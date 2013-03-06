require 'active_support'
require 'active_support/inflector'

module Multiflow
  extend ActiveSupport::Concern

  included do
    Multiflow::Persistence.load!(self)
  end

  def self.persistence
    @@persistence ||= nil
  end

  def self.persistence=(persistence)
    @@persistence = persistence
  end

  module ClassMethods
    def machines
      p @machines
      @machines ||= []
    end

    def stateflow(&block)
      @machines ||= []

      machine = Multiflow::Machine.new(&block)
      @machines << machine

      reader     = :"machine_#{machine.state_column}"
      state      = :"current_#{machine.state_column}"
      mach_ivar  = :"@#{reader}"
      state_ivar = :"@#{state}"

      if respond_to?(reader)
        raise ArgumentError, "Machine for #{machine.state_column} is already defined"
      end

      define_method(reader) do
        self.class.send reader
      end

      define_singleton_method(reader) do
        instance_variable_get(mach_ivar)
      end

      instance_variable_set(mach_ivar, machine)

      define_method(state) do
        state = instance_variable_get(state_ivar)

        if state.nil?
          loaded = load_from_persistence(machine)
          if loaded.nil?
            state = machine.initial_state
          else
            state = machine.states[loaded.to_sym]
          end

          instance_variable_set(state_ivar, state)
        end

        state
      end

      define_method("set_#{state}") do |state, options = {}|
        save_to_persistence(machine, state.name.to_s, options)
        instance_variable_set(state_ivar, state)
      end

      machine.states.values.each do |state|
        state_name = state.name

        define_method(:"#{state_name}?") do
          state_name == current_state.name
        end

        if machine.create_scopes?
          add_scope(machine, state)
        end
      end

      machine.events.keys.each do |key|
        define_method(key.to_sym) do
          fire_event(machine, key, :save => false)
        end

        define_method(:"#{key}!") do
          fire_event(machine, key, :save => true)
        end
      end
    end
  end

  def machines
    self.class.machines
  end

  private

  def fire_event(machine, event_name, options = {})
    event = machine.events[event_name.to_sym]
    raise Multiflow::NoEventFound.new("No event matches #{event_name}") if event.nil?

    current_state = send :"current_#{machine.state_column}"

    state = event.fire(machine, current_state, self, options)

    unless state.nil?
      send :"set_current_#{machine.state_column}", state, options
    end
  end
end

require 'multiflow/machine'
require 'multiflow/state'
require 'multiflow/event'
require 'multiflow/transition'
require 'multiflow/persistence'
require 'multiflow/exception'
require 'multiflow/railtie' if defined?(Rails)
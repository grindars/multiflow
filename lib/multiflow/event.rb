module Multiflow
  class Event
    attr_accessor :name, :transitions, :machine

    def initialize(name, machine=nil, &transitions)
      @name = name
      @machine = machine
      @transitions = Array.new

      instance_eval(&transitions)
    end

    def fire(machine, current_state, klass, options)
      transition = @transitions.select{ |t| t.from.include? current_state.name }.first
      raise NoTransitionFound.new("No transition found for event #{@name}") if transition.nil?

      return nil unless transition.can_transition?(klass)

      new_state = machine.states[transition.find_to_state(klass)]
      raise NoStateFound.new("Invalid state #{transition.to.to_s} for transition.") if new_state.nil?

      current_state.execute_action(:exit, klass)
      new_state.execute_action(:enter, klass)

      new_state
    end

    private
    def transitions(args = {})
      transition = Multiflow::Transition.new(args)
      @transitions << transition
    end

    def any
      @machine.states.keys
    end
  end
end

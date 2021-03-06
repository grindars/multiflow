module Multiflow
  module Persistence
    module ActiveRecord
      extend ActiveSupport::Concern

      included do
        before_validation(:ensure_initial_state, :on => :create)
      end

      module ClassMethods
        def add_scope(machine, state)
          scope state.name, -> { where("#{machine.state_column}".to_sym => state.name.to_s) }
        end
      end

      def load_from_persistence(machine)
        send machine.state_column.to_sym
      end

      def save_to_persistence(machine, new_state, options = {})
        send("#{machine.state_column}=".to_sym, new_state)
        save! if options[:save]
      end

      def ensure_initial_state
        machines.each do |machine|
          if send(machine.state_column.to_s).blank?
            current_state = send("current_#{machine.state_column}")
            send("#{machine.state_column.to_s}=", current_state.name.to_s)
          end
        end
      end
    end
  end
end

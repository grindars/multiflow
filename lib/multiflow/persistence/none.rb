module Multiflow
  module Persistence
    module None
      extend ActiveSupport::Concern

      module ClassMethods
        def add_scope(machine, state)
          # do nothing
        end
      end

      def load_from_persistence(machine)
        instance_variable_get :"@state_#{machine.state_column}"
      end

      def save_to_persistence(machine, new_state, options)
        instance_variable_set :"@state_#{machine.state_column}", new_state
      end
    end
  end
end

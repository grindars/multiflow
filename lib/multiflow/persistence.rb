module Multiflow
  module Persistence
    def self.active
      persistences = Array.new

      Dir[File.dirname(__FILE__) + '/persistence/*.rb'].each do |file|
        persistences << File.basename(file, File.extname(file)).underscore.to_sym
      end

      persistences
    end

    def self.load!(base)
      begin
        base.send :include, "Multiflow::Persistence::#{Multiflow.persistence.to_s.camelize}".constantize
      rescue NameError
        puts "[Multiflow] The ORM you are using does not have a Persistence layer. Defaulting to ActiveRecord."
        puts "[Multiflow] You can overwrite the persistence with Multiflow.persistence = :new_persistence_layer"

        Multiflow.persistence = :active_record
        base.send :include, "Multiflow::Persistence::ActiveRecord".constantize
      end
    end

    Multiflow::Persistence.active.each do |p|
      autoload p.to_s.camelize.to_sym, "multiflow/persistence/#{p.to_s}"
    end
  end
end
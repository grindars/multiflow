module Multiflow
  class Railtie < Rails::Railtie
    def default_orm
      generators = config.respond_to?(:app_generators) ? :app_generators : :generators
      config.send(generators).options[:rails][:orm]
    end

    initializer "multiflow.set_persistence" do
      Multiflow.persistence = default_orm if Multiflow.persistence.blank?
    end
  end
end
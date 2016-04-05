module ActiveTrail
  class Engine < ::Rails::Engine
    isolate_namespace ActiveTrail

    config.to_prepare do
      ActiveTrail::ApplicationController.helper Rails.application.helpers
    end
  end
end
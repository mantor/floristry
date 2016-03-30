module RuoteTrail
  class Engine < ::Rails::Engine
    isolate_namespace RuoteTrail

    config.to_prepare do
      RuoteTrail::ApplicationController.helper Rails.application.helpers
    end
  end
end
module Floristry
  class Engine < ::Rails::Engine
    isolate_namespace Floristry

    config.to_prepare do
      Floristry::ApplicationController.helper Rails.application.helpers
    end
  end
end
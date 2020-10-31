Floristry.configure do |config|
  # Sample configuration file to use in your application
  #
  # todo complete this doc. What does each mixin do ?
  # You can use it to define the following mixins:
  # Floristry::WorkflowBehavior
  # Floristry::TrailBehavior
  # Floristry::ActiveRecordBehaviour
  # Floristry::LeafBehavior
  # Floristry::TaskBehavior

  # Default values - Flack running on localhost on port 7007
  config.flack_proto = 'http'
  config.flack_host = 'localhost'
  config.flack_port = '7007'

  module Floristry
    module WebTaskFormBehaviour
      extend ActiveSupport::Concern

      included do
        alias_method :__simple_form_for, :simple_form_for
        def simple_form_for(record, options = {}, &block)

          if record.class.to_s.deconstantize == "Floristry::Web"
            # Disable task form fields if the task is inactive
            defaults = options[:defaults] || {}
            defaults.merge!(disabled: true) if record.inactive?
            options[:defaults] = defaults

            # Form action URL: It's a custom thing for tasks
            options[:url] = workflows_path + "/#{record.__feid__}/edit"
          end

          __simple_form_for record, options, &block
        end
      end
    end
  end

  SimpleForm::ActionViewExtensions::FormHelper.send(:include, Floristry::WebTaskFormBehaviour)
end
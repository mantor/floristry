ActiveTrail.configure do |config|
  # Sample configuration file to use in your application
  #
  # todo complete this doc. What does each mixin do ?
  # You can use it to define the following mixins:
  # ActiveTrail::WorkflowBehavior
  # ActiveTrail::TrailBehavior
  # ActiveTrail::ActiveRecordBehaviour
  # ActiveTrail::LeafBehavior
  # ActiveTrail::ParticipantBehavior

  module ActiveTrail
    module WebParticipantFormBehaviour
      extend ActiveSupport::Concern

      included do
        alias_method :__simple_form_for, :simple_form_for
        def simple_form_for(record, options = {}, &block)

          if record.class.to_s.deconstantize == "ActiveTrail::Web"
            # Disable participant form fields if the participant is inactive
            defaults = options[:defaults] || {}
            defaults.merge!(disabled: true) if record.inactive?
            options[:defaults] = defaults

            # Form action URL: It's a custom thing for participants
            options[:url] = workflows_path + "/#{record.__feid__}/edit"
          end

          __simple_form_for record, options, &block
        end
      end
    end
  end

  SimpleForm::ActionViewExtensions::FormHelper.send(:include, ActiveTrail::WebParticipantFormBehaviour)
end
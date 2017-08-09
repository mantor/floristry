module ActiveTrail
  class WebparticipantController < ::ApplicationController

    skip_before_action :verify_authenticity_token

    def create

      model = "ActiveTrail::Web::#{params['message']['attd']['model'].classify}".constantize

      model.create(params['message'])
      render nothing: true
    end
  end
end

module ActiveTrail
  class ObserverController < ::ApplicationController

    skip_before_action :verify_authenticity_token

    before_action :set_default_response_format

    def terminated

      Trail.terminated(params['id'], params['message'])

      #todo Should we send back a status and let flack handle errors, etc.
      render nothing: true
    end

    protected

    def set_default_response_format
      request.format = :json
    end
  end
end
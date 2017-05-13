module ActiveTrail
  class HookhandlerController < ::ApplicationController

    skip_before_action :verify_authenticity_token

    before_action :set_default_response_format

    def launched

      Trail.launched(params['message'])

      #todo Should we send back a status and let flack handle errors, etc.
      render nothing: true
    end

    def error

      Trail.error(params['id'], params['message'])

      #todo Should we send back a status and let flack handle errors, etc.
      render nothing: true
    end

    def returned

      Trail.replied(params['id'], params['message'])

      #todo Should we send back a status and let flack handle errors, etc.
      render nothing: true
    end

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
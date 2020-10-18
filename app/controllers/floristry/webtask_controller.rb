module Floristry
  class WebTaskController < ::ApplicationController

    skip_before_action :verify_authenticity_token

    def create

      model = "Floristry::Web::#{params['message']['attd']['model'].classify}".constantize

      model.create(params['message'])
      render nothing: true
    end
  end
end

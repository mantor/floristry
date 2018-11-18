module Floristry
  class WorkflowsController < ::ApplicationController
    # layout 'application'

    def index

      @wfs = Workflow.all
    end

    def edit

      @wf ||= Workflow.find(params[:id])
    end

    def update

      @wf = Workflow.find(params[:id])
      if @wf.wi.update_attributes(workflow_params(@wf))

        if params[:commit] == 'Close'

          @wf.wi.return
          flash[:notice] = "#{@wf.wi.instance.class.to_s.demodulize} was successfully closed."
          redirect_to action: :edit, id: @wf.exid
        else

          flash[:notice] = "#{@wf.wi.instance.class.to_s.demodulize} was successfully updated."
          redirect_to action: :edit
        end
      else

        flash[:error] = "An error prohibited this #{@wf.wi.instance.class.to_s.demodulize} from being saved."
        render :edit
      end
    end

    protected

    def workflow_params(wf)

      attrs = wf.wi.attributes.keys - Floristry::ActiveRecord::Base::ATTRIBUTES_TO_EXCLUDE
      params.require("#{wf.wi.module_name}_#{wf.wi.name}".underscore.to_sym).permit(attrs)
    end
  end
end
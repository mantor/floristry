class FlowsController < ApplicationController
  before_action :set_flow, only: [:show, :edit, :update, :launch, :destroy]

  # GET /flows
  def index
    @flows = Flow.all
  end

  # GET /flows/1
  def show
  end

  # GET /flows/new
  def new
    @flow = Flow.new
  end

  # GET /flows/1/edit
  def edit
  end

  # POST /flow/1/launch
  def launch
    exid = @flow.launch
    @flows = Flow.all
    redirect_to flows_url, notice: "Flow was launched. Execution id is: #{exid}"
  end

  # POST /flows
  def create
    @flow = Flow.new(flow_params)

    if @flow.save
      redirect_to @flow, notice: 'Flow was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /flows/1
  def update
    if @flow.update(flow_params)
      redirect_to @flow, notice: 'Flow was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /flows/1
  def destroy
    @flow.destroy
    redirect_to flows_url, notice: 'Flow was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flow
      @flow = Flow.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def flow_params
      params.require(:flow).permit(:name, :definition)
    end
end

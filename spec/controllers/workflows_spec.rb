require 'rails_helper'

describe ActiveTrail::WorkflowsController do

  describe 'GET /workflows' do

    context 'when no flows have been launched' do

      it 'lists nothing' do

        get :index
        expect(assigns(:wfs)).to eq([])
      end
    end

    context 'when one flow is launched and completed' do
      fixtures :active_trail_trails

      it 'lists it' do

        get :index

        expect(assigns(:wfs).size).to eq(1)
        expect(assigns(:wfs).first).to be_a(ActiveTrail::Workflow)
      end

    end
  end
end

require 'rails_helper'

describe ActiveTrail::WorkflowsController do
  describe 'GET /workflows' do
    context 'when no flows have been launched' do
      it 'lists nothing' do
        get :index
        expect(assigns(:wfs)).to eq([])
      end
    end

    context 'when flows have been launched' do
      set_fixture_class active_trail_trails: ActiveTrail::Trail
      fixtures :active_trail_trails

      it 'lists them' do
        get :index
        expect(assigns(:wfs).size).to be > 0
        expect(assigns(:wfs).first).to be_a(ActiveTrail::Workflow)
      end
    end
  end

  describe 'GET /workflow/:id/edit' do
    render_views
    set_fixture_class active_trail_trails: ActiveTrail::Trail
    fixtures :active_trail_trails

    context "branch expressions:" do
      context 'sequence' do
        it 'renders the sequence partial' do
          sequence = active_trail_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_sequence')
          expect(response).to render_template(partial: '_sequence_spacer')
        end
      end

      context 'concurrence' do
        it 'renders the concurrence partial' do
          skip("not implemented")
          concurrence = active_trail_trails(:concurrence)

          get :edit, id: concurrence.wfid
          expect(response).to render_template(partial: '_concurrence')
          expect(response).to render_template(partial: '_concurrence_spacer')
        end
      end
    end

    context "leaf expression" do
      it "renders the leaf-expression layout" do
        sequence = active_trail_trails(:sequence)
        get :edit, id: sequence.wfid
        expect(response).to render_template(partial: '_leaf-expression')
      end

      context "cron" do
        it 'renders the cron partial' do
          skip("not implemented")
          sequence = active_trail_trails(:sequence_cron)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_cron')
        end
      end

      context "if" do
        it 'renders the if partial' do
          skip("not implemented")
          sequence = active_trail_trails(:sequence_if)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_if')
        end
      end

      context "set" do
        it 'renders the set partial' do
          sequence = active_trail_trails(:sequence_set)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_set')
        end
      end

      context "sleep" do
        it 'renders the sleep partial' do
          sequence = active_trail_trails(:sequence_sleep)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_sleep')
        end
      end

      context "stall" do
        it 'renders the stall partial' do
          sequence = active_trail_trails(:sequence_stall)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_stall')
        end
      end

      context "task" do
        it 'renders the task partial' do
          sequence = active_trail_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_participant')
        end
      end

      context "tasker" do
        it 'renders the tasker -> participant partial' do
          sequence = active_trail_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_participant')
        end
      end

      context "wait" do
        it 'renders the wait partial' do
          sequence = active_trail_trails(:sequence_wait)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_wait')
        end
      end
    end
  end
end

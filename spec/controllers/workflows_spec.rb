require 'rails_helper'

describe Floristry::WorkflowsController do
  describe 'GET /workflows' do
    context 'when flows have been launched' do
      set_fixture_class floristry_trails: Floristry::Trail
      fixtures :floristry_trails

      it 'lists them' do
        get :index
        expect(assigns(:wfs).size).to be > 0
        expect(assigns(:wfs).first).to be_a(Floristry::Workflow)
      end
    end
  end

  describe 'GET /workflow/:id/edit' do
    render_views
    set_fixture_class floristry_trails: Floristry::Trail
    fixtures :floristry_trails

    context "branch expressions:" do
      context 'sequence' do
        it 'renders the sequence partial' do
          sequence = floristry_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_sequence')
          expect(response).to render_template(partial: '_sequence_spacer')
        end
      end

      context 'concurrence' do
        it 'renders the concurrence partial' do
          skip("not implemented")
          concurrence = floristry_trails(:concurrence)

          get :edit, id: concurrence.wfid
          expect(response).to render_template(partial: '_concurrence')
          expect(response).to render_template(partial: '_concurrence_spacer')
        end
      end
    end

    context "leaf expression" do
      it "renders the leaf-expression layout" do
        sequence = floristry_trails(:sequence)
        get :edit, id: sequence.wfid
        expect(response).to render_template(partial: '_leaf-expression')
      end

      context "cron" do
        it 'renders the cron partial' do
          skip("not implemented")
          sequence = floristry_trails(:sequence_cron)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_cron')
        end
      end

      context "if" do
        it 'renders the if partial' do
          skip("not implemented")
          sequence = floristry_trails(:sequence_if)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_if')
        end
      end

      context "set" do
        it 'renders the set partial' do
          sequence = floristry_trails(:sequence_set)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_set')
        end
      end

      context "sleep" do
        it 'renders the sleep partial' do
          sequence = floristry_trails(:sequence_sleep)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_sleep')
        end
      end

      context "stall" do
        it 'renders the stall partial' do
          sequence = floristry_trails(:sequence_stall)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_stall')
        end
      end

      context "task" do
        it 'renders the task partial' do
          sequence = floristry_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_participant')
        end
      end

      context "tasker" do
        it 'renders the tasker -> participant partial' do
          sequence = floristry_trails(:sequence)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_participant')
        end
      end

      context "wait" do
        it 'renders the wait partial' do
          sequence = floristry_trails(:sequence_wait)
          get :edit, id: sequence.wfid
          expect(response).to render_template(partial: '_wait')
        end
      end

      context "web participant" do
        describe 'renders the appropriate web participant partial' do
          it 'renders the form tark participant form partial' do
            sequence = floristry_trails(:sequence_web_part)
            get :edit, id: sequence.wfid
            expect(response).to render_template(partial: '_form_task')
          end
        end
      end
    end
  end
end

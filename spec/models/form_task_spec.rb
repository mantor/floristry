require 'rails_helper'

RSpec.describe ActiveTrail::Web::FormTask, :type => :model do
  describe "create" do

    context "given a malformed 'wi'" do
      it "fails if nil" do
        expect { ActiveTrail::Web::FormTask.create(nil) }.
          to raise_error("'wi' can't be nil")
      end

      it "fails if it's missing the exid" do
        expect { ActiveTrail::Web::FormTask.create({'nothing' => ''}) }.
          to raise_error("'wi' does not contain an 'exid'")
      end

      it "fails if it's missing the nid" do
        expect { ActiveTrail::Web::FormTask.create({'exid' => 'exid'}) }.
          to raise_error("'wi' does not contain an 'nid'")
      end

      it "fails if it's missing a playload" do
        expect {
          ActiveTrail::Web::FormTask.create(
            {
              'exid' => '',
              'nid' => ''
            }
          )
        }.to raise_error("'wi' is missing the payload")
      end

      it "fails if it's missing 'attd'" do
        expect {
          ActiveTrail::Web::FormTask.create(
            {
              'exid' => '',
              'nid' => '',
              'payload' => ''
            }
          )
        }.to raise_error("'wi' is missing 'attd'")
      end

      it "fails if exid and nid can't be parsed as a FlowExpressionId" do
        expect {
          ActiveTrail::Web::FormTask.create(
            {
              'exid' => '',
              'nid' => '',
              'payload' => '',
              'attd' => ''
            }
          )
        }.to raise_error("ActiveRecord::RecordNotFound")
      end
    end

    context "with a complete wi" do

      wi = {
        exid: 'test0-u0-20170831.0132.dijoshiyudu',
        nid: "0_1",
        payload: { ret: nil, post_tstamp: "2017-08-23 21:27:00 -0400" },
        tasker: "web",
        attl: ["web"],
        attd: {  model: "form_task" },
        vars: nil
      }

      it "sets the current state to 'open'" do

        form_task = ActiveTrail::Web::FormTask.create(wi)

        expect(form_task.current_state).to eq('open')
      end

      it "initializes a @fei" do

        form_task = ActiveTrail::Web::FormTask.create(wi)

        expect(form_task.fei.exid).to eq(wi[:exid])
        expect(form_task.fei.nid).to eq(wi[:nid])
      end
    end
  end

  describe "update" do

    wi = {
      exid: 'test0-u0-20170831.0132.dijoshiyudu',
      nid: "0_1",
      payload: { ret: nil, post_tstamp: "2017-08-23 11:11:00 -0400" },
      tasker: "web",
      attl: ["web"],
      attd: {  model: "form_task" },
      vars: nil
    }

    it "sets the current state to 'in progress'" do

      form_task = ActiveTrail::Web::FormTask.create(wi)

      form_task.update_attributes({free_text: 'Updated text'})

      expect(form_task.current_state).to eq('in_progress')
    end

    it "updates the active record model attributes" do
      form_task = ActiveTrail::Web::FormTask.create(wi)
      form_task.update_attributes({free_text: 'Updated text'})
      id = form_task.id

      form_task = ActiveTrail::Web::FormTask.find(id)

      expect(form_task.free_text).to eq('Updated text')
    end
  end

  describe "return" do

    wi = {
      exid: 'test0-u0-20170831.0132.dijoshiyudu',
      nid: "0_1",
      payload: { ret: nil, post_tstamp: "2017-08-23 11:11:00 -0400" },
      tasker: "web",
      attl: ["web"],
      attd: {  model: "form_task" },
      vars: nil
    }

    it "sets the current state to 'closed'" do

      form_task = ActiveTrail::Web::FormTask.create(wi)
      form_task.update_attributes({free_text: 'Updated text'})
      form_task.return

      expect(form_task.current_state).to eq('closed')
    end

    it "merges the model's attributes with the payload" do

      form_task = ActiveTrail::Web::FormTask.create(wi)
      form_task.update_attributes({free_text: 'Updated text'})

      expected_merged_wi = {
        "exid" => "test0-u0-20170831.0132.dijoshiyudu",
        "nid" => "0_1",
        "payload" => {
          "ret" => nil,
          "post_tstamp" => "2017-08-23 11:11:00 -0400",
          "free_text" => "Updated text"
        },
        "tasker" => "web",
        "attl" => ["web"],
        "attd" => {"model"=>"form_task"},
        "vars" => nil
      }

      expect(ActiveTrail::WorkflowEngine)
        .to receive(:return).with(wi[:exid], wi[:nid], expected_merged_wi)

      form_task.return
    end
  end
end
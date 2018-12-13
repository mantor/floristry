require 'rails_helper'

RSpec.describe Floristry::Web::FormTask, :type => :model do
  describe "create" do

    context "given a malformed 'msg'" do
      it "fails if nil" do
        expect { Floristry::Web::FormTask.create(nil) }.
          to raise_error("'msg' can't be nil")
      end

      it "fails if it's missing the exid" do
        expect { Floristry::Web::FormTask.create({'nothing' => ''}) }.
          to raise_error("'msg' does not contain an 'exid'")
      end

      it "fails if it's missing the nid" do
        expect { Floristry::Web::FormTask.create({'exid' => 'exid'}) }.
          to raise_error("'msg' does not contain an 'nid'")
      end

      it "fails if it's missing a playload" do
        expect {
          Floristry::Web::FormTask.create(
            {
              'exid' => '',
              'nid' => ''
            }
          )
        }.to raise_error("'msg' is missing the payload")
      end

      it "fails if it's missing 'attd'" do
        expect {
          Floristry::Web::FormTask.create(
            {
              'exid' => '',
              'nid' => '',
              'payload' => ''
            }
          )
        }.to raise_error("'msg' is missing 'attd'")
      end

      it "fails if exid and nid can't be parsed as a FlowExecutionId" do
        expect {
          Floristry::Web::FormTask.create(
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

    context "msg a complete msg" do

      msg = {
        exid: 'test0-u0-20170831.0132.dijoshiyudu',
        nid: "0_1",
        payload: { ret: nil, post_tstamp: "2017-08-23 21:27:00 -0400" },
        tasker: "web",
        attl: ["web"],
        attd: {  model: "form_task" },
        vars: nil
      }

      it "sets the current state to 'open'" do

        form_task = Floristry::Web::FormTask.create(msg)

        expect(form_task.current_state).to eq('open')
      end

      it "initializes a @fei" do

        form_task = Floristry::Web::FormTask.create(msg)

        expect(form_task.fei.exid).to eq(msg[:exid])
        expect(form_task.fei.nid).to eq(msg[:nid])
      end
    end
  end

  describe "update" do

    msg = {
      exid: 'test0-u0-20170831.0132.dijoshiyudu',
      nid: "0_1",
      payload: { ret: nil, post_tstamp: "2017-08-23 11:11:00 -0400" },
      tasker: "web",
      attl: ["web"],
      attd: {  model: "form_task" },
      vars: nil
    }

    it "sets the current state to 'in progress'" do

      form_task = Floristry::Web::FormTask.create(msg)

      form_task.update_attributes({free_text: 'Updated text'})

      expect(form_task.current_state).to eq('in_progress')
    end

    it "updates the active record model attributes" do
      form_task = Floristry::Web::FormTask.create(msg)
      form_task.update_attributes({free_text: 'Updated text'})
      id = form_task.id

      form_task = Floristry::Web::FormTask.find(id)

      expect(form_task.free_text).to eq('Updated text')
    end
  end

  describe "return" do

    msg = {
      exid: 'test0-u0-20170831.0132.dijoshiyudu',
      nid: "0_1",
      payload: { ret: nil, post_tstamp: "2017-08-23 11:11:00 -0400" },
      tasker: "web",
      attl: ["web"],
      attd: {  model: "form_task" },
      vars: nil
    }

    it "sets the current state to 'closed'" do

      form_task = Floristry::Web::FormTask.create(msg)
      form_task.update_attributes({free_text: 'Updated text'})
      form_task.return

      expect(form_task.current_state).to eq('closed')
    end

    it "merges the model's attributes msg the payload" do

      form_task = Floristry::Web::FormTask.create(msg)
      form_task.update_attributes({free_text: 'Updated text'})

      expected_merged_msg = {
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

      expect(Floristry::WorkflowEngine)
        .to receive(:return).with(msg[:exid], msg[:nid], expected_merged_msg)

      form_task.return
    end
  end
end

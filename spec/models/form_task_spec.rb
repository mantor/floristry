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

      expected_merged_msg = {"ret"=>nil,
         "post_tstamp"=>"2017-08-23 11:11:00 -0400",
         "free_text"=>"Updated text"
      }

      expect(Floristry::WorkflowEngine)
        .to receive(:return).with(msg[:exid], msg[:nid], expected_merged_msg)

      form_task.return
    end
  end

  describe "when combined with other flor units" do
    it "sets payload field(s)" do
      exid = Floristry::WorkflowEngine.launch(
        %{
          web model: 'form_task' _
        })

      sleep 1
      call_return_on_form_task exid, '0'

      r = Floristry::WorkflowEngine.process(exid)
      expect(r).to be_a(Hash)
      expect(r['data']['closing_messages'][0]['payload']).to have_key('free_text')
      expect(r['data']['closing_messages'][0]['payload']['free_text']).to eq('Testati testato')
    end

    it "does not interfere with other taskers payload fields" do
      control_exid = Floristry::WorkflowEngine.launch(
        %{
          alice _
          web model: 'form_task' _
        })

      sleep 1
      call_return_on_form_task control_exid, '0_1'

      r = Floristry::WorkflowEngine.process(control_exid)
      expect(r).to be_a(Hash)

      expect(r['data']['closing_messages'][0]['payload']).to have_key('alice_tstamp')
      expect(r['data']['closing_messages'][0]['payload']).to have_key('free_text')
    end

    it "sets fields to be used by other procs" do
      control_exid = Floristry::WorkflowEngine.launch(
        %{
          alice _
          web model: 'form_task' _
          if (f.free_text == 'Testati testato')
            bob _
          if (f.free_text != 'Testati testato')
            charlie _
        })

      sleep 1
      call_return_on_form_task control_exid, '0_1'

      r = Floristry::WorkflowEngine.process(control_exid)
      expect(r).to be_a(Hash)

      expect(r['data']['closing_messages'][0]['payload']).to have_key('alice_tstamp')
      expect(r['data']['closing_messages'][0]['payload']).to have_key('free_text')
      expect(r['data']['closing_messages'][0]['payload']).to have_key('bob_tstamp')
      # Charlie is not called, condition is false
      expect(r['data']['closing_messages'][0]['payload']).not_to have_key('charlie_tstamp')
    end
  end
end

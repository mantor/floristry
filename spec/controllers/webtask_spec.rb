require 'rails_helper'

describe Floristry::WebtaskController do

  set_fixture_class floristry_trails: Floristry::Trail
  fixtures :floristry_trails

  it "creates the task on msg from hook" do
    sequence = floristry_trails(:sequence_web_task)

    msg = get_create_msg(sequence)
    post :create, :message => msg

    form_task = Floristry::Web::FormTask.find("#{msg[:exid]}!#{msg[:nid]}")
    expect(form_task.current_state).to eq('open')
  end

  it "handles the reply msg" do
    exid = Floristry::WorkflowEngine.launch(
      %{
        alice _
        web model: 'form_task' _
      })

    sleep 1

    r = Floristry::WorkflowEngine.process(exid)
    expect(r).to be_a(Hash)
    expect(r['status']).to eq('active')

    form_task = call_return_on_form_task exid, '0_1'
    expect(form_task.current_state).to eq('closed')

    r = Floristry::WorkflowEngine.process(exid)
    expect(r).to be_a(Hash)
    expect(r['status']).to eq('terminated')
  end

  # This is what flack sends through the WebTasker.
  # We only really use a subset of it, but I included unedited so we can see if it ever change
  # after the spec is written.
  def get_create_msg(sequence)
    {
      point: "task",
      exid: sequence.wfid,
      nid: "0_1",
      from: "0_1",
      sm: 23,
      payload: {
        ret: nil,
        alice_tstamp: "2017-08-23 21:26:59 -0400",
        post_tstamp: "2017-08-23 21:27:00 -0400"
      },
      tasker: "web",
      taskname: nil,
      attl: ["web"],
      attd: {
        model: "form_task"
      },
      er: 2,
      m: 24,
      pr: 2,
      tconf: {
        require: "tasker.rb",
        class: "WebTasker",
        _path: "envs/dev/lib/taskers/web/dot.json",
        root: "envs/dev/lib/taskers/web"
      },
      vars: nil
    }
  end
end
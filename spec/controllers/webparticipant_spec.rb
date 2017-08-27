require 'rails_helper'

describe ActiveTrail::WebparticipantController do

  set_fixture_class active_trail_trails: ActiveTrail::Trail
  fixtures :active_trail_trails

  it "creates the participant on msg from hook" do
    sequence = active_trail_trails(:sequence_web_part)

    post :create, :message => get_msg(sequence)

    form_task = ActiveTrail::Web::FormTask.find(sequence.wfid)
    expect(form_task.current_state).to eq('open')
  end

  it "handles the reply msg" do
    skip("not implemented")
  end

  # This is what flack sends through the WebTasker.
  # We only really use a subset of it, but I included unedited so we can see if it ever change
  # after the spec is written.
  def get_msg(sequence)
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
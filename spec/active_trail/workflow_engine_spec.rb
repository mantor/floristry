require 'rails_helper'
require 'active_trail/workflow_engine'

describe ActiveTrail::WorkflowEngine do

  it "should have an http client that communicates with flack" do

    r = ActiveTrail::WorkflowEngine.engine('/')

    expect(r.body.to_s).to match('flack')
  end

  it "should launch a flow and return it's exid" do

    r = ActiveTrail::WorkflowEngine.launch(%{ alice _ })

    expect(r).to match(/[0-9A-Za-z\-\.]+/) #Looks like an exid
  end

  it "should retrieve a flow by it's exid" do

    exid = ActiveTrail::WorkflowEngine.launch(%{ alice_ })

    sleep 1
    r = ActiveTrail::WorkflowEngine.process(exid)
    expect(r).to be_a(Hash)
  end

end
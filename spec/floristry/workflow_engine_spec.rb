require 'rails_helper'
require 'floristry/workflow_engine'

describe Floristry::WorkflowEngine do

  it "should have an http client that communicates with flack" do

    r = Floristry::WorkflowEngine.engine('/')

    expect(r.body.to_s).to match('flack')
  end

  it "should launch a flow and return it's exid" do

    r = Floristry::WorkflowEngine.launch(%{ alice _ })

    expect(r).to match(/[0-9A-Za-z\-\.]+/) #Looks like an exid
  end

  it "should retrieve a flow by it's exid" do

    exid = Floristry::WorkflowEngine.launch(%{ alice_ })

    sleep 1
    r = Floristry::WorkflowEngine.process(exid)
    expect(r).to be_a(Hash)
  end

end
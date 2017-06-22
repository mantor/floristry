require 'spec_helper'

class LeafExpressionTest < ActiveSupport::TestCase

  test "it parses Stall params" do

    params = [["_att",[["timeout",[],6],["_dqs","1s",6]],6]]

    stall = ActiveTrail::Stall.new('test-u0-test', 'test', params, [], 'present')
    assert_equal(["timeout", "1s"], stall.params)
  end

  test "it parses Sleep params" do

    params = [["_att",[["_sqs","1d",4]],4]]

    sleep = ActiveTrail::Sleep.new('test-u0-test', 'test', params, [], 'present')
    assert_equal(["1d"], sleep.params)
  end

  test "it parses Set params" do

    params = [["_att",[["procedure_id",[],1]],1],["_att",[["_num",10,1]],1]]

    set = ActiveTrail::Set.new('test-u0-test', 'test', params, [], 'present')
    assert_equal(["procedure_id", "10"], set.params)
  end

  test "it parses a Task params" do

    params = [["_att",[["cmd",[],3],["_sqs","ls",3]],3,{ret: nil, task_tstamp:"1111-11-11 11:11:11 -0400"}],["_att",[["target",[],3],["_sqs","temp",3]],3]];

    task = ActiveTrail::Task.new('test-u0-test', 'test', params, [], 'present')
    assert_equal(["cmd", "ls", "target", "temp"], task.params)
  end

  test "it accesses a Task payload" do

    params = [["_att",[["cmd",[],3],["_sqs","ls",3]],3,{ret: nil, task_tstamp:"1111-11-11 11:11:11 -0400"}],["_att",[["target",[],3],["_sqs","temp",3]],3]];

    task = ActiveTrail::Task.new('test-u0-test', 'test', params, {ret: nil, task_tstamp:"1111-11-11 11:11:11 -0400"}, 'present')
    assert_equal({ret: nil, task_tstamp:"1111-11-11 11:11:11 -0400"}, task.payload)
  end
end

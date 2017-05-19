require 'test_helper'

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
end

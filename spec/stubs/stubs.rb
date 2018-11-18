def stub_workflow

  # Creates a new instance of an Floristry::Workflow, which is transient, based on a stubbed Floristry::Trail
  Floristry::Workflow.new('test-u0-11111111.1337.testmetobesi',
                          stub_model(Floristry::Trail) {|trail|
      trail.wfid = "test-u0-11111111.1337.testmetobesi"
      trail.tree = ["sequence", [["alice", [["_att", [["_", [], 3]], 3]], 3, {"ret" => "alice", "alice_tstamp" => "2017-07-02 19:27:25 -0400"}], ["bob", [["_att", [["_", [], 4]], 4]], 4, {"ret" => "bob", "alice_tstamp" => "2017-07-02 19:27:25 -0400", "bob_tstamp" => "2017-07-02 19:27:25 -0400"}]], 2, {}, {}]
    }
  )
end

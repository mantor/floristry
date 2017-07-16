require "rails_helper"

describe "active_trail/workflows/edit.html.erb" do
  set_fixture_class active_trail_trails: ActiveTrail::Trail
  fixtures :active_trail_trails

  before(:all) do
    # allow_any_instance_of(ActiveTrail::Workflow).to receive(:@current_nids).and_return(["0_1"])
  end

  context "completed workflow" do
    it "display participants as 'closed'" do
      assign(:wf, stub_workflow)
      render

      expect(rendered).to match /closed.*alice/m
      expect(rendered).to match /closed.*bob/m
    end
  end

  context "in progress workflow" do
    it "display one participant as 'closed' and the other as 'open'" do
      wf = stub_workflow
      wf.current_nids = ["0_1"]
      assign(:wf, wf)
      render

      expect(rendered).to match /closed.*alice/m
      expect(rendered).to match /open.*bob/m
    end
  end

end
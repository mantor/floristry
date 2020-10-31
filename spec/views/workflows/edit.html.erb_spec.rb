require "rails_helper"

describe "floristry/workflows/edit.html.erb" do
  set_fixture_class floristry_trails: Floristry::Trail
  fixtures :floristry_trails

  context "terminated workflow" do
    it "display tasks as 'closed'" do
      wf = stub_workflow
      wf.current_nids = []
      assign(:wf, wf)
      render

      expect(rendered).to match /closed.*alice/m
      expect(rendered).to match /closed.*bob/m
    end
  end

  context "in progress workflow" do
    it "display one task as 'closed' and the other as 'open'" do
      wf = stub_workflow
      wf.current_nids = ["test-u0-11111111.1337.testmetobesi!0_1"]
      assign(:wf, wf)
      render

      expect(rendered).to match /closed.*alice/m
      expect(rendered).to match /open.*bob/m
    end
  end

end
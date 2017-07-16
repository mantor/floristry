require "rails_helper"

describe "active_trail/workflows/index.html.erb" do

  context "with no workflows" do
    it "displays an 0 records" do
      assign(:wfs, [])
      render

      expect(rendered).to match("0 records")
    end
  end

  context "with 1 workflow" do
    let(:trail) { [] }
    before(:each) do

      assign(:wfs, [
        stub_workflow
      ])
    end

    it "displays that there is 1 record" do
      render

      expect(rendered).to match("1 records")
    end

    context "displays it's details in the list" do

      it "displays it's exid" do
        render

        expect(rendered).to match("test-u0-11111111.1337.testmetobesi")
      end

      it "displays a link to the edit action" do
        render

        expect(rendered).to match("/workflows/test-u0-11111111.1337.testmetobesi/edit")
      end
    end
  end

  context "with 2 workflows" do
    before(:each) do
      assign(:wfs, [
        stub_workflow,
        stub_workflow
      ])
    end

    it "displays that there is 2 record" do
      render

      expect(rendered).to match("2 records")
    end
  end
end
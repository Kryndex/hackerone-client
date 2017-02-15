require "spec_helper"

RSpec.describe HackerOne::Client do
  let(:api) { HackerOne::Client::Api.new("github") }
  it "has a version number" do
    expect(Hackerone::Client::VERSION).not_to be nil
  end

  context "#report" do
    it "fetches and populates a report" do
      VCR.use_cassette(:report) do
        example_report = api.report(200)
        expect(example_report.id).to eq("200")
        expect(example_report.title).to eq("Sweet Vuln")
        expect(example_report.reporter).to_not be_nil
        expect(example_report.risk).to eq("low")
        expect(example_report.payment_total).to eq(500)
      end
    end

    it "raises an exception if a report is not found" do
      VCR.use_cassette(:missing_report) do
        expect { api.report(404) }.to raise_error(ArgumentError)
      end
    end
  end

  context "#reports" do
    it "raises an error if no program is supplied" do
      expect { HackerOne::Client::Api.new.reports }.to raise_error(ArgumentError)
    end

    it "returns reports for a default program" do
      begin
        HackerOne::Client.program = "github"
        VCR.use_cassette(:report_list, record: :new_episodes) do
          expect(HackerOne::Client::Api.new.reports).to_not be_empty
        end
      ensure
        HackerOne::Client.program = nil
      end
    end

    it "returns reports for a given program" do
      VCR.use_cassette(:report_list, record: :new_episodes) do
        expect(api.reports).to_not be_empty
      end
    end

    it "returns an empty array if no reports are found" do
      VCR.use_cassette(:empty_report_list, record: :new_episodes) do
        expect(api.reports).to be_empty
      end
    end
  end
end
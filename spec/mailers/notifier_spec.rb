require "spec_helper"

describe Notifier do
  describe "sync_email" do
    let(:mail) { Notifier.sync_email([]) }

    it "renders the headers" do
      mail.subject.should eq("Camfed Data Import for #{Date.today.to_s}")
      mail.to.should eq(["admin@example.com"])
      mail.from.should eq(["admin@example.com"])
    end

  end

end

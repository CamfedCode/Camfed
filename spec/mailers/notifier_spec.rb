require "spec_helper"

describe Notifier do
  describe "sync_email" do
    let(:mail) { Notifier.sync_email([]) }

    it "renders the headers" do
      config = ""
      config.should_receive(:notify_email).and_return('admin@example.com')
      Configuration.should_receive(:instance).and_return(config)
      mail.subject.should eq("Camfed Data Import for #{Date.today.to_s}")
      mail.to.should eq(["admin@example.com"])
      mail.from.should eq(["camfed.notification@gmail.com"])
    end

  end

end

class Notifier < ActionMailer::Base
  default :from => "admin@example.com"

  def sync_email import_histories
    @import_histories = import_histories
    mail :to => "admin@example.com", :subject => "Camfed Data Import for #{Date.today.to_s}"
  end
end

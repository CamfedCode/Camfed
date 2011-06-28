class Notifier < ActionMailer::Base
  default :from => "camfed.notification@gmail.com"

  def sync_email import_histories, to_email_address
    @import_histories = import_histories
    mail :to => to_email_address, :subject => "Camfed Data Import for #{Date.today.to_s}"
  end
end

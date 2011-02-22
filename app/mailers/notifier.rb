class Notifier < ActionMailer::Base
  default :from => "camfed.notification@gmail.com"

  def sync_email import_histories
    @import_histories = import_histories
    mail :to => Configuration.instance.notify_email, :subject => "Camfed Data Import for #{Date.today.to_s}"
  end
end

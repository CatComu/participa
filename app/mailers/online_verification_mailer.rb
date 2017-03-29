class OnlineVerificationMailer < ActionMailer::Base
  layout "email"
  default from: Rails.application.secrets.default_from_email

  def report event
    @event = event

    mail to: event.verified.email,
         subject: t('online_verifications.mailer.subject')
  end
end

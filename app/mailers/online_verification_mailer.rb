class OnlineVerificationMailer < ActionMailer::Base
  layout "email"
  default from: Rails.application.secrets.default_from_email

  def report event
    @event = event

    #
    # @todo. Store user's locale in DB and use that locale for sending emails.
    # For now, we use the default locale since we can't be sure and we
    # definitely don't want the user to receive emails in the verificator's
    # locale.
    #
    I18n.with_locale(I18n.default_locale) do
      mail to: event.verified.email,
         subject: t('online_verifications.mailer.subject')
    end
  end
end

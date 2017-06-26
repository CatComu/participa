class ConfirmationMailer < ActionMailer::Base
  layout "email"
  default from: Rails.application.secrets.default_from_email

  def retry_confirmation_instructions(user)
    @user = user
    @token = user.confirmation_token

    subject = '[Catalunya en Comú - ATENCIÓ] Si no confirmes el teu correu, no podràs participar!'

    mail(to: user.email, subject: subject)

    user.update!(confirmation_sent_at: Time.zone.now)
  end
end

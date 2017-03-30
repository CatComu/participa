class VerificationMailer < ActionMailer::Base
  layout "email"
  default from: Rails.application.secrets.default_from_email

  # user is verified
  def verified user
    @user = user

    #
    # @todo. Store user's locale in DB and use that locale for sending emails.
    # For now, we use the default locale since we can't be sure and we
    # definitely don't want the user to receive emails in the verificator's
    # locale.
    #
    I18n.with_locale(I18n.default_locale) do
      mail(to: @user.email, subject: t('verification.mailer.verified.subject'))
    end
  end

  def finish user
    @user = user
    mail(to: @user.email, subject: t('verification.mailer.finish.subject'))
  end

end

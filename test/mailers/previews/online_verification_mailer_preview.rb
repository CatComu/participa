class OnlineVerificationMailerPreview < ActionMailer::Preview
  #
  # Preview this email at
  # http://localhost:3000/rails/mailers/online_verification_mailer/report
  #
  def report
    event = OnlineVerifications::Report.create! \
              verified: User.online_verification_pending.first,
              verifier: User.verifying_presentially.first,
              label_ids: OnlineVerifications::Label.where(id: [1, 2]).pluck(:id)

    OnlineVerificationMailer.report event
  end
end

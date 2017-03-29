require 'test_helper'

class OnlineVerificationMailerTest < ActionMailer::TestCase
  setup do
    verified = create(:user, :confirmed_by_sms, email: "pep@example.org")
    label = create(:online_verification_label, code: 'invalid_id')

    @report = create(:online_verification_report, verified: verified)

    @report.labels << label
  end

  test "report" do
    mail = OnlineVerificationMailer.report(@report)

    assert_equal \
      "Revisa tu solicitud de verificación digital en Un País En Comú",
      mail.subject

    assert_equal ["pep@example.org"], mail.to
    assert_equal ["changeme@example.com"], mail.from

    assert_match "Debe ser DNI, NIE o pasaporte", mail.text_part.body.encoded
    assert_match "Debe ser DNI, NIE o pasaporte", mail.html_part.body.encoded
  end
end

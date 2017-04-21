require 'test_helper'

require 'tasks/encomu/confirmation_extensions'

class MicrosoftConfirmationsTest < ActiveSupport::TestCase
  setup { User.include(ConfirmationExtensions) }

  test ".microsoft" do
    emails = %w(
      example@outlook.es
      peter@outlook.com
      peter@gmail.com
      peter@yahoo.fr
      more@live.com
      example@hotmail.es
      example@hotmail.com
    )

    emails.each { |email| FactoryGirl.create(:user, email: email) }

    assert_equal emails - %w(peter@gmail.com peter@yahoo.fr),
                 User.microsoft.pluck(:email)
  end

  test ".confirmation_sent_before" do
    FactoryGirl.create(:user, confirmation_sent_at: 2.hours.ago)
    user = FactoryGirl.create(:user, confirmation_sent_at: 4.hours.ago)

    assert_equal [user], User.confirmation_sent_before(3.hours.ago)
  end
end

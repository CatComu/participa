require 'test_helper'

class VerifiableTest < ActiveSupport::TestCase
  test "verification scopes" do
    create(:user, :banned)
    unverified = create(:user)
    confirmed_by_sms = create(:user, :confirmed_by_sms)
    not_confirmed_by_sms = create(:user, :not_confirmed_by_sms)
    verified_presentially = create(:user, :verified_presentially)
    verified_online = create(:user, :verified_online)
    verified_both_ways = create(:user, :verified_presentially, :verified_online)

    assert_matches_array \
      [verified_presentially, verified_online, verified_both_ways],
      User.verified

    assert_matches_array \
      [unverified, not_confirmed_by_sms, confirmed_by_sms],
      User.unverified

    assert_matches_array \
      [verified_presentially, verified_both_ways],
      User.verified_presentially

    assert_matches_array \
      [unverified, not_confirmed_by_sms, confirmed_by_sms, verified_online],
      User.unverified_presentially

    assert_matches_array \
      [verified_online, verified_both_ways],
      User.verified_online

    assert_matches_array \
      [unverified, not_confirmed_by_sms, confirmed_by_sms, verified_presentially],
      User.unverified_online

    assert_matches_array \
      [confirmed_by_sms, verified_presentially, verified_online, verified_both_ways],
      User.voting_right

    assert_matches_array [unverified, not_confirmed_by_sms], User.no_voting_right

    assert_matches_array [confirmed_by_sms], User.unverified_with_voting_right
  end

  test ".presential_verifier_ever gives past & present presential verifiers" do
    active_presential_verifier = create(:user,
                                        :verifying_presentially,
                                        starts_at: 1.day.ago,
                                        ends_at: 1.day.from_now)

    create(:user, :verifying_online, starts_at: 1.day.ago, ends_at: 1.day.from_now)

    inactive_presential_verifier = create(:user,
                                          :verifying_presentially,
                                          starts_at: 2.days.ago,
                                          ends_at: 1.day.ago)

    assert_equal \
      [active_presential_verifier, inactive_presential_verifier].sort,
      User.presential_verifier_ever.sort
  end

  test "#verifying presentially?" do
    user = create(:user, :verifying_presentially, starts_at: 1.day.ago,
                                                  ends_at: 1.day.from_now)
    assert_equal true, user.verifying_presentially?

    user = create(:user, :verifying_presentially, starts_at: 2.days.ago,
                                                  ends_at: 1.day.ago)
    assert_equal false, user.verifying_presentially?

    user = create(:user, :verifying_presentially, starts_at: 1.day.from_now,
                                                  ends_at: 2.days.from_now)
    assert_equal false, user.verifying_presentially?
  end

  test "online verification process status" do
    with_verifications(online: true) do
      confirmed_by_sms_only = create(:user, :confirmed_by_sms)
      assert_equal false, confirmed_by_sms_only.pending_docs?
      assert_equal false, confirmed_by_sms_only.pending_moderation?

      ready_for_review = create(:user, :pending_moderation)
      assert_equal false, ready_for_review.pending_docs?
      assert_equal true, ready_for_review.pending_moderation?

      pending_doc_reupload = create(:user, :pending_docs)
      assert_equal true, pending_doc_reupload.pending_docs?
      assert_equal false, pending_doc_reupload.pending_moderation?
    end
  end

  test "#verifying_online?" do
    user = create(:user, :verifying_online, starts_at: 1.day.ago,
                                            ends_at: 1.day.from_now)
    assert_equal true, user.verifying_online?

    user = create(:user, :verifying_online, starts_at: 2.days.ago,
                                            ends_at: 1.day.ago)
    assert_equal false, user.verifying_online?

    user = create(:user, :verifying_online, starts_at: 1.day.from_now,
                                            ends_at: 2.days.from_now)
    assert_equal false, user.verifying_online?
  end

  test "#is_verified? when no verifications enabled" do
    check_verifications(presential: false, online: false)
  end

  test "#is_verified? when only presential verifications enabled" do
    check_verifications(presential: true, online: false)
  end

  test "#is_verified? when only online verifications enabled" do
    check_verifications(presential: false, online: true)
  end

  test "#is_verified? when presential & online verifications enabled" do
    check_verifications(presential: true, online: true)
  end

  test "#voting_right? when no verifications enabled" do
    check_voting_right(presential: false, online: false)
  end

  test "#voting_right? when only presential verifications enabled" do
    check_voting_right(presential: true, online: false)
  end

  test "#voting_right? when only online verifications enabled" do
    check_voting_right(presential: false, online: true)
  end

  test "#voting_right? when presential & online verifications enabled" do
    check_voting_right(presential: true, online: true)
  end

  private

  def check_voting_right(presential:, online:)
    with_verifications(presential: presential, online: online) do
      voting_right_expectations(presential, online).each do |state, expectation|
        msg = <<~MSG
          Expected a user with flags #{state} to #{expectation ? '' : 'not'}
          have voting right.
        MSG

        assert_equal expectation, create(:user, *state).voting_right?, msg
      end
    end
  end

  def check_verifications(presential:, online:)
    with_verifications(presential: presential, online: online) do
      verification_expectations(presential, online).each do |state, expectation|
        msg = <<~MSG
          Expected a user with flags #{state} to #{expectation ? '' : 'not'}
          be considered verified.
        MSG

        assert_equal expectation, create(:user, *state).is_verified?, msg
      end
    end
  end

  def voting_right_expectations(presential, online)
    {
      %i(not_banned not_verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(not_banned not_verified_online not_confirmed_by_sms verified_presentially) => presential,
      %i(not_banned not_verified_online confirmed_by_sms not_verified_presentially) => online,
      %i(not_banned not_verified_online confirmed_by_sms verified_presentially) => presential || online,
      %i(not_banned verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(not_banned verified_online not_confirmed_by_sms verified_presentially) => presential,
      %i(not_banned verified_online confirmed_by_sms not_verified_presentially) => online,
      %i(not_banned verified_online confirmed_by_sms verified_presentially) => presential || online,
      %i(banned not_verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(banned not_verified_online not_confirmed_by_sms verified_presentially) => false,
      %i(banned not_verified_online confirmed_by_sms not_verified_presentially) => false,
      %i(banned not_verified_online confirmed_by_sms verified_presentially) => false,
      %i(banned verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(banned verified_online not_confirmed_by_sms verified_presentially) => false,
      %i(banned verified_online confirmed_by_sms not_verified_presentially) => false,
      %i(banned verified_online confirmed_by_sms verified_presentially) => false
    }
  end

  def verification_expectations(presential, online)
    {
      %i(not_banned not_verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(not_banned not_verified_online not_confirmed_by_sms verified_presentially) => presential,
      %i(not_banned not_verified_online confirmed_by_sms not_verified_presentially) => false,
      %i(not_banned not_verified_online confirmed_by_sms verified_presentially) => presential,
      %i(not_banned verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(not_banned verified_online not_confirmed_by_sms verified_presentially) => presential,
      %i(not_banned verified_online confirmed_by_sms not_verified_presentially) => online,
      %i(not_banned verified_online confirmed_by_sms verified_presentially) => presential || online,
      %i(banned not_verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(banned not_verified_online not_confirmed_by_sms verified_presentially) => false,
      %i(banned not_verified_online confirmed_by_sms not_verified_presentially) => false,
      %i(banned not_verified_online confirmed_by_sms verified_presentially) => false,
      %i(banned verified_online not_confirmed_by_sms not_verified_presentially) => false,
      %i(banned verified_online not_confirmed_by_sms verified_presentially) => false,
      %i(banned verified_online confirmed_by_sms not_verified_presentially) => false,
      %i(banned verified_online confirmed_by_sms verified_presentially) => false
    }
  end
end

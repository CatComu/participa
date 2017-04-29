require 'test_helper'

class VerificationSlotTest < ActiveSupport::TestCase
  test "validates presence of start time" do
    assert_equal false, build(:verification_slot, starts_at: nil).valid?
  end

  test "validates presence of end time" do
    assert_equal false, build(:verification_slot, ends_at: nil).valid?
  end

  test "validates correctness of time interval" do
    starts_at = Time.zone.now + 1.day
    ends_at = Time.zone.now
    verification_slot = build(:verification_slot, starts_at: starts_at,
                                                  ends_at: ends_at)

    assert_equal false, verification_slot.valid?
  end
end

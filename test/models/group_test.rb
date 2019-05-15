require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'use validations' do
    group = build(:group, name: nil)
    refute group.valid?
    fields = %i(name)
    fields.each do |type|
      assert_includes group.errors[type], I18n.t("errors.messages.blank")
    end
  end

  test 'optional - required fields' do
    group = build(:group, has_location: true, location_type: nil)
    refute group.valid?
  end
end

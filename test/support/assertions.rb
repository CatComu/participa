require 'minitest/assertions'

module Minitest
  module Assertions
    #
    #  Fails unless +expected+ and +actual+ have the same items.
    #
    def assert_matches_array(expected, actual)
      assert actual.is_a?(Enumerable), invalid_type_message(actual)
      assert expected.is_a?(Enumerable), invalid_type_message(expected)

      assert_equal expected.sort, actual.sort
    end

    private

    def invalid_type_message(object)
      <<~EOM.squish
        Expected #{object} of class #{object.class} to be an Enumerable, but
        it's not
      EOM
    end
  end
end


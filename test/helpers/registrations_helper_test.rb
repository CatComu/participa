require 'test_helper'

#
# Tests countries, provinces & regions through Carmen
#
class RegistrationsHelperTest < ActionView::TestCase
  test "get_countries gets us all countries" do
    assert_equal 249, get_countries.size
  end

  test "get_provinces gets all provinces for specific countries" do
    assert_equal 52, get_provinces("ES").size
  end

  test "get catalonia provinces only if Spain and a specific flag given" do
    provinces = get_provinces("ES", true)

    assert_equal 4, provinces.size
    assert_equal true, provinces.any? { |p| p.name == 'Barcelona' }
    assert_equal true, provinces.any? { |p| p.name == 'Tarragona' }
    assert_equal true, provinces.any? { |p| p.name == 'Lleida' }
    assert_equal true, provinces.any? { |p| p.name == 'Girona' }
  end

  test "get catalonia provinces flag does not affect other countries" do
    provinces = get_provinces("US", true)

    assert_equal 57, provinces.size
  end

  test "get_towns gets towns for a specific province" do
    barna_towns = get_towns("ES", "B").map(&:name)

    assert_includes barna_towns, "Barcelona"
    assert_includes barna_towns, "Terrassa"
    assert_includes barna_towns, "Sabadell"
  end
end

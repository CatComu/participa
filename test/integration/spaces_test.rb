require 'test_helper'
require 'integration/concerns/login_helpers'

class SpacesTest < ActionDispatch::IntegrationTest
  include Participa::Test::LoginHelpers

  test "download census" do
    user = create(:user)
    position = create(:position, :downloader)
    user.positions << position
    catalan_town = create(:catalan_town, vegueria_code: position.territory.code)
    create_list(:user, 10, country: "ES", town: catalan_town.code, province: "B", postal_code: "08001")

    login user
    visit spaces_path
    assert_content position.territory.name
    assert_content position.name
    click_link "Descargar"
    csv = CSV.parse(page.body, headers: true)
    assert csv
    assert_equal 10, csv.size
  end
end

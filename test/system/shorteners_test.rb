require "application_system_test_case"

class ShortenersTest < ApplicationSystemTestCase
  setup do
    @shortener = shorteners(:one)
  end

  test "visiting the index" do
    visit shorteners_url
    assert_selector "h1", text: "Shorteners"
  end

  test "creating a Shortener" do
    visit shorteners_url
    click_on "New Shortener"

    click_on "Create Shortener"

    assert_text "Shortener was successfully created"
    click_on "Back"
  end

  test "updating a Shortener" do
    visit shorteners_url
    click_on "Edit", match: :first

    click_on "Update Shortener"

    assert_text "Shortener was successfully updated"
    click_on "Back"
  end

  test "destroying a Shortener" do
    visit shorteners_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Shortener was successfully destroyed"
  end
end

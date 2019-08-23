require 'test_helper'

class ShortenersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shortener = shortenedurls(:one)
  end

  # confirm the new controller loads correctly
  test "should get new" do
    get new_shortener_url
    assert_response :success
  end
  # confirm the create controller loads correctly
  test "should create shortener" do
    assert_difference('Shortenedurl.count') do
      post shortener_index_url, params: { shortener: { longurl: 'www.house.gov' } }
    end
    assert_response 200
  end
  # confirm the show controller loads correctly
  test "should show shortener" do
    get shortener_url(@shortener)
    assert_response :success
  end
  # confirm the show controller correctly redirects to the long url
  test "should redirect to long url" do
    get shortener_url(id: 'abc')
    assert_redirected_to 'http://www.google.com'
  end

  # confirm an invalid short url correctly returns an error message
  test "invalid short url" do
    get shortener_url(id: 'rrr')
    assert'that is not a valid short url'
  end
  # confirm a fake long url returns an error
  test "fake long should return error" do
    post shortener_index_url, as: :json, params: { shortener: { longurl: 'house' } }
    json = JSON.parse(response.body)
      #response = response.as_json
    assert(json['shortenedValue']['error'], 'The url you entered is not a valid url.')
  end
  # confirm a bad long url returns an error
  test "bad long should return error" do
    post shortener_index_url, as: :json, params: { shortener: { longurl: 'thereisnoway.thisisa.urlthatisreal.edu' } }
    json = JSON.parse(response.body)
    #response = response.as_json
    assert(json['shortenedValue']['error'], 'The url you entered is not a valid url.')
  end
end

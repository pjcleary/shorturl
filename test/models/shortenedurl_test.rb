require 'test_helper'

class ShortenedurlTest < ActiveSupport::TestCase
  # check that a long url can be correctly queried
  test "get short url" do
    shortUrl = 'abc'
    longUrlData = Shortenedurl.where(shorturlpath: shortUrl).take
    assert_equal 'www.google.com', longUrlData.longurl
  end
  # check that a short url does not return the incorrect long url
  test "get short url fail" do
    shortUrl = 'xyz'
    longUrlData = Shortenedurl.where(shorturlpath: shortUrl).take
    assert_not_equal 'www.google.com', longUrlData.longurl
  end
  # test that we can do a find or create using only the long url
  # ensures there are no restrictions added that make other fields required
  test "enter long url" do
    longUrl = 'www.gmail.com'
    assert Shortenedurl.find_or_create_by(longurl: longUrl)
  end
end

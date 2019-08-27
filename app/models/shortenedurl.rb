require 'net/http'
require 'uri'
require 'twilio-ruby'
require 'url_utility'
require 'message_utility'
class Shortenedurl < ApplicationRecord
  @smsNumber = ''
  @longUrl = ''
  @shortUrl = ''
  @smsResponse = ''
  # set the longurl, which will be used in method below
  def self.setLongUrl(longUrl)
    @longUrl = longUrl
  end
  # set the sms number, which will be used in method below
  def self.setSmsNumber(smsNumber)
    #keep only digits from the number
    @smsNumber = smsNumber.tr('^0-9', '')
  end
  # get the short url value
  def self.getShortUrl()
    @shortUrl
  end
  # get the sms response value
  def self.getSmsResponse()
    @smsResponse
  end

  #shorten the url provided by the user
  def self.shortenUrl()
    # remove an http or https prefix if provided by user
    @longUrl = UrlUtility.removeHttp(@longUrl)
    # first, check to make sure the user entered a valid url
    if (UrlUtility.checkIfUrl(@longUrl))
      # check to see if the url is already in the database
      # if it is, retrieve it
      # if it is not, enter it
      checkUrlEntry = Shortenedurl.find_or_create_by(longurl: @longUrl)
      # if the query found that the url is already in the database, just return the short url that was already generated
      if (checkUrlEntry.shorturlpath)
        # set the short url value retrieved by the find or create query
        @shortUrl = checkUrlEntry.shorturlpath
        # prepend the SHORTURLBASE env variable, which is the first part of the url
        @shortUrl.prepend(ENV["SHORTURLBASE"])
      else
        # if the short url is not already in database, create it
        # bijective encode the id of the database entry
        # the bijectiveEncode method has more details on this encoding
        @shortUrl = UrlUtility.bijectiveEncode(checkUrlEntry.id)
        # update the database entry with the short url
        checkUrlEntry.shorturlpath = @shortUrl #set the value of the short url
        checkUrlEntry.save # save to the database
        # prepend the SHORTURLBASE env variable, which is the first part of the url
        @shortUrl.prepend(ENV["SHORTURLBASE"])
      end
      #send an SMS if we have a 10 digit number
      if (@smsNumber.length == 10)
        @smsResponse = MessageUtility.sendSms(@smsNumber, @shortUrl)
      end
    else
      # if the user did not enter a valid url, return an error
      @shortUrl = Hash.new
      @shortUrl['error'] = "The url you entered is not a valid url."
    end
  end
end

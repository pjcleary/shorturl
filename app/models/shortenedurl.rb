require 'net/http'
require 'uri'
require 'twilio-ruby'
class Shortenedurl < ApplicationRecord
  @smsNumber = ''
  @longUrl = ''
  # set the longurl, which will be used in methods below
  def self.setLongUrl(longUrl)
    @longUrl = longUrl
  end
  # set the sms number, which will be used in methods below
  def self.setSmsNumber(smsNumber)
    #keep only digits from the number
    @smsNumber = smsNumber.tr('^0-9', '')
  end
  #shorten the url provided by the user
  def self.shortenUrl()
    # remove an http or https prefix if provided by user
    self.removeHttp
    # check to see if the url is already in the database
    # if it is, retrieve it
    # if it is not, enter it
    checkUrlEntry = Shortenedurl.find_or_create_by(longurl: @longUrl)
    # if the query found that the url is already in the database, just return the short url that was already generated
    if (checkUrlEntry.shorturlpath)
      # get the short url value retrieved by the find or create query
      returnValue = checkUrlEntry.shorturlpath # if there already is an entry, just return the short url
      # prepend the SHORTURLBASE env variable, which is the first part of the url
      returnValue.prepend(ENV["SHORTURLBASE"])
    else
      #if the long url is not already stored in the database, create a new short url
      # first, check to make sure the user entered a valid url
      if (self.checkIfUrl)
        # bijective encode the id of the database entry
        # the bijectiveEncode method has more details on this encoding
        shortUrl = self.bijectiveEncode(checkUrlEntry.id)
        # update the database entry with the short url
        checkUrlEntry.shorturlpath = shortUrl #set the value of the short url
        checkUrlEntry.save # save to the database
        returnValue = shortUrl
        # prepend the SHORTURLBASE env variable, which is the first part of the url
        returnValue.prepend(ENV["SHORTURLBASE"])
      else
        # if the user did not enter a valid url, return an error
        returnValue = Hash.new
        returnValue['error'] = "The url you entered is not a valid url."
      end
    end
    #send an SMS if we have a 10 digit number
    if (@smsNumber.length == 10)
      self.sendShortUrl(returnValue)
    end
    returnValue
  end

  # remove the https or http prefix, if entered by the user
  def self.removeHttp()
    # first check to make sure the user provided a long url
    if (@longUrl)
      # check if the beginning of the string is https://
      if (@longUrl.index('https://') == 0)
        # remove the https:// if necessary
        @longUrl.sub!('https://', '')
      # check if the beginning of the string is http://
      elsif (@longUrl.index('http://') == 0)
        # remove the http:// if necessary
        @longUrl.sub!('http://', '')
      end
    end
  end

  # check if the user entered a valid url
  def self.checkIfUrl()
    # start with the assumption the url is not valid
    validUrl = false
    begin
      # parse the url
      url = URI.parse("http://" + @longUrl)
      # use the ruby functions to visit the url
      req = Net::HTTP.new(url.host, url.port)
      path = url.path if url.path.present?
      res = req.request_head(path || '/')
      # as long the url does not return a 404 code, consider it to be valid
      if (res.code != "404")
        validUrl = true
      end
    rescue
      # currently, the function returns false if the code to visit the url fails
      # a future update can log the error to track what users are entering instead of valid urls
      # TODO - log error
    end
    validUrl
  end

  # Base 62 encode the input value
  # this is referred to as bijective encoding
  # based on https://medium.com/@harpermaddox/how-to-build-a-custom-url-shortener-5e8b454c58ae
  # and https://gist.github.com/zumbojo/1073996
  # with modifications
  # using a Base 62 string is much more efficient than using a Base 10 number
  # since encoding allows for a much shorter string
  # and Base 62 avoids using special characters that may not be work in a url
  #
  def self.bijectiveEncode(inputNumber)
    # set the string of characters available for Base 62 encoding
    # this will create a short url that uses only alphanumeric characters
    base62Characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    # if the input is 0, just return the first of the Base 62 characters
    # otherwise, the function would return an empty string for an input of 0
    if inputNumber == 0
      shortCode = base62Characters[0]
    else
      #set a variable for the short code
      shortCode = ''
      # get the length of the base characters available
      base = base62Characters.length
      # do this as long as the inputNumber is 0
      while inputNumber > 0
        #prepend the short code with Base 62 character at the position of the modulus of the
        # current value of the input number and the base
        shortCode.prepend(base62Characters[inputNumber % base])
        # get a new value for the input value by dividing the current number of the input value by the base
        # and rounding down
        inputNumber = (inputNumber / base).floor
      end
    end
    shortCode
  end
  # end part based on web links
  #
  # NOTE - This app does not decode the Base 62 string
  # Rather than using computational power to decode and then query by the ID in the table,
  # the app stores the Base 62 string and queries that to get the long url for a redirect

  # send an SMS to the user if they requested one
      # code is modified from Twilio example snippet
  def self.sendShortUrl(shortUrl)
    #set the Twilio credentials and from number
    account_sid = ENV["TWILIO_SID"]
    auth_token = ENV["TWILIO_TOKEN"]
    from = ENV["TWILIO_NUMBER"] # Your Twilio number
    # create a twilio client
    client = Twilio::REST::Client.new(account_sid, auth_token)

    # set the number the message will go to
    to = '+1' + @smsNumber
    begin
      # send the message
      client.messages.create(
          from: from,
          to: to,
          body: shortUrl
      )
      returnValue = 'success'
    rescue
      # return a generic error if send fails
      # this can be made more specific in a future version
      returnValue = 'there was an error sending the sms'
    end
    returnValue
  end

end

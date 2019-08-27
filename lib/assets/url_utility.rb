module UrlUtility
  # remove the https or http prefix, if entered by the user
  def self.removeHttp(longUrl)
    # first check to make sure the user provided a long url
    if (longUrl)
      # check if the beginning of the string is https://
      if (longUrl.index('https://') == 0)
        # remove the https:// if necessary
        longUrl.sub!('https://', '')
        # check if the beginning of the string is http://
      elsif (longUrl.index('http://') == 0)
        # remove the http:// if necessary
        longUrl.sub!('http://', '')
      end
    end
    longUrl
  end

  # check if the user entered a valid url
  def self.checkIfUrl(longUrl)
    # start with the assumption the url is not valid
    validUrl = false
    begin
      # parse the url
      url = URI.parse("http://" + longUrl)
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
  # based on information from https://medium.com/@harpermaddox/how-to-build-a-custom-url-shortener-5e8b454c58ae
  # and https://gist.github.com/zumbojo/1073996
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
      while inputNumber > 0
        # prepend the short code with Base 62 character at the position of the modulus of the
        # current value of the input number and the base
        shortCode.prepend(base62Characters[inputNumber % base])
        # get a new value for the input value by dividing the current number of the input value by the base
        # and rounding down
        inputNumber = (inputNumber / base).floor
      end
    end
    shortCode
  end
  #
  # NOTE - This app does not decode the Base 62 string
  # Rather than using computational power to decode and then query by the ID in the table,
  # the app stores the Base 62 string and queries that to get the long url for a redirect

end
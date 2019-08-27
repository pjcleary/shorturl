class ShortenerController < ApplicationController
  # this setting allows for cross-resource sharing to open up the web service for creating a short url
  # if we want to increase security, we could allow users to obtain short urls via only the web app
  # or require users to register and allow requests from only registered sources
  protect_from_forgery :except => :create
  # if a user goes to / send them to the page to create a new url
  def index
    render 'new'
  end
  def new
    #this displays the new view
  end

  # a get request - handled by show - will redirect the user to the long url
  def show
    begin
      # query the table to get the long url based on the value in the short url
      longUrlData = Shortenedurl.where(shorturlpath: params[:id]).take
      # add http to the front of the long url
      # use http rather than https since some legacy sites are still using http
      # https sites will typically redirect from http
      longUrl = "http://" + longUrlData.longurl
      redirect_to longUrl
    rescue
      @displayMessage = "that is not a valid short url"
    end
  end
  #make a new short url
  def create
    # create a hash to store key value pairs
    @displayData = Hash.new
    # check how the data is being posted
    # if the user posted from the Ruby on Rails form, the data will include the "shortener" param
    if (params[:shortener])
      longUrl = params[:shortener][:longUrl]
      smsNumber = params[:shortener][:smsNumber]
    # if the user posted directly to the API, they will use the longurl param only
    # this makes the API easier to use
    else
      longUrl = params[:longUrl]
      smsNumber = params[:smsNumber]
    end
    # set the long url
    Shortenedurl.setLongUrl(longUrl)
    # set the SMS number, if provided
    if (smsNumber)
      Shortenedurl.setSmsNumber(smsNumber)
    end
    # add the long url to the hash
    @displayData['longUrl'] = longUrl
    # create/get the short url and add it to the hash
    Shortenedurl.shortenUrl()
    @displayData['shortenedValue'] = Shortenedurl.getShortUrl
    @displayData['smsResponse'] = Shortenedurl.getSmsResponse
    # check whether the user is expecting the response in html or json
    respond_to do |format|
      format.html {
        # if they are expecting html show the create view
        # unless there is an error, then return to the new view and provide the error to display
        if @displayData['shortenedValue']['error']
          render 'new'
        end
      }
      # if they user is expecting json, return the hash as json
      format.json { render json: @displayData }
    end
  end
end
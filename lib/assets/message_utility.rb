module MessageUtility

  # send an SMS to the user if they requested one
  # code is modified from Twilio example snippet
  def self.sendSms(smsNumber, messageToSend)
    smsResponse = ''
    #set the Twilio credentials and from number
    account_sid = ENV["TWILIO_SID"]
    auth_token = ENV["TWILIO_TOKEN"]
    from = ENV["TWILIO_NUMBER"] # Your Twilio number
    # create a twilio client
    client = Twilio::REST::Client.new(account_sid, auth_token)

    # set the number the message will go to
    to = '+1' + smsNumber
    begin
      # send the message
      client.messages.create(
          from: from,
          to: to,
          body: messageToSend
      )
      smsResponse = 'success'
    rescue
      # return a generic error if send fails
      # this can be made more specific and logged in a future version
      smsResponse = 'there was an error sending the sms'
    end
    smsResponse
  end
end
class ApplicationController < ActionController::Base
  def show
    render 'shortener/show'
  end
end

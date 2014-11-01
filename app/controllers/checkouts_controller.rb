class CheckoutsController < ApplicationController

  def index
    @username = 'Username'
  end

  def create
    render 'checkouts/show'
    if session[:bought] == nil
      session[:bought] = session[:in_cart]
    else
      session[:in_cart].each  do |element|
        session[:bought].push(element)
      end
    end
    session[:in_cart] = nil
  end

end

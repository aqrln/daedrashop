class CheckoutsController < ApplicationController

  def index
    @username = 'Username'
  end

  def create
    render 'checkouts/show'
    session[:bought] = session[:in_cart]
    session[:in_cart] = nil
  end

end

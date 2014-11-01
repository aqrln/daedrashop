class CheckoutsController < ApplicationController

  def index
    @username = 'Username'
  end

  def create
    render 'checkouts/show'
    if session[:bought] == nil
      session[:bought] = session[:in_cart]
      session[:buy_prev] = session[:bought]
    else
      session[:in_cart].each  do |element|
        session[:bought].push(element)
      end
    end

    @products = Product.all
    @graphs = Graph.all
    buy_with(@products, @graphs)

    session[:in_cart] = nil
  end

  def buy_with(products, graphs)
    if session[:buy_prev].length != session[:bought].length and session[:buy_prev] != nil


      session[:buy_prev] = session[:bought]
    elsif session[:buy_prev] == nil
      session[:buy_prev] = session[:bought]
    end
  end

end

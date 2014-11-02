class CartsController < ApplicationController

  def index
    @sum = 0
    @products = Product.all
    @amount = Array.new(@products.length) { 0 }
    GetAmount()
  end

  def GetAmount
    if session[:in_cart] != nil
      @products.each do |product|
        session[:in_cart].each do |element|
          if product.id == element
            @amount[product.id - 1] += 1
          end
        end
      end
    end
  end

  def show
    session[:in_cart] = nil
    session[:total] = 0
    redirect_to products_path
  end

end

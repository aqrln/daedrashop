class ProductsController < ApplicationController

  #TODO: Rewrite index(find better way)
  def index
    @products = Product.all

    if session[:bought] != nil
      @bought = Array.new(session[:bought].length) { 0 }
      session[:bought].each do |element|
        if element == @products[element - 1].id
          @bought[element - 1] = element
        end
      end
    end

    if session[:in_cart] != nil
      @cart = Array.new(session[:in_cart].length) { 0 }
      session[:in_cart].each do |element|
        if element == @products[element - 1].id
          @cart[element - 1] = element
        end
      end
    end

    if session[:bought] != nil and session[:in_cart] != nil
      @view = Array.new(@products.length - @bought.length - @cart.length) { 0 }
      @products.each do |product|
        if @bought[product.id - 1] != product.id and product.id != @cart[product.id - 1]
          @view[product.id - 1] = product.id
        end
      end
    elsif session[:bought] != nil and session[:in_cart] == nil
      @view = Array.new(@products.length - @bought.length) { 0 }
      @products.each do |product|
        if @bought[product.id - 1] != product.id
          @view[product.id - 1] = product.id
        end
      end
    elsif session[:in_cart] != nil and session[:bought] == nil
      @view = Array.new(@products.length - @cart.length) { 0 }
      @products.each do |product|
        if product.id != @cart[product.id - 1]
          @view[product.id - 1] = product.id
        end
      end
    else
      @view = Array.new(@products.length) { 0 }
      @products.each do |product|
        @view[product.id - 1] = product.id
      end
    end

  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(params[:product])

    if @product.save
      redirect_to @product
    else
      render new_product_path
    end
  end

  def show
    @product = Product.find(params[:id])

    if session[:in_cart] != nil
      session[:in_cart].each do |element|
        if element == @product.id
          @remove = true
          break
        else
          @remove = false
        end
      end
    end

    @product.views += 1
    @product.update_attribute(:views, @product.views)
  end

  def clear
    #TODO: Remove from cart
    session[:in_cart].delete_at(0)
    redirect_to products_path
  end

  def edit
    @product = Product.find(params[:id])
    (session[:in_cart] ||= []) << @product.id
    redirect_to products_path
  end

end

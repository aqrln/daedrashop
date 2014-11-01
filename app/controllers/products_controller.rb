class ProductsController < ApplicationController

  def index
    @products = Product.all

    @buy_list = SetupArray(:bought, @products)
    @cart = SetupArray(:in_cart, @products)

    if session[:bought] != nil and session[:in_cart] != nil
      @view = Array.new(@products.length - @cart.length) { 0 }
      @products.each do |product|
        if @buy_list[product.id - 1] != product.id and product.id != @cart[product.id - 1]
          @view[product.id - 1] = product.id
        end
      end
    elsif session[:bought] != nil and session[:in_cart] == nil
      @view = Array.new(@products.length - @buy_list.length) { 0 }
      @products.each do |product|
        if @buy_list[product.id - 1] != product.id
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

  def SetupArray(params, products)
    if session[params] != nil
      array = Array.new(session[params].length) { 0 }
      session[params].each do |element|
        if element == products[element - 1].id
          array[element - 1] = element
        end
      end
    end
    return array
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

    @bought = CheckListType(:bought, @product)
    @remove = CheckListType(:in_cart, @product)

    @product.views += 1
    @product.update_attribute(:views, @product.views)
  end

  def CheckListType(params, product)
    my_bool = false
    if session[params] != nil
      session[params].each do |element|
        if element == product.id
          my_bool = true
          break
        end
      end
    end
    return my_bool
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

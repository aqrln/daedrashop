class ProductsController < ApplicationController

  require 'graph_manager'

  def index
    @products = Product.all

    #session.clear

    @buy_list = setup_array(:bought, @products)
    @cart = setup_array(:in_cart, @products)

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

  def setup_array(params, products)
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
      @graphManager = GraphManager.new
      @graphManager.graph_create()
      redirect_to @product
    else
      render new_product_path
    end
  end

  def show
    @product = Product.find(params[:id])
    session[:current_id] = @product.id

    #view_session(@product)
    #graph_update(:view_session, @product)
    graph_update(:in_cart, @product)

    cart_graph = Graph.find_all_by_first_product(@product.id)
    cart_graph.sort_by! { |element| element.cart_with }
    cart_graph.reverse!

    in_cart_ten = Array.new(10)
    (0..9).each do |i|
      in_cart_ten[i] = (cart_graph[i])
    end

    @in_cart = Array.new(4)
    @newR = 0
    @prevR = Random.rand(9)
    4.times do |i|
      random_stuff()
      @in_cart[i] = in_cart_ten[@newR]
    end

    @bought = check_list_type(:bought, @product)
    @remove = check_list_type(:in_cart, @product)

    @product.views += 1
    @product.update_attribute(:views, @product.views)
  end

  def random_stuff
    @newR = Random.rand(9)
    if @newR == @prevR
      random_stuff()
    else
      @prevR = @newR
    end
  end

  def view_session(product)
    update_view = true
    if not session[:view_session].nil?
      session[:view_session].each do |element|
        if element == product.id
          update_view = false
          break
        end
      end
    end
    (session[:view_session] ||= []) << product.id if update_view
  end

  def graph_update(param, product)
    @graphManager = GraphManager.new
    if session[param] != nil and session[param].length > 1
      session[param].each do |element|
        if element == product.id
          session[param].each do |first|
            session[param].each do |second|
              if first != second
                if param == :in_cart
                  @graphManager.update_cart_graph(first, second)
                elsif param == :view_session
                  @graphManager.update_view_graph(first, second)
                end
              end
            end
          end
          break
        end
      end
    end
  end

  def check_list_type(params, product)
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

  def remove
    array = Array.new
    session[:in_cart].each do |element|
      if element != session[:current_id]
        array.push(element)
      end
    end
    session[:in_cart] = nil
    session[:in_cart] = array
    redirect_to products_path
  end

  def edit
    @product = Product.find(params[:id])
    (session[:in_cart] ||= []) << @product.id
    if session[:total] == nil
      session[:total] = 0
    end
    session[:total] = @product.price + session[:total]
    redirect_to products_path
  end

end

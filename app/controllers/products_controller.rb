class ProductsController < ApplicationController

  def index
    @products = Product.all

    #session.clear

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
      GraphCreate()
      redirect_to @product
    else
      render new_product_path
    end
  end

  def GraphCreate
    Product.all.each do |product_first|
      Product.all.each do |product_second|
        if product_first.id != product_second.id
          if not Graph.where(:first_product => product_first.id, :second_product => product_second.id).exists?
            @graph = Graph.create(:first_product => product_first.id, :second_product => product_second.id,
                                  :buy_with => 0, :view_with => 0, :cart_with => 0)
          end
        end
      end
    end
  end

  def UpdateCartGraph(first, second)
    graph = Graph.where(:first_product => first, :second_product => second)
    if not graph.exists?
      GraphCreate()
      CartWithUpdate(Product.find(first))
    else
      myGraph = Graph.find(graph)
      myGraph.update_attribute(:cart_with, myGraph.cart_with + 1)
    end
  end

  def UpdateViewGraph(first, second)
    graph = Graph.where(:first_product => first, :second_product => second)
    if not graph.exists?
      GraphCreate()
      ViewWithUpdate(Product.find(first))
    else
      myGraph = Graph.find(graph)
      myGraph.update_attribute(:view_with, myGraph.view_with + 1)
    end
  end

  def show
    @product = Product.find(params[:id])

    ViewWithUpdate(@product)
    CartWithUpdate(@product)

    @bought = CheckListType(:bought, @product)
    @remove = CheckListType(:in_cart, @product)

    @product.views += 1
    @product.update_attribute(:views, @product.views)
  end

  def ViewSession(product)
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

  def ViewWithUpdate(product)
    ViewSession(product)
    if session[:view_session] != nil and session[:view_session].length > 1
      session[:view_session].each do |element|
        if element != product.id
          UpdateViewGraph(product.id, element)
          UpdateViewGraph(element, product.id)
        end
      end
    end
  end

  def CartWithUpdate(product)
    if session[:in_cart] != nil and session[:in_cart].length > 1
      session[:in_cart].each do |element|
        if element != product.id
          UpdateCartGraph(product.id, element)
          UpdateCartGraph(element, product.id)
        end
      end
    end
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

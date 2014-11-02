class CheckoutsController < ApplicationController

  require 'graph_manager'

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
    session[:buy_with] = nil
    session[:buy_with] = session[:in_cart]
    session[:in_cart] = nil

    graph_update()
  end

  def graph_update
    if session[:buy_with] != nil and session[:buy_with].length > 1
      session[:buy_with].each do |first|
        session[:buy_with].each do |second|
          if first != second
            update_buy_graph(first, second)
            end
          end
        end
      end
  end

  def update_buy_graph(first, second)
    @graphManager = GraphManager.new
    myGraph = @graphManager.get_graph(first, second)
    myGraph.update_attribute(:buy_with, myGraph.buy_with + 1)
  end

end

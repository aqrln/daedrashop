class GraphManager

  def graph_create
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

  def get_graph(first, second)
    graph = Graph.where(:first_product => first, :second_product => second)
    if not graph.exists?
      graph_create()
    else
      myGraph = Graph.find(graph)
      return myGraph
    end
  end

  def update_view_graph(first, second)
    myGraph = get_graph(first, second)
    myGraph.update_attribute(:view_with, myGraph.view_with + 1)
  end

  def update_cart_graph(first, second)
    myGraph = get_graph(first, second)
    myGraph.update_attribute(:cart_with, myGraph.cart_with + 1)
  end

end
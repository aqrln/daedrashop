class Graph < ActiveRecord::Base
  attr_accessible :buy_with, :cart_with, :first_product, :second_product, :view_with
end

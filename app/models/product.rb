class Product < ActiveRecord::Base
  attr_accessible :title, :views, :price, :description
end

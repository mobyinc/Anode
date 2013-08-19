class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :release_date, :created_at, :updated_at  
end

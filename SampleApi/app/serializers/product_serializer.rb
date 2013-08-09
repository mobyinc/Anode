class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :created_at, :updated_at, :secret_thing

  def secret_thing
  	"Hello there!" if current_user
  end
end

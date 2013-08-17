class Product < ActiveRecord::Base
	validates :name, presence: true
	validates :description, presence: true
	validates :price, presence: true, numericality: true
end

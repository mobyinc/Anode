class Api::V1::ProductsController < Api::V1::ApiController
	def show
		@product = ::Product.find(params[:id])
		render json: @product
	end
end

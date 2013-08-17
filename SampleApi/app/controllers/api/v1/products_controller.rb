class Api::V1::ProductsController < Api::V1::ApiController
	def show
		@product = ::Product.find(params[:id])
		render json: @product
	end

	def create
		@product = ::Product.new(product_params);		

		if @product.save
			render json: @product
		else			
			client_error "validation error"
		end
	end

private

	def product_params
		params.require(:product).permit(:name,
																 		:description,
																		:price)
	end

end

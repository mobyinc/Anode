class Api::V1::ProductsController < Api::V1::ApiController
	before_filter :find_product, only: [:show, :update, :destroy]

	def index
		@products = ::Product.all
		render json: @products
	end

	def show		
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

	def update
		if @product.update_attributes(product_params)
			render json: @product
		else
			client_error "validation error"
		end
	end

	def destroy
		@product.destroy
		render json: {}
	end

	def released_products

	end

private

	def find_product
		@product = ::Product.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		client_error "object not found"
	end

	def product_params
		params.require(:product).permit(:name,
																 		:description,
																		:price,
																		:release_date)
	end

end

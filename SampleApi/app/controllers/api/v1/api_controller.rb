class Api::V1::ApiController < ApplicationController	

	class ClientError < StandardError
		attr_accessor :message
		attr_accessor :code

		def initialize(message, code=400)
			self.message = message
			self.code = code
		end
	end

	protect_from_forgery with: :null_session, except: [:create, :update, :destroy, :query]

	rescue_from Exception, with: :exception_handler
	rescue_from ClientError, with: :client_error_handler

	before_filter :authorize
	serialization_scope :current_user

	def query
		model_name = controller_name.classify.constantize
		table_name = controller_name.downcase.pluralize		
		limit = params[:limit]
		skip = params[:skip]

		query = Arel::Table.new(table_name)

		if params[:predicate]
			left = params[:predicate][:left]
			right = params[:predicate][:right]
			op = params[:predicate][:operator]
			
			method = query[left].method(op)
			query = query.where(method.call(right))
		end

		query.take(limit)
		query.skip(skip)
		query.project('*')

		sql = query.to_sql
		objects = model_name.find_by_sql(sql)

		# TODO ACL

		render json: objects
	end

private

	def authorize
		return true # TODO: Remove

		authenticate_or_request_with_http_token do |token, options|
			api_key = ApiKey.find_by_access_token(token)
			
			if api_key
				@user = api_key.user
				return true
			else
				return false
			end
		end
	end

	def current_user
		@user
	end

	def client_error(message, code=400)
		raise ClientError.new(message, code)
	end

	def exception_handler(e)
		message = "unexpected error: #{e}"
		logger.error(message)
		render json: {error: {code: 500, message: message}}, status: :internal_server_error
		return false
	end

	def client_error_handler(e)
		logger.warn(e.message)
		render json: {error: {code: e.code, message: e.message}}, status: e.code
		return false
	end
end
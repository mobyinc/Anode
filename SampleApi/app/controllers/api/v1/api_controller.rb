class Api::V1::ApiController < ApplicationController	

	class ClientError < StandardError
		attr_accessor :message
		attr_accessor :code

		def initialize(message, code=400)
			self.message = message
			self.code = code
		end
	end

	protect_from_forgery with: :null_session, except: [:create, :update, :destroy]

	rescue_from Exception, with: :exception_handler
	rescue_from ClientError, with: :client_error_handler

	before_filter :authorize
	serialization_scope :current_user

private

	def authorize
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
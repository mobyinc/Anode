class Api::V1::ApiController < ApplicationController
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
end
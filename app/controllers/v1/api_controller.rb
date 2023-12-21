module V1
  class APIController < ApplicationController
    before_action :current_user

    private

      def current_user
        if !bearer_token.present?
          render json: { errors: ["No Bearer Token."] } and return
        end

        if !decoded_jwt[:success]
          render json: { errors: decoded_jwt[:errors] } and return
        end

        user_result = find_or_create_user(decoded_jwt[:account_id])
        if !user_result[:success]
          render json: { errors: user_result[:errors] } and return
        end

        return user_result[:data]
      end

      def find_or_create_user(account_id)
        @user_result ||= ::Kinde::Services::FindOrCreateUser.new({
          account_id: account_id,
        }).perform
      end

      def bearer_token
        @bearer_token ||= request.headers["Authorization"]&.match(/Bearer (.*)/)&.[](1)
      end

      def decoded_jwt
        @decoded_jwt ||= Kinde::DecodeJwt.new({ token: bearer_token }).perform
      end

      def current_user_scope
        decoded_jwt[:scope]
      end
  end
end
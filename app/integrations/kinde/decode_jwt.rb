# frozen_string_literal: true

module Kinde
  class DecodeJwt
    require 'jwt'
    require 'http'

    def initialize(params = {})
      @token = params[:token]
    end

    def perform
      validate_token(@token)
    end

    private

      def validate_token(token)
        jwks_request = get_jwks
    
        unless jwks_request.status.success?
          return { success: false, errors: ["Unable to verify credentials"] }
        end
    
        jwks_hash = JSON.parse(jwks_request.to_s, symbolize_names: true)
    
        decoded_tokens = decode_token(token, jwks_hash)
        decoded_token = decoded_tokens.first

        return {
          success: true,
          account_id: decoded_token&.dig("sub"),
          data: decoded_token,
          scope: decoded_token&.dig("scp"),
        }

      rescue JWT::VerificationError, JWT::DecodeError => e
        return { success: false, errors: ["Invalid Credentials"] }
      end

      def get_jwks
        HTTP.get("#{domain_url}/.well-known/jwks.json")
      end

      def domain_url
        Rails.application.credentials.dig(:kinde, :domain)
      end

      def decode_token(token, jwks_hash)
        JWT.decode(token, nil, true, {
          algorithm: 'RS256',
          iss: domain_url,
          verify_iss: true,
          aud: Rails.application.credentials.dig(:kinde, :audience),
          verify_aud: true,
          jwks: { keys: jwks_hash[:keys] }
        })
      end
  end
end
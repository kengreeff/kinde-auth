module Kinde
  module Services
    class FindOrCreateUser
      PROVIDER_KEY = "kinde"

      def initialize(params = {})
        @account_id = params[:account_id]
      end

      def perform
        user_result = find_or_create_user(@account_id)
        return user_result
      end

      private

        def find_or_create_user(account_id)
          # Existing User
          existing_user = User.joins(:user_accounts)
            .where(user_accounts: {
              provider: PROVIDER_KEY,
              provider_account_id: account_id,
            })
            .first
          return { success: true, data: existing_user } if existing_user

          # New User
          new_user = User.new(
            user_accounts_attributes: [{
              provider: PROVIDER_KEY,
              provider_account_id: account_id,
            }],
          )

          return { success: false, errors: new_user.errors.full_messages } if !new_user.save

          return { success: true, data: new_user }
        end
    end
  end
end
class UserAccount < ApplicationRecord
  belongs_to :user

  validates :provider, :provider_account_id, :user, presence: true
end
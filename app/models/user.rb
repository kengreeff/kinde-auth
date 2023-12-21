class User < ApplicationRecord
  has_many :user_accounts, dependent: :destroy

  accepts_nested_attributes_for :user_accounts
end
# frozen_string_literal: true

# UserSerializer
#
#   Used for the user data representation
#
class UserSerializer < ApplicationSerializer
  set_type :user

  attributes :email, :username, :admin, :locale,
             :settings, :timezone, :created_at, :updated_at

  #
  # just stub for the first time
  #
  attribute :avatar do |object|
    if object.avatar_data.nil?
      Users::Gravatar.call(email: object.email, size: 100, username: object.username)
    else
      object.avatar_url
    end
  end

  attribute :confirmed, &:confirmed?

  attribute :banned, &:banned?

  attribute :locked, &:access_locked?

  belongs_to :student, serializer: StudentSerializer

  has_one :status, serializer: UserStatusSerializer
end

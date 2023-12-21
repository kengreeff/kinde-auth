module V1
  class UsersController < APIController

    def me
      render json: { current_user: current_user }
    end

  end
end
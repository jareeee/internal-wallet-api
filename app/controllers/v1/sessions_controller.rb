module V1
  class SessionsController < ApplicationController
    # POST /v1/auth
    def create
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        expiration_time = 24.hours.from_now
        session[:user_id] = user.id
        render json: {
          data: {
            expiration_time: expiration_time.iso8601,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              team: nil,
              stocks: []
            }
          }
        }, status: :created
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    # DELETE /v1/auth
    def destroy
      session.delete(:user_id)
      render json: { message: "Logout successful" }
    end
  end
end

class Api::UsersController < ApplicationController

  respond_to :json

  def create
    

    user = User.new(user_params)

    if user.save
      render json: user, root: false, except: :id
    else
      head :bad_request
    end
  end

  def index
    users = User.all

    render json: users, except: :password
  end

  private

  def user_params
    params.permit(:username, :password)
  end

end
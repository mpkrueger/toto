class Api::ListsController < ApplicationController

  def create
    if List.find_by_name(list_params[:name])
      head :bad_request and return
    end

    list = List.new(list_params)
    user = User.find(params[:id])
    list.user_id = user.id

    if user.authenticate?(params[:password]) == false
      head :bad_request and return
    end

    if list.save
      render json: list
    end

  end

  def index
    user = User.find(params[:id])
    lists = user.lists

    if user.authenticate?(params[:password]) == false
      head :bad_request and return
    end

    render json: lists, only: [:name, :user_id]
  end

  private

  def list_params
    params.require(:list).permit(:name, :permissions, :user_id)
  end

end
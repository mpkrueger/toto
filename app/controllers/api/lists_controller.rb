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

  def update
    @list = List.find(list_params[:id])



    if @list.update_attributes(list_params) && List.permission_options.include?(@list.permissions)
      render json: @list
    else
      head :bad_request and return
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
    params.require(:list).permit(:id, :name, :permissions, :user_id)
  end

end
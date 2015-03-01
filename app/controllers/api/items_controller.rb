class Api::ItemsController < ApplicationController
  def create
    list = List.find(item_params[:list_id])
    item = Item.new(item_params)
    user = User.find(user_params[:id])

    if user.authenticate?(user_params[:password]) == false
      head :bad_request and return
    end

    if item.save
      render json: item
    end
  end

  def index
    list = List.find(params[:list_id])
    user = User.find(user_params[:id])
    items = list.items

    if user.authenticate?(user_params[:password]) == false
      head :bad_request and return
    end

    if user.can?(:view, list)
      render json: items, only: [:list_id, :description]
    else
      head :bad_request and return
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :username, :password)
  end

  def item_params
    params.require(:item).permit(:list_id, :description)
  end
end
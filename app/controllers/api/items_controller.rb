class Api::ItemsController < ApplicationController
  def create
    list = List.find(item_params[:list_id])
    item = Item.new(item_params)

    if item.save
      render json: item
    end
  end

  private

  def item_params
    params.require(:item).permit(:list_id, :description)
  end
end
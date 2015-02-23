require 'spec_helper'

describe Api::ItemsController do 
  before do
    @list = List.create(name: "Santa's List", user_id: 3)
  end

  describe "create" do
    context "with correct user's password" do

      it "takes an item name and creates it if it doesn't exit" do
        params = { item: { list_id: @list.id, description: "Toy truck" } }

        expect{ post :create, params }
          .to change{ Item.count }
          .by 1
      end
    end

    context "without correct user's password" do
      xit "returns an error"
    end
  end

  describe "index" do
    context "with correct user's password" do

      xit "returns all items associated with the list"
    end

    context "without correct user's password" do

      xit "returns an error"
    end

  end

end
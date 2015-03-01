require 'spec_helper'

describe Api::ItemsController do 
  before do
    @list = List.create(name: "Santa's List", user_id: 3)
    @user = User.create(username: "Santa", password: "rudolph")
  end

  describe "create" do
    context "with correct user's password" do

      it "takes an item name and creates it if it doesn't exit" do
        params = { user: { id: @user.id, 
                           username: @user.username,
                           password: @user.password }, 
                   item: { list_id: @list.id,
                           description: "Toy truck" } }

        expect{ post :create, params }
          .to change{ Item.count }
          .by 1
      end
    end

    context "without correct user's password" do

      it "returns an error" do
        params = { user: { id: @user.id,
                   username: @user.username, 
                   password: "wrong" }, 
                   item: { list_id: @list.id,
                           description: "doll" } }

        post :create, params
        expect(response.status).to eq 400
      end
    end
  end

  describe "index" do
    before do
      (1..3).each{ |n| Item.create( list_id: @list.id, description: "Robot#{n}") }
    end

    context "with correct user's password" do

      it "returns all items associated with the list" do
        params = { user: { id: @user.id,
                           username: @user.username, 
                           password: @user.password }, 
                   list_id: @list.id }

        get :index, params
        JSON.parse(response.body).should ==
          { 'items' =>
            [
              { 'list_id' => @list.id, 'description' => 'Robot1'},
              { 'list_id' => @list.id, 'description' => 'Robot2'},
              { 'list_id' => @list.id, 'description' => 'Robot3'}
            ]
          }

      end

    end

    context "without correct user's password" do

      it "returns an error" do
        params = { user: { id: @user.id, username: @user.username, password: "wrong" }, list_id: @list.id }

        get :index, params
        expect(response.status).to eq 400
      end
    end

  end

end
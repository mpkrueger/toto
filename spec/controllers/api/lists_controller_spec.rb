require 'spec_helper'

describe Api::ListsController do 

  before do
    User.destroy_all
    List.destroy_all
    @user = create(:user)      
  end

  describe "create" do
    context "with correct user's password" do

      it "takes a list name and creates it if it doesn't exist" do
        params = { id: @user.id, username: @user.username, password: @user.password, list: { name: "New List", permissions: "private", user_id: @user.id } }

        expect{ post :create, params }
          .to change{ List.count }
          .by 1

      end

      it "takes a list name and returns false if it does exist" do
        list = List.create(name: "Honey Do", permissions: "private", user_id: @user.id)
        params = { id: @user.id, username: @user.username, password: @user.password, list: { name: "Honey Do", permissions: "private", user_id: @user.id } }

        post :create, params
        expect(response.status).to eq 400
      end

    end

    context "without correct user's password" do
      
      it "it errors" do
        params = { id: @user.id, username: @user.username, password: "wrong", list: { name: "New List", permissions: "private", user_id: @user.id } }

        post :create, params
        expect(response.status).to eq 400

      end

    end
  end

  describe "index" do
    
    before do
      @user1 = User.create( id: '3', username: "user", password: "pass" )
      (1..3).each{ |n| List.create( name: "List#{n}", user_id: '3') }
    end

    context "with correct user's password" do

      it "returns all lists associated with the user" do
        params = { id: @user1.id, username: @user1.username, password: @user1.password }

        get :index, params

        JSON.parse(response.body).should ==
          { 'lists' =>
            [
              { 'name' => 'List1', 'user_id' => 3 },
              { 'name' => 'List2', 'user_id' => 3 },
              { 'name' => 'List3', 'user_id' => 3 }
            ]
          }

      end

    end

    context "without correct user's password" do

      it "returns all visible and open lists" do
        params = { id: @user1.id, username: @user1.username, password: "wrong" }

        get :index, params
        expect(response.status).to eq 400

      end

    end
  end
end
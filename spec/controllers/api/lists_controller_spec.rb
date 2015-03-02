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
        params = { id: @user.id,
                   username: @user.username, 
                   password: @user.password, 
                   list: { name: "New List", 
                           permissions: "private", 
                           user_id: @user.id } }

        expect{ post :create, params }
          .to change{ List.count }
          .by 1

      end

      it "takes a list name and returns false if it does exist" do
        list = List.create(name: "Honey Do", permissions: "private", user_id: @user.id)
        params = { id: @user.id, 
                   username: @user.username, 
                   password: @user.password, 
                   list: { name: "Honey Do",
                           permissions: "private", 
                           user_id: @user.id } }

        post :create, params
        expect(response.status).to eq 400
      end

    end

    context "without correct user's password" do
      
      it "it errors" do
        params = { id: @user.id,
                   username: @user.username,
                   password: "wrong", 
                   list: { name: "New List",
                           permissions: "private", 
                           user_id: @user.id } }

        post :create, params
        expect(response.status).to eq 400

      end

    end
  end

  describe "update" do

    before do
      @user = User.create(username: "Santa", password: "rudolph")
      @list = List.create(name: "Santa's list", user_id: @user.id)
      @viewable_list = List.create(name: "view list", user_id: @user.id, permissions: "viewable")
      @open_list = List.create(name: "open list", user_id: @user.id, permissions: "open")
    end

    it "updates the list permissions when given a supported permissions type" do
      params = { id: @user.id,
                 username: @user.username,
                 password: @user.password,
                 list: { id: @list.id,
                         name: @list.name,
                         permissions: "open",
                         user_id: @user.id } }

      patch :update, params

      expect(@list.reload.permissions).to eq "open"

    end

    it "returns an error when given an unsupported permissions type" do
      params = { id: @user.id,
                 username: @user.username,
                 password: @user.password,
                 list: { id: @list.id,
                         name: @list.name,
                         permissions: "wrong",
                         user_id: @user.id } }

      patch :update, params

      expect(response.status).to eq 400
    end

    it "allows user to edit a list with permissions set to open" do

      params = { id: @user.id,
                 username: @user.username,
                 password: @user.password,
                 list: { id: @open_list.id,
                         name: "New Name",
                         user_id: @user.id } }

      patch :update, params

      expect(@open_list.reload.name).to eq "New Name"
    end

    it "doesn't allow a user to edit a list with permissions set to viewable" do
      viewable_user = User.create(username: "Abe", password: "password")

      params = { id: viewable_user.id,
                 username: "Abe",
                 password: "password",
                 list: { id: @viewable_list.id,
                         name: "New Name",
                         user_id: viewable_user.id } }

      patch :update, params

      expect(response.status).to eq 400
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
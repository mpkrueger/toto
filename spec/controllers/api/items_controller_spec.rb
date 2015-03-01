require 'spec_helper'

describe Api::ItemsController do 
  before do
    @user = User.create(username: "Santa", password: "rudolph")
    @list = List.create(name: "Santa's List", user_id: @user.id)
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

      it "allows user to view a list with permissions set to viewable" do
        viewable_list = List.create(name: "To Do", user_id: @user.id, permissions: "viewable")
        other_user = User.create(username: "Doug", password: "password")
        (1..3).each{ |n| Item.create( list_id: viewable_list.id, description: "Shopping#{n}") }

        params = { user: { id: other_user.id,
                           username: "Doug",
                           password: "password" },
                   list_id: viewable_list.id }

        get :index, params
        JSON.parse(response.body).should ==
          { 'items' =>
            [
              { 'list_id' => viewable_list.id, 'description' => 'Shopping1'},
              { 'list_id' => viewable_list.id, 'description' => 'Shopping2'},
              { 'list_id' => viewable_list.id, 'description' => 'Shopping3'}
            ]
          }
      end

      it "doesn't allows user to view a list with permissions set to private" do
        private_list = List.create(name: "Honey Do", user_id: @user.id, permissions: "private")
        other_user = User.create(username: "Doug", password: "password")
        (1..3).each{ |n| Item.create( list_id: private_list.id, description: "Clean#{n}") }

        params = { user: { id: other_user.id,
                           username: "Doug",
                           password: "password" },
                   list_id: private_list.id }

        get :index, params
        expect(response.status).to eq 400
      end

      it "allows user to view a list with permissions set to open" do
        open_list = List.create(name: "open listicle", user_id: @user.id, permissions: "open")
        other_user = User.create(username: "Doug", password: "password")
        (1..3).each{ |n| Item.create( list_id: open_list.id, description: "Fix#{n}") }

        params = { user: { id: other_user.id,
                           username: "Doug",
                           password: "password" },
                   list_id: open_list.id }

        get :index, params
        JSON.parse(response.body).should ==
          { 'items' =>
            [
              { 'list_id' => open_list.id, 'description' => 'Fix1'},
              { 'list_id' => open_list.id, 'description' => 'Fix2'},
              { 'list_id' => open_list.id, 'description' => 'Fix3'}
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
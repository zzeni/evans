require 'spec_helper'

describe DashboardsController do
  log_in_as :student

  describe "GET show" do
    it "requires an authenticated user" do
      controller.stub :current_user => nil
      get :show
      response.should deny_access
    end

    it "assigns the number of points the current user has to @points" do
      current_user.stub :points => 2
      get :show
      assigns(:points).should == 2
    end
  end
end

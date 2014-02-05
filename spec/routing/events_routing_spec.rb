require "spec_helper"

describe SessionsController do
  describe "routing" do

    it "routes to #index" do
      get("/sessions").should route_to("sessions#index")
    end

    it "routes to #new" do
      get("/sessions/new").should route_to("sessions#new")
    end

    it "routes to #show" do
      get("/sessions/1").should route_to("sessions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sessions/1/edit").should route_to("sessions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sessions").should route_to("sessions#create")
    end

    it "routes to #update" do
      put("/sessions/1").should route_to("sessions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sessions/1").should route_to("sessions#destroy", :id => "1")
    end

  end
end

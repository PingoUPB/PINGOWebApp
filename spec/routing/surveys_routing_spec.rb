require "spec_helper"

describe SurveysController do
  describe "routing" do

    it "routes to #index" do
      get("/surveys").should route_to("surveys#index")
    end

    it "routes to #new" do
      get("/surveys/new").should route_to("surveys#new")
    end

    it "routes to #show" do
      get("/surveys/1").should route_to("surveys#show", :id => "1")
    end

    it "routes to #edit" do
      get("/surveys/1/edit").should route_to("surveys#edit", :id => "1")
    end

    it "routes to #create" do
      post("/surveys").should route_to("surveys#create")
    end

    it "routes to #update" do
      put("/surveys/1").should route_to("surveys#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/surveys/1").should route_to("surveys#destroy", :id => "1")
    end

  end
end

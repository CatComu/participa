class SpacesController < ApplicationController
    before_action :authenticate_user!
  
    def index
      authorize! :index, :spaces
    end

  end
  
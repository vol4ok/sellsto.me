class CustomMapController < ApplicationController

    def index
      respond_to do |format|
        format.html #use html layout
        format.json #basic json command
      end
    end

end

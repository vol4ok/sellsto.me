

class MapController < ApplicationController

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json #do nothing for now
    end
  end

  def search
    points = Array.new(100)
    for i in 0..99
      points[i] = GeoPoint.new -34.397 + 0.5 * rand, 150.644 + 0.5 * rand
    end
    respond_to do |format|
      format.json {render json: points} #Question: Does this variable would be accessible?
    end
  end

end

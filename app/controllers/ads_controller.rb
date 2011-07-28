class AdsController < ApplicationController
  
  def index
    @ad = Ad.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ad }
    end
  end
  
  def create
    @ad = Ad.new(params[:ad])
    if @ad.save
      render json: @ad, status: :created, location: @ad
    else
      render json: @ad.errors, status: :unprocessable_entity
    end
  end

  def update
    @ad = Ad.find(params[:id])
    if @ad.update_attributes(params[:ad])
       head :ok
    else
      render json: @ad.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @ad = Ad.find(params[:id])
    @ad.destroy
    head :ok
  end
  
end

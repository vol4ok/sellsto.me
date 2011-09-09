class SearchController < ApplicationController

  def index
    logger.info Rails.application.config.assets.paths
  end

end

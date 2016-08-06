class ItemsController < ApplicationController

  def show
    items = Item.search params[:id]
    render json: items
  end

  def index
  end

end

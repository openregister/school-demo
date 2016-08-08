class ItemsController < ApplicationController

  def show
    items = Item.search params[:id]
    render json: items
  end

  def index
    @items = Item.search params[:q].to_s.strip.chomp(',') if params[:q]
  end

end

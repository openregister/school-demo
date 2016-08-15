class ItemsController < ApplicationController

  def show
    items = Item.search params[:id]
    render json: items
  end

  def index
    if params[:q]
      @items = Item.search params[:q].to_s.strip.chomp(',')
      if @items.try(:size) == 1
        item = @items.first
        case item.register
        when 'place'
          redirect_to point_url(id: item.coordinates.join(','))
        when 'school'
          redirect_to school_url(id: item.record)
        end
      end
    end
  end

end

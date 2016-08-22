class ItemsController < ApplicationController

  def show
    items = Item.search params[:id]
    render json: items
  end

  def index
    @query = params[:q]
    if @query
      @items = Item.search @query, limit: 250
      if @items.try(:size) == 0
        @items = Item.search @query.to_s.split(',').first, limit: 250
      end

      if @items.try(:size) == 1
        item = @items.first
        case item.register
        when 'place'
          flash[:query] = @query
          redirect_to point_url(id: item.coordinates.join(','))
        when 'school'
          redirect_to school_url(id: item.record)
        end
      else
        @items.sort_by!(&:display_name)
      end
    end
  end

end

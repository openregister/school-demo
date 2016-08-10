class PointsController < ApplicationController

  def show
    point = params[:id]
    if school = Item.school_at(point)
      redirect_to school_url(id: school.record)
    else
      @lon, @lat = Item.lon_lat point
      @schools = Item.not_ended.nearest_schools(point)
    end
  end

end

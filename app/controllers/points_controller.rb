class PointsController < ApplicationController

  def show
    point = params[:id]
    if school = Item.school_at(point)
      redirect_to school_url(id: school.record)
    else
      item = Item.at(point).first
      @lon, @lat = Item.lon_lat point
      @heading = item ? "Schools near #{item.name}" : "Schools near lon: #{@lon}, lat: #{@lat}"
      @schools = Item.not_ended.nearest_schools(point)
    end
  end

end

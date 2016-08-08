class PointsController < ApplicationController

  def show
    point = params[:id]
    if school = Item.school_at(point)
      redirect_to school_url(id: school.record)
    else
      @schools = Item.nearest_schools(point)
    end
  end

end

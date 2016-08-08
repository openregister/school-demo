class PointsController < ApplicationController

  def show
    point = params[:id]
    if school = Item.school_at(point)
      redirect_to school_url(id: school.record)
    else
      binding.pry
      render json: []
    end
  end

end

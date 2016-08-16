class IndicesController < ApplicationController

  def index
    @fields = %i[register record name place coordinates entry_number]
    @schools = Item.schools.page params[:page]
    @places = Item.places.page params[:page]
  end

end

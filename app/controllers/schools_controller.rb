require 'openregister'

class SchoolsController < ApplicationController

  def show
    @school = OpenRegister.record 'school', params[:id], ENV['PHASE'].to_sym
    if @school
      address = @school._address
      point = address.try(:point)
      if point && point.size > 0
        @lon, @lat = eval(point)
      end
      @records = [@school].push(*OpenRegisterHelper.record_fields_from_list([@school]))
      @by_registry = @records.group_by { |record| record._register.registry }
    end
  end

end

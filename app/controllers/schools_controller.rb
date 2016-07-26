class SchoolsController < ApplicationController

  def show
    @school = OpenRegister.record 'school', params[:id], :discovery
    if @school
      @records = [@school].push(*OpenRegisterHelper.record_fields_from_list([@school]))
      @by_registry = @records.group_by { |record| record._register.registry }
    end
  end

end

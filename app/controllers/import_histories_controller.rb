class ImportHistoriesController < ApplicationController

  def index
    if params[:survey_id]
      @import_histories = ImportHistory.where(:survey_id => params[:survey_id])
    else
      @import_histories = ImportHistory.all
    end
  end

  def show
    @import_history = ImportHistory.find(params[:id])
  end

  def destroy
    @import_history = ImportHistory.find(params[:id])
    @import_history.destroy

    redirect_to(import_histories_url)
  end
end

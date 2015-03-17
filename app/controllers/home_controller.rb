class HomeController < ApplicationController

  include HomeHelper

  def index
    authorize! :home, :index
    @user = current_user
    prepare_current_status
  end
end

class IdentitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_identity

  def destroy
    if @identity.user == current_user
      @identity.destroy

      flash[:notice] = "#{@identity.provider.capitalize} login removed."
    else
      flash[:alert] = "Only user can delete their own Identity."
    end

    redirect_to root_path
  end

  private
    def set_identity
      @identity = Identity.find(params[:id])
    end
end
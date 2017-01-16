class IdentitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_identity

  def destroy
    if @identity.user == current_user
      @identity.destroy

      redirect_to root_path, notice: "#{@identity.provider.capitalize} login removed."
    else
      redirect_to root_path, alert: "Only user can delete their own Identity."
    end
  end

  private
    def set_identity
      @identity = Identity.find(params[:id])
    end
end
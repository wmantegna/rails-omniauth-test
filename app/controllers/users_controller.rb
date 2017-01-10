class UsersController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_current_user

  def edit_password
  end
  def update_password
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in(@user, :bypass => true)
      redirect_to root_path
    else
      render :edit_password
    end
  end

  def edit_email
  end
  def update_email
    if @user.update(user_params)
      send_reconfirmation_email(@user)
      redirect_to root_path
    else
      raise
      render :edit_email
    end
  end

  def cancel_email_change
    @user.unconfirmed_email = nil
    @user.confirmation_token = nil
    @user.save

    redirect_to root_path, alert: "Request to change email address cancelled."
  end
  def resend_reconfirmation_email
    send_reconfirmation_email(@user)

    redirect_to root_path, notice: "reconfirmation email successfully sent to #{@user.unconfirmed_email}"
  end

  # PATCH/PUT /users/:id.:format
  # def update
  #   # authorize! :update, @user
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       sign_in(@user == current_user ? @user : current_user, :bypass => true)
  #       format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # GET/PATCH /users/:id/finish_signup
  # def finish_signup
  #   # authorize! :update, @user 
  #   if request.patch? && params[:user] #&& params[:user][:email]
  #     if @user.update(user_params)
  #       @user.skip_reconfirmation!
  #       sign_in(@user, :bypass => true)
  #       redirect_to @user, notice: 'Your profile was successfully updated.'
  #     else
  #       @show_errors = true
  #     end
  #   end
  # end
  
  private
    # def set_user
    #   @user = User.find(params[:id])
    # end
    def set_current_user
      @user = User.find(current_user.id)
    end

    def send_reconfirmation_email(user)
      user.confirmation_token = Devise.friendly_token
      user.save
      Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver   
    end

    def user_params
      # accessible = [ :name, :email ] # extend with your own params
      accessible = []
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      accessible << [ :unconfirmed_email, :unconfirmed_email_confirmation ] unless params[:user][:unconfirmed_email].blank?
      params.require(:user).permit(accessible)
    end
end
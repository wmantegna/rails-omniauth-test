class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit_password
    redirect_to_correct_user(user_edit_password_path, params[:user_id])
  end
  def update_password
    if redirect_to_correct_user(user_edit_password_path, params[:user_id])
      return
    end

    # validate input
    @errorMessage = ''
    if user_params[:password] != user_params[:password_confirmation]
      @errorMessage = "new password & new password confirmation must be the same"
    end
    
    # update record
    if @errorMessage.blank?
      if @user.update(user_params)
        # Sign in the user by passing validation in case their password changed
        sign_in(@user, :bypass => true)
        redirect_to root_path, notice: 'Successfully updated password.'
      else
        @errorMessage = 'Failed to update password.'
      end
    end

    # output error
    unless @errorMessage.blank?
      flash[:alert] = @errorMessage
      render :edit_password
    end
  end

  def edit_email
    redirect_to_correct_user(user_edit_email_path, params[:user_id])
  end
  def update_email
    if redirect_to_correct_user(user_edit_email_path, params[:user_id])
      return
    end

    # Validate parameters from form
    @errorMessage = ''
    @unconfirmedEmail = user_params[:unconfirmed_email]
    if @unconfirmedEmail != user_params[:unconfirmed_email_confirmation]
      @errorMessage = 'New email & new email confirmation must be the same.'
    end
    if @errorMessage.blank? && User.is_email?(@unconfirmedEmail) == false
      @errorMessage = 'New email must be a proper email address.'
    end
    if @errorMessage.blank? && @user.email == @unconfirmedEmail
      @errorMessage = "You can only change to an email address different from the #{@user.email}"
    end
    if @errorMessage.blank? && User.is_email_in_use?(@unconfirmedEmail)
      @errorMessage = "#{@unconfirmedEmail} is already in use."
    end

    # update record
    if @errorMessage.blank?
      if @user.update(user_params)
        send_confirmation_email(@user)
        redirect_to root_path, notice: "Email change requested. Check #{@user.unconfirmed_email} for confirmation email."
      else
        @errorMessage = 'Error updating user record'
      end
    end

    # display error if necessary
    unless @errorMessage.blank?
      flash[:alert] = @errorMessage
      render :edit_email
    end
  end

  def cancel_email_change
    if redirect_to_correct_user(root_path, params[:user_id])
      return
    end
    
    @user.unconfirmed_email = nil
    @user.confirmation_token = nil
    @user.save

    redirect_to root_path, alert: "Request to change email address cancelled."
  end
  def send_confirmation
    if redirect_to_correct_user(root_path, params[:user_id])
      return
    end
    
    send_confirmation_email(@user)
    redirect_to root_path, notice: "Confirmation email successfully sent to #{@user.unconfirmed_email}"
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
    def set_user
      @user = User.find(params[:user_id])
    end
   
    # Stops users from being impersonated by making sure only the current user can edit their own record
    def redirect_to_correct_user(path, requested_id)
      # Potential failure here if the requested_id appears multiple times.
      
      # As long as all of the routes to this controller only ever contain...
      # ...one id (as it currently does), this function will work.

      unless current_user.id == requested_id.to_i
        newPath = path.sub(requested_id.to_s, current_user.id.to_s)
        redirect_to newPath
        return true
      end
      
      return false
    end

    def send_confirmation_email(user)
      user.confirmation_token = Devise.friendly_token
      user.save

      # send to unconfirmed email if this is a reconfirmation
      opts = {}
      unless user.unconfirmed_email.nil?
        opts = {to: user.unconfirmed_email}

        # contact original email address informing them of the change
        UserMailer.email_change(user.id).deliver_now
      end

      Devise::Mailer.confirmation_instructions(user, user.confirmation_token, opts).deliver_now
    end

    def user_params
      # accessible = [ :name, :email ] # extend with your own params
      accessible = []
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      accessible << [ :unconfirmed_email, :unconfirmed_email_confirmation ] unless params[:user][:unconfirmed_email].blank?
      params.require(:user).permit(accessible)
    end
end
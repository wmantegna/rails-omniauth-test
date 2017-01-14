class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  def new
    super
  end

  # POST /resource/confirmation
  def create
    super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # Stop confirmation if 'unconfirmed_email' exists as 'email' for any user
    @user = User.where(confirmation_token: params[:confirmation_token]).first
    unless @user.nil?
      if User.where(email: @user.unconfirmed_email).length > 0
        
        cancel_email_confirmation(@user)
        redirect_to root_path, alert: "Email Confirmation Failed. #{@user.unconfirmed_email} has already been confirmed by another user."
        return
      end
    end

    super
  end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    super(resource_name)
  end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    super(resource_name, resource)
  end

  private
  def cancel_email_confirmation(user)
    user.confirmation_token = nil
    user.unconfirmed_email = nil
    user.save
  end
end

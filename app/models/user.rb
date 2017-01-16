class User < ActiveRecord::Base
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  has_many :identities

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Validations
  #############################
  validates_presence_of :email
  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  # Non-model attribute (not saved directly to DB)
  attr_accessor :unconfirmed_email_confirmation

  def self.is_email?(email)
    return (email =~ Devise.email_regexp).nil? == false
  end
  def self.is_email_in_use?(email)
    return User.where(email: email).any?
  end
  #############################

  # Queries
  #############################
  def self.search_by_email(email)
    Event.where(email: email)
  end
  #############################


  # Omniauth
  #############################
  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)
    authEmail = auth.info.email if auth.info? && auth.info.email? && (Devise.email_regexp =~ auth.info.email).nil? == false

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    # signed_in_resource ~ current_user
    user = signed_in_resource ? signed_in_resource : identity.user


    # don't allow a user to connect an existing identity record to a different user
    if identity.user.nil? == false && identity.user != user
      raise "This account is already associated with another user"
    end

    defaultEmail = "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com"

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      user = User.where(:email => authEmail).first if authEmail

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          email: authEmail ? authEmail : defaultEmail,
          password: Devise.friendly_token[0,10]
        )
        user.skip_confirmation!
        user.save
      end
    end

    # if missing, add user email
    if user.email == defaultEmail && authEmail.nil? == false
      user.email = authEmail
      user.skip_confirmation!
      user.save
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end

    # Add name from auth to social identity
    if auth.info? && auth.info.name?
      if auth.info.name != identity.name
        identity.name = auth.info.name
        identity.save
      end
    end

    return user
  end

  def has_facebook_identity?
    return self.identities.where(provider: :facebook).exists?
  end

  def email_verified?
    return self.email && 
            (self.email !~ TEMP_EMAIL_REGEX) && 
            (self.email !~ Devise.email_regexp) == false
  end
  #############################
end

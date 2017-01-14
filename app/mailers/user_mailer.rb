class UserMailer < ApplicationMailer

  def email_change(user_id)
    @user = User.find(user_id)

    mail(to: @user.email, subject: 'Email Change Request')
  end
end

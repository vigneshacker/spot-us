class UsersController < ApplicationController
  include AuthenticatedSystem

  def new
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = 'Click the link in the email we just sent to you to finish creating your account!'
    end
    render :action => 'new'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if current_user
      current_user.activate!
      login_cookies
      flash[:success] = "You have successfully activated your account - welcome to Spot.Us!"
      redirect_back_or_default('/')
    else
      flash[:error] = "Sorry, we were unable to find that activation code. Perhaps you have already activated your account?"
      redirect_to new_session_url
    end
  end

  def activation_email
  end

  def resend_activation
    user = User.find_by_email(params[:email])
    if user && !user.activated?
      Mailer.deliver_activation_email(user)
      flash[:success] = 'Great! We just sent you another email. Click the link to finish activating your account.'
    else
      flash[:error] = "Sorry, we couldn't find an account with that email address."
    end
    redirect_back_or_default('/')
  end
end



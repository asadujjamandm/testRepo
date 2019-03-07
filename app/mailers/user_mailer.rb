class UserMailer < ActionMailer::Base
  default :from => "akash.jucse@gmail.com"
  def welcome_email(user)
    @user 		 = user
    @url 	     = "<a href='http://localhost:3007'>http://localhost:3007</a>"
    @site_name = "localhost"
    mail(:to => user.email, :subject => "Welcome to WIPTime.")  do |format| format.text
    end
  end
end

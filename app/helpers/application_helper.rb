module ApplicationHelper
  
  def signin
    link_to "sign in with twitter", :controller=>"twi_challenge", :action=>"request_token"
  end
  def signout
    link_to "Signout", :controller=>"session", :action=>"signout"
  end
  def username
   link_to "@"+TwiUser.find(session[:user_id]).handler, "https://www.twitter.com", :target=>"black"
  end
  def signout_twitter
   link_to "Signout of twitter", "https://twitter.com/logout", :id=>"signout_twitter"
  end
  
  
  def authlink
    if !session[:user_id].nil?
      username  + " | " + signout + " | " + signout_twitter
    else
      signin
    end
  end
  
  def str_source
    [('a'..'z'),('A'..'Z'),("0".."9")].map{|i| i.to_a}.flatten
  end
  

end

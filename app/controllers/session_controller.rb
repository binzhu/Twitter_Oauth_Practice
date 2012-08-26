class SessionController < ApplicationController
  def create
    #puts "create called!"
    #@access_token is user specific
    @access_token = session[:request_token].get_access_token
    puts @access_token.inspect
    #store the access token in session
    session[:access_token] = @access_token
    
    #look for user in the database
    user = TwiUser.find_by_uid(@access_token.params[:user_id])
    if user
      session[:user_id]=user.id
      #update token in database upon login, not sure usefulness yet
      user.access_token = @access_token.token
      user.token_secret = @access_token.secret
      user.save
    else
      
      #sign up user upon successful twitter authorization
      user = TwiUser.new(
        :uid=>@access_token.params[:user_id],
        :handler=>@access_token.params[:screen_name],
        :access_token=>@access_token.token,
        :token_secret=>@access_token.secret
      )
      user.save
      session[:user_id]=user.id
    end
    redirect_to :controller=>"twi_challenge", :action=>"index", :state=>"index"
  end

  def signout
    reset_session
    redirect_to :controller=>"twi_challenge", :action=>"index"
  end
end

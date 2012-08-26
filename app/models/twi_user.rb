class TwiUser < ActiveRecord::Base
  attr_accessible :access_token, :handler, :uid, :token_secret
  

end

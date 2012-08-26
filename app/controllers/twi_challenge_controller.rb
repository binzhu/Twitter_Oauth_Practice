class TwiChallengeController < ApplicationController
  def index
    if !session[:user_id].nil?
          #using api call #1 get_firend_id defined below
          all_friend_ids = get_friend_id
          if all_friend_ids.nil? || all_friend_ids.count < 0
            @error_msg = "no friend retrieved, please contact app admin"
          else
          
          friend_pagination_array = pagination(all_friend_ids,20)
          
          @pagcnt = friend_pagination_array.count # count the pages to be loaded
        
        #pagination logic
        if params[:page].to_i <= 1 || params[:page].nil?
          index = 1
          end_index = ((index-1)*20 + 20).to_s
        elsif params[:page].to_i >= @pagcnt
          index = @pagcnt.to_i
          end_index = all_friend_ids.length.to_s
        else
          index = params[:page].to_i
          end_index = ((index-1)*20 + 20).to_s
        end
        @pagemsg = "Displaying " + ((index-1)*20 + 1).to_s + " .. " + end_index
        
        
        #puts "current page is " + index.to_s
        @friend_ids = friend_pagination_array[index-1]
          
          @profile = Array.new
          fids = ""
          fcnt = @friend_ids.count
          
          for i in 0..fcnt-1 do
            fids += @friend_ids[i].to_s
            fids += "," unless i == fcnt
          end# end for loop to get friend id string
          @profile = []
          friend_info = get_detail_info(fids)
          
          unsorted_ids = []
          for i in 0..fcnt-1 do 
            unsorted_ids << friend_info[i]["id"]
          end
          
          @friend_ids.each do |fid|
            @profile << friend_info[unsorted_ids.index(fid)]
          end
        
        end#end if no friend retrieved  
    end#end if session isset
  end
  
  def search
    if params[:searchterm][:search].length < 1
      redirect_to :back, notice: "please input search keyword"
      return
    else
      @profile= search_user(params[:searchterm][:search])
    end
  end
  

  
  #0 api call to get request token for first time user
  def request_token
    localcallback = "http://localhost:3000/twitter/callback"
    herokucallback = "http://twitterapi.herokuapp.com/twitter/callback"
    @callback_url = herokucallback
    @consumer = OAuth::Consumer.new(ENV['consumer_key'],ENV['consumer_secret'],:site=>"https://api.twitter.com")
    @consumer.options[:authenticate_path] = "/oauth/authenticate"
    
    #@request_token is app specific not user specific
    @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
    
    session[:request_token] = @request_token
    #redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
    redirect_to "https://api.twitter.com/oauth/authenticate?oauth_callback=" + @callback_url + "&oauth_token=" + @request_token.token
  end
  
  #1 api call to return a list of user id that the current user is following
  def get_friend_id 
        uri  = "https://api.twitter.com/1/friends/ids.json"     
        
        #http request for friend search start
        req = Typhoeus::Request.new(uri,
                                  :method =>"get",
                                  :params =>{:cursor=>"-1", :screen_name=>crt_user.handler})      
      #sign_request(req,uri)
      hydra = Typhoeus::Hydra.new
      hydra.queue(req)
      hydra.run
      JSON.parse(req.response.body)["ids"]
  end
  
  #2 api call to return a user/many users' profile(image url, name, handler, user_id)
  def get_detail_info(fids)
      uri = "https://api.twitter.com/1/users/lookup.json"
      req = Typhoeus::Request.new(uri,
                                  :method =>"post",
                                  :params =>{:user_id=>fids, :include_entities=>"true"})
      
      sign_request(req,uri)
      hydra = Typhoeus::Hydra.new
      hydra.queue(req)
      hydra.run
      JSON.parse(req.response.body)
      
  end
  
  #3 api call to unfollow all marked friends
  def unfollow
    if request.post?
      @unf_ids = params[:unfollow]
      
      #unf_str = ""
      #unf_cnt = unf_ids.length - 1
      #for i in 0..unf_cnt
      #  unf_str +=unf_ids[i].to_s
      #  unf_str += "," unless unf_cnt == i
      #end
      if @unf_ids.nil? || @unf_ids.length < 1
      else
        @unf_ids.each do |unfo|    
          hydra = Typhoeus::Hydra.new
          uri = "http://api.twitter.com/1/friendships/destroy.json"
                req = Typhoeus::Request.new(uri,
                                            :method =>"post",
                                            :params =>{:user_id=>unfo, :include_entities=>"true"})
                
          sign_request(req,uri)
          hydra.queue(req)
          hydra.run
          puts req.response.inspect
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def search_user(q)
      uri = "https://api.twitter.com/1/users/search.json"
      req = Typhoeus::Request.new(uri,
                                  :method =>"get",
                                  :params =>{:q=>q, :include_entities=>"true"})
      oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => uri))
      sign_request(req,uri)
      hydra = Typhoeus::Hydra.new
      hydra.queue(req)
      hydra.run      
      
      profile_list = Array.new

      JSON.parse(req.response.body).each do |raw|
        profile_list.push([
          raw["id"].to_s,
          raw["profile_image_url"].to_s,
          raw["name"].to_s,
          raw["screen_name"].to_s]
        )# prepare to cash into database, not sure
      end
      profile_list.sort!{|x,y| x[0]<=>y[0]}     
  end
  def follow
    if request.post?
      fo_ids = params[:follow] 
      #fo_str = ""
      #fo_cnt = fo_ids.length - 1
      #for i in 0..fo_cnt
      #  fo_str +=fo_ids[i].to_s
      #  fo_str += "," unless fo_cnt == i
      #end
      
      fo_ids.each do  |fid|
        hydra = Typhoeus::Hydra.new
        uri = "http://api.twitter.com/1/friendships/create.json"
              req = Typhoeus::Request.new(uri,
                                          :method =>"post",
                                          :params =>{:user_id=>fid, :include_entities=>"true"})
              
        sign_request(req,uri)
        hydra.queue(req)
        hydra.run
        puts req.response.inspect
      end
    end
    redirect_to :action=>"index"    
  end
  
  def crt_user
    #TwiUser.find(session[:user_id])
    TwiUser.first
  end

  def sign_request(req,uri)
      oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(:request_uri => uri))
      req.headers.merge!({"Authorization" => oauth_helper.header}) # Signs the request
  end
  def oauth_params
     {:consumer => consumer, :token => access_token}
  end
  def consumer
     OAuth::Consumer.new(ENV['consumer_key'],ENV['consumer_secret'],:site=>"https://api.twitter.com")
  end
  
  def oauth_params
      {:consumer => consumer, :token => session[:access_token]}
  end
  def convert_zones(to_zone)
     to_zone_time = to_zone.localtime
  end
  
  
  ######################################################
  #attempted to write oauth lib
  #not successful
  ######################################################
  def unfollow_test
      unf_ids = params[:unfollow]
      
      unf_str = ""
      unf_cnt = unf_ids.length - 1
      for i in 0..unf_cnt
        unf_str +=unf_ids[i].to_s
        unf_str += "," unless unf_cnt == i
      end
     
    params_before_encode = [
          ["user_id",unf_str],
          ["include_entities","true"]
        ]
        request_before_encode = [
          ["http_method","POST"],
          ["base_url","http://api.twitter.com/1/friendships/destroy.json"]
        ]
      header_string = buildheader(params_before_encode,request_before_encode)
      puts header_string
      request = Typhoeus::Request.new("http://api.twitter.com/1/friendships/destroy.json",
                                  :method =>"post",
                                  :headers =>{"Authorization" => header_string},
                                  :params =>{:user_id=>unf_str, :include_entities=>"true"})
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run    
  end
  
  
  
  def sign( key, base_string )
    digest = OpenSSL::Digest::Digest.new( 'sha1' )
    hmac = OpenSSL::HMAC.digest( digest, key, base_string  )
    escape(Base64.encode64( hmac ).chomp.gsub( /\n/, '' ))
  end
  
  def buildheader(request_before_encode,params_before_encode)
      
      #prep string for nonce
      o =  [('a'..'z'),('A'..'Z'),("0".."9")].map{|i| i.to_a}.flatten
      oauth_nonce = (0..50).map{ o[rand(o.length)]  }.join
      oauth_timestamp=Time.now.to_i.to_s
      oauth_token = crt_user.access_token


      #data to authenticate the request
      token_before_encode = [
        ["oauth_consumer_key",ENV['consumer_key']],
        ["oauth_nonce",oauth_nonce],
        ["oauth_signature_method", "HMAC-SHA1"],
        ["oauth_timestamp",oauth_timestamp],
        ["oauth_token",oauth_token],
        ["oauth_version","1.0"]

      ]

      #concatenate and sort alphabetically
      after_encode = (token_before_encode + params_before_encode).sort{|x,y| x[0]<=>y[0]}
      

      #percent encode the params to prepare for parameter string
      after_encode.each do |af|
        af[0] = escape(af[0])
        af[1] = escape(af[1])
      end
      
      parameter_string = ""
      cnt = after_encode.length - 1
      
      for i in 0..cnt
        parameter_string += after_encode[i][0]
        parameter_string += "="
        parameter_string += after_encode[i][1]
        parameter_string += "&" unless i == cnt
      end
      
      
                                  #before_encode[cnt+2][1] is the http request baseurl
      signature_base =  request_before_encode[0][1].upcase + "&" +  escape(request_before_encode[1][1]) + "&" + parameter_string
      
      signing_key = escape(ENV['consumer_secret']) + "&" + escape(crt_user.token_secret)
    
      oauth_signature = sign(signing_key,signature_base)

      #start to build header string
      header_str = 'OAuth '
      header_prep = [
        ['oauth_consumer_key',ENV['consumer_key']],
        ['oauth_nonce',oauth_nonce],
        ['oauth_signature', oauth_signature],
        ['oauth_signature_method', 'HMAC-SHA1'],
        ['oauth_timestamp',oauth_timestamp],
        ['oauth_token',oauth_token],
        ['oauth_version','1.0']
      ]
      h_cnt = header_prep.length - 1
      
      for i in 0..h_cnt
        header_str += header_prep[i][0]
        header_str += '='
        header_str += '"'
        header_str += header_prep[i][1]
        header_str += '"'
        header_str += ', ' unless i == h_cnt
      end
      #header string finished
      header_str
  end
  
  def escape(value)
    URI::escape(value.to_s, OAuth::RESERVED_CHARACTERS)
  rescue ArgumentError
    URI::escape(value.to_s.force_encoding(Encoding::UTF_8), OAuth::RESERVED_CHARACTERS)
  end  
end

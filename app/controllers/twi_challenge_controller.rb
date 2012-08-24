class TwiChallengeController < ApplicationController
  def index
    if !session[:user_id].nil?

        params_before_encode = [
          ["screen_name",crt_user.handler],
          ["cursor","-1"]
        ]
        request_before_encode = [
          ["http_method","GET"],
          ["base_url","https://api.twitter.com/1/friends/ids.json"]
        ]
        base_url = request_before_encode[1][1]
        #defined private method to build header string
        header_string = buildheader(params_before_encode,request_before_encode)      
  
        #http request for friend search start
        request = Typhoeus::Request.new(base_url,
                                  :method =>"get",
                                  :headers =>{"Authorization" => header_string},
                                  :params =>{:cursor=>"-1", :screen_name=>crt_user.handler})      
      
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      friend_pagination_array = pagination(JSON.parse(request.response.body)["ids"],20)
      @pagcnt = friend_pagination_array.count # count the pages to be loaded
    
      #ids of all friends obtained
    if params[:page].to_i <= 1 || params[:page].nil?
      index = 1
    elsif params[:page].to_i >= @pagcnt
      index = @pagcnt.to_i
    else
      index = params[:page].to_i
    end
    puts "current page is " + index.to_s
      @friend_ids = friend_pagination_array[index-1]

      
      @profile = Array.new
      fids = ""
      fcnt = @friend_ids.count
      
      for i in 0..fcnt-1 do
        fids += @friend_ids[i].to_s
        fids += "," unless i == fcnt
      end
  
        params_before_encode = [
          ["user_id",fids],
          ["include_entities","true"]
        ]
        request_before_encode = [
          ["http_method","POST"],
          ["base_url","https://api.twitter.com/1/users/lookup.json"]
        ]
      base_url = request_before_encode[1][1]
      header_string = buildheader(params_before_encode,request_before_encode)
      request = Typhoeus::Request.new(base_url,
                                  :method =>request_before_encode[0][1],
                                  :headers =>{"Authorization" => header_string},
                                  :params =>{:user_id=>fids, :include_entities=>"true"})
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      JSON.parse(request.response.body)
      
      profile_list = Array.new
      session[:ids] = Array.new
      JSON.parse(request.response.body).each do |raw|
        profile_list.push([
          raw["id"].to_s,
          raw["profile_image_url"].to_s,
          raw["name"].to_s,
          raw["screen_name"].to_s]
        )
      end
      profile_list.sort!
      @profile = profile_list
    
    end#end if session isset
  end

  def unfollow
  end

  def follow
  end
  
  def request_token
    #o =  [('a'..'z'),('A'..'Z'),("0".."9")].map{|i| i.to_a}.flatten
    #oauth_nonce = (0..50).map{ o[rand(o.length)]  }.join
    #@callback_signedin = "http://localhost:3000"
    
    @callback_url = "http://localhost:3000/twitter/callback"
    @consumer = OAuth::Consumer.new(ENV['consumer_key'],ENV['consumer_secret'],:site=>"https://api.twitter.com")
    @consumer.options[:authenticate_path] = "/oauth/authenticate"
    
    #@request_token is app specific not user specific
    @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
    
    session[:request_token] = @request_token
    #redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
    redirect_to "https://api.twitter.com/oauth/authenticate?oauth_callback=" + @callback_url + "&oauth_token=" + @request_token.token
  end

  def pagination(pages,size)
    page_count = pages.length/size + 1 # count total page
    paged_array = Array.new
    for i in 0..(page_count-1)
      paged_array.push(pages[i*size..(i+1)*size-1])
    end
    paged_array
  end
  
  private

  def crt_user
    TwiUser.find(session[:user_id])
  end
  
  def sign( key, base_string )
    digest = OpenSSL::Digest::Digest.new( 'sha1' )
    hmac = OpenSSL::HMAC.digest( digest, key, base_string  )
    CGI.escape(Base64.encode64( hmac ).chomp.gsub( /\n/, '' ))
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
      before_encode = (token_before_encode + params_before_encode).sort
      

      #percent encode the params to prepare for parameter string
      before_encode.each do |be|
        be[0] = CGI.escape(be[0])
        be[1] = CGI.escape(be[1])
      end
      
      request_before_encode.each do |be|
        be[0] = CGI.escape(be[0])
        be[1] = CGI.escape(be[1])
      end
      
      parameter_string = ""
      cnt = before_encode.length - 1
      
      for i in 0..cnt
        parameter_string += before_encode[i][0]
        parameter_string += "="
        parameter_string += before_encode[i][1]
        parameter_string += "&" unless i == cnt
      end
      
                                  #before_encode[cnt+2][1] is the http request baseurl
      signature_base =  request_before_encode[0][1].capitalize + "&" +  request_before_encode[1][1] + "&" + parameter_string
      
      signing_key = CGI.escape(ENV['consumer_secret']) + "&" + CGI.escape(crt_user.token_secret)
    
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
end

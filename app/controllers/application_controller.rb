class ApplicationController < ActionController::Base
  protect_from_forgery
  
  require 'oauth/request_proxy/typhoeus_request'
  
  # total is the total number of items to be paginated
  # size is the size of items for each page
  # method return the ids of items for each page
  def pagination(total,size) 
    page_count = total.length/size + 1 # count total page
    paged_array = Array.new
    for i in 0..(page_count-1)
      paged_array.push(total[i*size..(i+1)*size-1])
    end
    paged_array
  end
  
end

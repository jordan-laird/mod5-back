
class RestaurantsWarpController < ApplicationController
  def create(params)
    response = JSON.parse(RestClient.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{params[:lat]},#{params[:long]}&key=#{Figaro.env.googleKey}&radius=16093.4&type=restaurant&keyword="))
    restaurantDetails = []
    response["results"].each do |restaurant| 
      begin
      test = RestClient.get("https://maps.googleapis.com/maps/api/place/details/json?key=#{Figaro.env.googleKey}&placeid=#{restaurant["place_id"]}&fields=geometry,name,formatted_address,formatted_phone_number,website")
     rescue => e
      byebug
      end
      restaurantDetails << JSON.parse(test)["result"]

    end
    # puts restaurantDetails
    restaurantsArray = [] 
    
    restaurantDetails.map{ |restaurant|
      restaurant["distance"] = calculateDistance(params[:lat], restaurant["geometry"]["location"]["lat"], params[:long], restaurant["geometry"]["location"]["lng"])
      restaurantsArray << restaurant
    }
  
    yield json: restaurantsArray 

  end

  def calculateDistance(a1, a2, lo1, lo2)
    lat1 = a1.to_f
    lat2 = a2.to_f
    long1 = lo1.to_f
    long2 = lo2.to_f
    radLat1 = (Math::PI * lat1) / 180
    radLat2 = (Math::PI * lat2) / 180
    theta = (long1 - long2)
    radTheta = (Math::PI * theta) / 180
    distance =
      Math.sin(radLat1) * Math.sin(radLat2) +
      Math.cos(radLat1) * Math.cos(radLat2) * Math.cos(radTheta)
      if (distance > 1)
        distance = 1
      end
    dist = Math.acos(distance)
    dist = (dist * 180) / Math::PI
    dist = dist * 60 * 1.1515
    # dist = Number(dist.toFixed(2))
  end
end
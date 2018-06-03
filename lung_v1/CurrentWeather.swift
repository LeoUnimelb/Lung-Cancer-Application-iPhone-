//  CurrentWeather.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swfit is used to create a datastructure to store and process the
 *  data in JSON format we fetched from weather prediction website.
 */

import Foundation

class CurrentWeather{
  let temperature: Int?
  let humidity: Int?
  let quality: String?
  
  //create a data structure to store related info fetched from API
  struct WeatherKeys{
    static  let temperature = "temperature"
    static  let humidity = "humidity"
    static  let quality = "icon"
  }
  
  init(weatherDictionary:[String:Any]){
    //judge if we get the info we want and process them if needed
    if let temperatureFetch = weatherDictionary[WeatherKeys.temperature] as? Double
    {
      temperature=Int(temperatureFetch)
    }
    else {temperature = nil}
    
    
    if let humidityFetch = weatherDictionary[WeatherKeys.humidity] as? Double
    {
      humidity = Int(humidityFetch*100)
      
    }
    else {humidity = nil}
    
    quality = weatherDictionary[WeatherKeys.quality] as? String
    
  }
  
  
  //using API provided by https://darksky.net, fetched data is in json format listed as follow:
  
  /*
   {
   "latitude":37.8267,
   "longitude":-122.4233,
   "timezone":"America/Los_Angeles",
   "currently":{
   "time":1525136197,
   "summary":"Clear",
   "icon":"clear-day",
   "nearestStormDistance":6,
   "nearestStormBearing":110,
   "precipIntensity":0,
   "precipProbability":0,
   "temperature":59.52,
   "apparentTemperature":59.52,
   "dewPoint":44.98,
   "humidity":0.59,
   "pressure":1013.81,
   "windSpeed":9.4,
   "windGust":15.28,
   "windBearing":251,
   "cloudCover":0.05,
   "uvIndex":1,
   "visibility":9.76,
   "ozone":423.46
   },
   */
  
  
}


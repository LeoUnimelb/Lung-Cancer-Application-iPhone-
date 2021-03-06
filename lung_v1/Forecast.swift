//  Forecast.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swift is created to talk to the weather website use the API it provided to
 *  obtain local weather conditions
 */

import Foundation
import Alamofire

class Forecast{
  
   //This myAPIKey was generated by website when set up an account on it
    let myAPIKey: String
   //URl of the website
    let baseURL: URL?
    
    init(APIKey: String)
    {
        self.myAPIKey = APIKey
        baseURL = URL(string: "https://api.darksky.net/forecast/\(APIKey)")
    }
  
   //communite with server to get current, using info (latitude,longtitude) to identify current location
   //of mobile devices, use the data structure we defined in CurrentWeather.swift to store and process
   //the infomation we fetched
    func getWeather (latitude: Double, longtitude: Double,completion:@escaping(CurrentWeather?)->Void)
    {
        if let weatherURL = URL(string: "\(baseURL!)/\(latitude),\(longtitude)"){
            Alamofire.request(weatherURL).responseJSON(completionHandler: {(response) in
                if let jsonDictionary = response.result.value as? [String : Any]{
                //print(jsonDictionary)
                    if let currentDictionary = jsonDictionary["currently"] as? [String : Any]
                    {
                        let current = CurrentWeather(weatherDictionary: currentDictionary)
                        completion(current)
                    }
                    else {completion(nil)}
                }
            })
        }
        
    }
    
    
}

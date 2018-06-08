//
//  Location.swift
//  Test
//
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
//

import Foundation
import Alamofire

class Forecast{
    
    let myAPIKey: String
    let baseURL: URL?
  
    //class init
    init(APIKey: String)
    {
        self.myAPIKey = APIKey
        baseURL = URL(string: "https://api.darksky.net/forecast/\(APIKey)")
    }
  
    //get required data using Alamofire from API
    func getWeather (latitude: Double, longtitude: Double,completion:@escaping(CurrentWeather?)->Void)
    {
        if let weatherURL = URL(string: "\(baseURL!)/\(latitude),\(longtitude)"){
            Alamofire.request(weatherURL).responseJSON(completionHandler: {(response) in
              
                if let jsonDictionary = response.result.value as? [String : Any]{
                print(jsonDictionary)
                    //get latest weather info
                    if let currentDictionary = jsonDictionary["timezone"] as? [String : Any]
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

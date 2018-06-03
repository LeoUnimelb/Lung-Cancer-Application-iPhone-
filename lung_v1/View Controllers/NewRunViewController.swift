//  NewRunViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swfit corresponds to weather conditions feature, it is used to detect
 *  weather conditions in current location, if they exceeds the predefined thresholds,
 *  using pop out window to warn user.
 */

import UIKit
import CoreLocation
import MapKit

class NewRunViewController: UIViewController,CLLocationManagerDelegate{
  
  @IBOutlet weak var Tempeature: UILabel!
  @IBOutlet weak var Humidity: UILabel!
  @IBOutlet weak var Quality: UILabel!
  @IBOutlet weak var District: UILabel!
  
  // variables definition
  let locationManager:CLLocationManager = CLLocationManager()
  let key = "06da2f22cde472ab3d251fe07db2ee12"
  var currentWeather: Forecast!
  var xCoordinate: Double!
  var yCoordinate: Double!
  
  
  // Using location services and set the desired accuracy to best to get accurate information
  override func viewDidLoad() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 100
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    super.viewDidLoad()
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
     //get the newest location
     let currLocation:CLLocation = locations.last!
     //obtain current coordination
     let xCoordinate  = currLocation.coordinate.latitude
     let yCoordinate  = currLocation.coordinate.longitude
     //print("\(xCoordinate)\n")
     //print("\(yCoordinate)\n")
    
    //use functions defined in Forecast.swift to do weather prediction
    currentWeather = Forecast(APIKey: key)
    currentWeather.getWeather(latitude: -xCoordinate, longtitude: yCoordinate){(currentWeather) in
      if let currentWeather = currentWeather{
        DispatchQueue.main.async {
          self.District.text = "Melbourne"
          // set thresholds to warn user if current weather is unsuitable for exercise
          if let temperature = currentWeather.temperature{
           if currentWeather.temperature! > 90 || currentWeather.temperature! < 41
            {
              self.alert("Current Weather is not suitable for exercise.")
            }
            self.Tempeature.text="Temperature: \(temperature)℉"
          }else{
            self.Tempeature.text="Unable to update"
          }
          if let humudity = currentWeather.humidity{
            if currentWeather.humidity! > 80
            {
              self.alert("Current Weather is not suitable for exercise.")
            }
            self.Humidity.text="Humudity: \(humudity)%"
          }else{
            self.Humidity.text="Unable to update"
          }
          if let quality = currentWeather.quality{
            self.Quality.text="\(quality)"
          }else{
            self.Quality.text="Unable to update"
          }
        }
      }
    }
    
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
   
  }
  
  //define alert function to display the pop out window
  func alert(_ message:String){
    let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
    let cancel = UIAlertAction(title: "Continue Anyway", style: .destructive, handler: { (action) -> Void in })
    alert.addAction(cancel)
    self.present(alert, animated: true, completion: nil)
  }
  
}
  

  

  


  


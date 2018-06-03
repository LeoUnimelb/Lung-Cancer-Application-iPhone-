//  RunDetailsViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swfit corresponds to exercise tracking feature, it is used to track users' exercise data
 *  including distance, duration, upstairs, downstairs and steps. When tracking exercise,
 *  it can be switched between detail mode and map mode. Once user finishes exercise and
 *  presses save button, current exercise data are stored in database on server end as well as
 *  local database. After that, users can choose to continue to include thier physical conditions to
 *  help doctors better understand their conditions.
 */


import CoreMotion
import UIKit
import CoreLocation
import MapKit
import LTMorphingLabel
import OHMySQL

class RunDetailsViewController: UIViewController {
  
//UI for map version
  @IBOutlet weak var Map: MKMapView!
  @IBOutlet weak var Distance1: UILabel!
  @IBOutlet weak var Timer1: LTMorphingLabel!
  @IBOutlet var DistanceStack: UIView!
  @IBOutlet weak var TimerStack: UIStackView!
  
//UI for non-map version
  @IBOutlet weak var MapButton: UIButton!
  @IBOutlet weak var Distance2: UIStackView!
  @IBOutlet weak var Timer2: UIStackView!
  @IBOutlet weak var Speed2: UIStackView!
  @IBOutlet weak var Step: UIStackView!
  @IBOutlet weak var Upstairs: UIStackView!
  @IBOutlet weak var Downstairs: UIStackView!
  @IBOutlet weak var DistanceLabel: UILabel!
  @IBOutlet weak var TimerLabel: UILabel!
  @IBOutlet weak var SpeedLabel: UILabel!
  @IBOutlet weak var StepLable: UILabel!
  @IBOutlet weak var UpstairsLable: UILabel!
  @IBOutlet weak var DownstairsLabel: UILabel!
  @IBOutlet weak var DB: UIButton!
  @IBOutlet weak var StartButton: UIButton!
  @IBOutlet weak var ResumeButton: UIButton!
  @IBOutlet weak var StopButton: UIButton!
  @IBOutlet weak var SaveButton: UIButton!
    
  // variables definition
  private var exercise: Exercise?
  private let locationManager = LocationManager.shared
  private var locationList: [CLLocation] = []
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  var pedometerStart: NSDate!
  let pedometer = CMPedometer()
  var timerCount: Int = 0
  weak var timer: Timer?
  var db:SQLiteDB!
  var exerciseDate: NSDate!
  var sqlSave : String = ""
  //variables used to accumulated statistics after stop
  var stepCount: Int = 0
  var steps:Int = 0
  var previousSteps: Int = 0
  var isPrevious: Bool = true
  var upstairsCount: Int = 0
  var upstairs:Int = 0
  var previousUpstairs: Int = 0
  var downstairsCount: Int = 0
  var downstairs:Int = 0
  var previousDownstairs: Int = 0
  var userID: String!
 
  //Button functions definition
  
  //Back: switch from map mode to detail mode
  @IBAction func Back(_ sender: UIButton) {
    MapButton.isHidden = false
    DB.isHidden = true
    Map.isHidden = true
    DistanceStack.isHidden = true
    TimerStack.isHidden = true
    Distance2.isHidden = false
    Timer2.isHidden = false
    Speed2.isHidden = false
    Step.isHidden = false
    Upstairs.isHidden = false
    Downstairs.isHidden = false
    StopButton.isHidden = false
  }
  
    
   //Start: start track
    @IBAction func Start(_ sender: UIButton) {
    StopButton.isHidden = false
    StartButton.isHidden = true
    pedometerStart = NSDate()
    Map.removeOverlays(Map.overlays)
    locationList.removeAll()
    startLocationUpdates()
    startPedometerUpdates()
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    
    }
  
    //start GPS services
    private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
    }
  
    //Map: switch from detail mode to map mode
    @IBAction func Map(_ sender: UIButton) {
        Map.isHidden = false
        Distance2.isHidden = true
        Timer2.isHidden = true
        Speed2.isHidden = true
        Step.isHidden = true
        Upstairs.isHidden = true
        Downstairs.isHidden = true
        ResumeButton.isHidden = true
        StopButton.isHidden = true
        SaveButton.isHidden = true
        StartButton.isHidden = true
        DistanceStack.isHidden = false
        TimerStack.isHidden = false
        MapButton.isHidden = true
        DB.isHidden = false
    }
    
   //Stop: pause the GPS services, once stop
   // user can choose to resume current exercise or save it
    @IBAction func Stop(_ sender: UIButton) {
      ResumeButton.isHidden = false
      StopButton.isHidden = true
      SaveButton.isHidden = false 
      self.isPrevious = true
      self.stepCount = self.steps
      self.downstairsCount = self.downstairs
      self.upstairsCount = self.upstairs
      locationManager.stopUpdatingLocation()
      timer?.invalidate()
      self.pedometer.stopUpdates()
      self.SpeedLabel.text = "0"
    }
  
   //Resume: Continue exercise, restart the paused GPS services
    @IBAction func resume(_ sender: UIButton) {
      locationManager.startUpdatingLocation()
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
      self.startPedometerUpdates()
      StopButton.isHidden = false
      SaveButton.isHidden = true
      ResumeButton.isHidden = true
      
    }
    
   //Save: save current data both in server end and in local.
    @IBAction func Save(_ sender: UIButton) {
      exerciseDate = NSDate()
      let dateFormat: DateFormatter = DateFormatter()
      dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
      let exerciseDateF = dateFormat.string(from:exerciseDate as Date) //fomulate obtained NSDate().
      let distanceSave = Int(self.distance.value)
      let stepsSave = self.steps
      let upstairsSave = self.upstairs
      let downstairsSave = self.downstairs
      let durationSave = self.timerCount
      
      //print(upstairsSave)
      //print(downstairsSave)
      //print(durationSave)     -----Test Use
      //print(exerciseDateF)
      //print(distanceSave)
      
      
      //connect to server-side database
      let user = OHMySQLUser(userName: "leo", password: "1994813xl", serverName:"test.carm2gv6dkhr.ap-southeast-2.rds.amazonaws.com", dbName: "test", port: 3306, socket: "")
      let coordinator = OHMySQLStoreCoordinator(user: user!)
      //coordinator.encoding = .UTF8MB4
      coordinator.connect()
      let context = OHMySQLQueryContext()
      context.storeCoordinator = coordinator
      
      
      //get pid from local database
      let sql_id = "select * from user"
      let result = db.query(sql: sql_id)
      print(result)
      if result.count>0
      {
        let a = result[0]
        if let b = a["uid"]{
          userID = b as! String
          print(userID)
        }
      }
      
      //store data in the server
      let query = OHMySQLQueryRequestFactory.insert("patient_exercise", set: ["pid": "\(userID as! String)", "exerciseDate": "\(exerciseDateF)"])
      try? context.execute(query)
      
      //use sqlite to store the exercise data locally
      let accumulatorDistance = db.query(sql: "SELECT distance,step,duration,upstairs,downstarirs FROM userExercise WHERE exerciseDate='\(exerciseDateF)' ")
      if accumulatorDistance.count>0{
        print("\(accumulatorDistance)")
        let row = accumulatorDistance[0]
        if let value1 = row["distance"] , let value2 = row["step"], let value3 = row["upstairs"], let value4 = row["downstarirs"],let value5 = row["duration"]
        {
          sqlSave = "INSERT OR REPLACE INTO userExercise (exerciseDate,distance,step,duration,upstairs,downstarirs) VALUES ('\(exerciseDateF)',\(distanceSave)+\(value1),\(stepsSave )+\(value2),\(durationSave)+\(value5),\(upstairsSave)+\(value3),\(downstairsSave)+\(value4))"
        }
        _=db.execute(sql: sqlSave)
        let d = db.query(sql: "select * from userExercise")
        print("Query Result ：\(d)")
      }
      else
      {
        sqlSave = "INSERT INTO userExercise (exerciseDate,distance,step,duration,upstairs,downstarirs) VALUES ('\(exerciseDateF)',\(distanceSave),\(stepsSave ),\(durationSave),\(upstairsSave),\(downstairsSave))"
        _=db.execute(sql: sqlSave)
        let d = db.query(sql: "select * from userExercise")
        print("Query Result： \(d)")
      }
      
      
      //after successfully saved , use a pop out window to inform user
      let alertController = UIAlertController(title: "Exercise data saved successfully!",
                                              message: "Add physical condition？", preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Yes", style: .cancel, handler: {
        action in
        self.performSegue(withIdentifier: "recordState", sender:nil)
      })
      let okAction = UIAlertAction(title: "No", style: .default, handler: {
        action in
          self.performSegue(withIdentifier: "back", sender:nil)
      })
      alertController.addAction(cancelAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
      
    }
  

  
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Map.delegate = self
        Map.isHidden = true
        DistanceStack.isHidden = true
        TimerStack.isHidden = true
        ResumeButton.isHidden = true
        StopButton.isHidden = true
        SaveButton.isHidden = true
        DB.isHidden = true
        db = SQLiteDB.shared
  }
  
   override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
   }

  
  //use onborad pedometer to obtain info incluing steps, upstairs and downstairs
  func startPedometerUpdates() {
    //check weather device support pedometer, not supported on IOS simulators
    guard CMPedometer.isStepCountingAvailable() else {
      self.StepLable.text = "Unsupported"
      return
    }
    
    self.pedometer.startUpdates (from: pedometerStart as Date, withHandler: { pedometerData, error in
      guard error == nil else {
        print(error!)
        return
      }
      
      var stepDisplay = ""
      //get data and judge whether this is the first time update, if not, exclude the
      //previous results in case of repetitive accumulations.
      if let Steps = pedometerData?.numberOfSteps {
        if ((self.stepCount != 0) && (self.isPrevious == true)){
          self.isPrevious = false
          self.previousSteps = Int(truncating: Steps) - self.stepCount
        }
        self.steps = Int(truncating: Steps) - self.previousSteps
        stepDisplay += "\(self.steps)"
      }
      
      var upstairsDisplay = ""
      if let Upstairs = pedometerData?.floorsAscended {
        if ((self.upstairsCount != 0) && (self.isPrevious == true)){
          self.isPrevious = false
          self.previousUpstairs = Int(truncating: Upstairs) - self.upstairsCount
        }
        self.upstairs = Int(truncating: Upstairs) - self.previousUpstairs
        upstairsDisplay += "\(self.upstairs)"
      }
      
      var downstairsDisplay = ""
      if let Downstairs = pedometerData?.floorsDescended {
        if ((self.downstairsCount != 0) && (self.isPrevious == true)){
          self.isPrevious = false
          self.previousDownstairs = Int(truncating: Downstairs) - self.downstairsCount
        }
        self.downstairs = Int(truncating: Downstairs) - self.previousDownstairs
        downstairsDisplay += "\(self.downstairs)"
      }
      
      //Updating dispaly, in order to display the correct and real-time results,
      //work must be allocated to main thread and without waiting for finish
      DispatchQueue.main.async{
        self.StepLable.text = stepDisplay
        self.UpstairsLable.text = upstairsDisplay
        self.DownstairsLabel.text = downstairsDisplay
      }
    })
  }
  
  //definea a timer to achieve time counting fucntion
  @objc func UpdateTimer() {
  timerCount = timerCount + 1
  var time = timerCount
  let hour = Int(time/3600)
  time = time-hour*3600
  let minute = Int(time/60)
  time = time-minute*60
  let second = time
  let hourDisplay = String(format: "%02d", hour)
  let minDisplay = String(format: "%02d", minute)
  let secDisplay = String(format: "%02d", second)
  let Formlize = MeasurementFormatter()
  Formlize.unitStyle = .medium
  let distanceDisplay = Formlize.string(from: distance)
  let speedDisplay = String (format: "%.2f", Double(distance.value/Double(timerCount)))
  self.TimerLabel.text = String("\(hourDisplay):\(minDisplay):\(secDisplay)")
  self.Timer1.text = String("\(hourDisplay):\(minDisplay):\(secDisplay)")
  self.Distance1.text = String("\(distanceDisplay)")
  self.DistanceLabel.text = String("\(distanceDisplay)")
  self.SpeedLabel.text = String("\(speedDisplay)")
}
  
  func setNormalDefault(key:String, value:AnyObject?){
    if value == nil {
      UserDefaults.standard.removeObject(forKey: key)
    }
    else{
      UserDefaults.standard.set(value, forKey: key)
      UserDefaults.standard.synchronize()
    }
  }
  
 func removeNormalUserDefault(key:String?){
    if key != nil {
      UserDefaults.standard.removeObject(forKey: key!)
      UserDefaults.standard.synchronize()
    }
  }
  
 func getNormalDefult(key:String)->AnyObject?{
  return UserDefaults.standard.value(forKey: key) as AnyObject
  }
  
}

//extend CLLocationManagerDelegate to :
//1. Caculate the total distance by accumulation
//2. Update route on map
extension RunDetailsViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 30 && abs(howRecent) < 15 else { continue }
      
      if let lastLocation = locationList.last {
        let movement = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: movement, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        Map.add(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
        Map.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}

//extend MKMapViewDelegate to draw exercise routes on map
extension RunDetailsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .black
    renderer.lineWidth = 6
    return renderer
  }
}






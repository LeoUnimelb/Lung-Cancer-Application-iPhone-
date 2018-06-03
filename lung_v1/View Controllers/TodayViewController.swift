
//  TodayViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to daily progress checking feature, it enables user to check
 *  his detailed daily progress and visualizes these data using charts and animiated progress bars
 *  to better demonstate them.
 */





import UIKit

class TodayViewController: UIViewController {

  @IBOutlet weak var Distance: UILabel!
  @IBOutlet weak var StepLabek: UILabel!
  @IBOutlet weak var Upstairs: UILabel!
  @IBOutlet weak var Downstairs: UILabel!
  @IBOutlet weak var Duration: UILabel!
  @IBOutlet weak var DiagramButton: UIButton!
  @IBOutlet weak var View1: UIView!
  @IBOutlet weak var Info: UILabel!
  
  //variable defination
  let shapeLayer = CAShapeLayer()
  var queryDate: NSDate!
  var target : Double!
  var myDistance : Int!
  var db:SQLiteDB!
  var ratio: Double!
  var userID: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //open DB and create table when 1st use
    db=SQLiteDB.shared
    _ = db.open()
    Info.isHidden = true
    //get today's exercise data from database
    queryDate = NSDate()
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
    let queryDateF = dateFormat.string(from:queryDate as Date)
    
    //get user id from local database
    let sql_id = "select * from user"
    let result = db.query(sql: sql_id)
    if result.count>0
    {
      let a = result[0]
      if let b = a["uid"]{
        userID = b as! String
      }
    }
    
    let todayData = db.query(sql: "SELECT distance,step,duration,upstairs,downstarirs FROM userExercise WHERE exerciseDate='\(queryDateF)' ")
    if todayData.count>0{
      print("\(todayData)")
      let row = todayData[0]
      if let value1 = row["distance"] , let value2 = row["step"], let value3 = row["upstairs"], let value4 = row["downstarirs"],let value5 = row["duration"]
      {
        var time = value5 as! Int
        let hour = Int(time/3600)
        time = time-hour*3600
        let minute = Int(time/60)
        time = time-minute*60
        let second = time
        myDistance = value1 as! Int
        Distance.text = "\(value1)M"
        StepLabek.text = "\(value2)"
        Upstairs.text = "\(value3)"
        Downstairs.text = "\(value4)"
        Duration.text = "\(hour)h\(minute)m\(second)s"
      }
    }
    else
    {
      myDistance = 0
      Distance.text = "0"
      StepLabek.text = "0"
      Upstairs.text = "0"
      Downstairs.text = "0"
      Duration.text = "0"
    }
    
    //fetch target
    let sqlWGoal = "SELECT * FROM user_AG WHERE uid = '\(userID)'"
    let weekResult = db.query(sql: sqlWGoal)

    if weekResult.count > 0{
      let a = weekResult[0]
      if let value = a["goal"]
      {
        let Weektarget = value as! Int
        target=Double(Weektarget)/7.0
      }
    }
    else{target = 1000}
    
    if (target==0) {ratio = 0}
    else {ratio = Double(myDistance)/target}
    if ratio>=1 {ratio=1}
    let ratioPercent = Int(ratio*100)
    Info.text = "Achieve \(ratioPercent)% Of Goal"
    
    
    //draw the aniamted progress bar
    let center = View1.center
    //create track layer
    let trackLayer = CAShapeLayer()
    let tPath = UIBezierPath(arcCenter: center, radius:110, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer.path = tPath.cgPath
    trackLayer.strokeColor = UIColor.white.cgColor
    trackLayer.lineWidth = 9
    trackLayer.lineCap = kCALineCapRound
    trackLayer.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer)
    
    //drawing the progress bar based on complete percentage
    let cPath = UIBezierPath(arcCenter: center, radius:110, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(ratio)-CGFloat.pi/2, clockwise: true)
    shapeLayer.path = cPath.cgPath
    shapeLayer.strokeColor = UIColor.green.cgColor
    shapeLayer.lineWidth = 9
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeEnd = 0
    view.layer.addSublayer(shapeLayer)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
  }
  
  // define the annimation when tap the screen
  @objc private func Tap(){
    let banimation = CABasicAnimation(keyPath:"strokeEnd")
    banimation.toValue = 1
    banimation.duration = 2
    banimation.fillMode = kCAFillModeForwards
    banimation.isRemovedOnCompletion = false
    shapeLayer.add(banimation, forKey: "Day")
    Info.isHidden = false
  }
  
}


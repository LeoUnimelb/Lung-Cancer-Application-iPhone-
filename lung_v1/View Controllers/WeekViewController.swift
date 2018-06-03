
//  TodayViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to weekly progress checking feature, it enables user to check
 *  his detailed weekly progress incluing total complete percentage of the week and a break down analysis
 *  of complete percentage from Mon to Sun. Also, it visualizes these data using charts and animiated progress bars
 *  to better demonstate them.
 */


import UIKit

class WeekViewController: UIViewController {
  
  @IBOutlet weak var three: UIView!
  @IBOutlet weak var five: UIView!
  @IBOutlet weak var one: UIView!
  @IBOutlet weak var six: UIView!
  @IBOutlet weak var two: UIView!
  @IBOutlet weak var seven: UIView!
  @IBOutlet weak var four: UIView!
  @IBOutlet weak var Week: UIView!
  @IBOutlet weak var tDistance: UILabel!
  @IBOutlet weak var Goal: UILabel!
  @IBOutlet weak var Text: UILabel!
  @IBOutlet weak var dRemain: UILabel!
  
  //variable defination
  let shapeLayer = CAShapeLayer()
  var weekDistance: [Int]!
  var weekGoal: [Int]!
  var barRatio: [Double]!
  var totalDistance: Int!
  var totalTarget : Int!
  var queryDate: NSDate!
  var db:SQLiteDB!
  var exerciseDate: NSDate!
  var userID: String!
  var ratio: Double!
  
  override func viewDidLoad() {
    dRemain.isHidden = true
    Text.isHidden = true
    barRatio = [0,0,0,0,0,0,0,0,0]
    weekDistance = [0,0,0,0,0,0,0,0,0]
    weekGoal = [0,0,0,0,0,0,0,0,0]
    totalTarget = 0
    totalDistance = 0
    queryDate = NSDate()
    db = SQLiteDB.shared
    
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
    
    //query weekly data and store
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
    let queryDateF = dateFormat.string(from:queryDate as Date)
    let sqlQuery = " SELECT * FROM userData5 WHERE DATE(exerciseDate) >= DATE('now', 'weekday 1', '-7 days') ORDER BY DATE(exerciseDate) ASC"
    let sqlWGoal = "SELECT * FROM user_AG WHERE uid = '\(userID)'"
    
    //get weekly distance target
    let weekResult1 = db.query(sql: sqlWGoal)
    print("\(weekResult1)")
    if weekResult1.count > 0{
      let a = weekResult1[0]
      if let value = a["goal"]
      {
        totalTarget = value as! Int
      }
    }
    else {totalTarget = 7000}
    
    //update week goal
    for i in 0...8{
      weekGoal[i] = totalTarget/7
    }
    
    let weekResult = db.query(sql: sqlQuery)
    //print("\(weekResult)") Test Use
    
    
    let dayOfWeek = weekResult.count
    if dayOfWeek > 0 {
      for i in 1...dayOfWeek {
        let row = weekResult[i-1]
        if let value = row["distance"]
        {
          //print("\(value)")
          weekDistance[i-1] = value as! Int
        }
      }
    }
    
    /*
    //test
    for i in 1...9 {
      print("\(weekDistance[i-1])")
    }
    */
    
    
    //calculate progress bar ratio
    for i in 1...weekDistance.count{
      barRatio[i-1] = Double(weekDistance[i-1])/Double(weekGoal[i-1])
      if barRatio[i-1]>1 {barRatio[i-1]=1}
      if barRatio[i-1]==0 {barRatio[i-1]=1}
     }
    
    //cacluate totoal distance
    for i in 1...weekDistance.count{
      totalDistance = totalDistance + weekDistance[i-1]
    }
    
    if totalTarget==0 {ratio = 0}
    else {ratio = Double(totalDistance)/Double(totalTarget)}
    
    //show data
    tDistance.text = "\(totalDistance as Int)M"
    Goal.text = "\(Double(totalTarget)/1000)KM"
    Text.text = "Achieve \(Int(ratio*100))% of goal"
    let left = Double(totalTarget)/1000-Double(totalDistance)/1000
    if (left>=0){dRemain.text = "\(left)KM Left this week"}
    else {dRemain.text = "0KM Left this week"}
    
    
    //Draw the total progress bar
    let center0 = Week.center
    //create track layer
    let trackLayer0 = CAShapeLayer()
    
    let tPath0 = UIBezierPath(arcCenter: center0, radius:110, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer0.path = tPath0.cgPath
    trackLayer0.strokeColor = UIColor.white.cgColor
    trackLayer0.lineWidth = 9
    trackLayer0.lineCap = kCALineCapRound
    trackLayer0.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer0)
    
    
    let cPath = UIBezierPath(arcCenter: center0, radius:110, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(ratio)-CGFloat.pi/2, clockwise: true)
    shapeLayer.path = cPath.cgPath
    shapeLayer.strokeColor = UIColor.green.cgColor
    shapeLayer.lineWidth = 9
    shapeLayer.lineCap = kCALineCapRound
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeEnd = 0
    view.layer.addSublayer(shapeLayer)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
  
  

    
    //Draw progress bar from Mon to Sun
    let center = one.center
    let trackLayer = CAShapeLayer()
    if weekDistance[0] == 0{
    let tPath = UIBezierPath(arcCenter: center, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer.path = tPath.cgPath
    trackLayer.strokeColor = UIColor.white.cgColor
    }
    else{
      let tPath = UIBezierPath(arcCenter: center, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[0])-CGFloat.pi/2, clockwise: true)
      trackLayer.path = tPath.cgPath
      trackLayer.strokeColor = UIColor.green.cgColor
    }
    trackLayer.lineWidth = 3.5
    trackLayer.lineCap = kCALineCapRound
    trackLayer.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer)
    
    
    
    let center2 = two.center
    let trackLayer2 = CAShapeLayer()
    if weekDistance[1] == 0
    {
    let tPath2 = UIBezierPath(arcCenter: center2, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer2.path = tPath2.cgPath
    trackLayer2.strokeColor = UIColor.white.cgColor
    }
    else{
      let tPath2 = UIBezierPath(arcCenter: center2, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[1])-CGFloat.pi/2, clockwise: true)
      trackLayer2.path = tPath2.cgPath
      trackLayer2.strokeColor = UIColor.green.cgColor
      
    }
    trackLayer2.lineWidth = 3.5
    trackLayer2.lineCap = kCALineCapRound
    trackLayer2.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer2)
    
    let center3 = three.center
    let trackLayer3 = CAShapeLayer()
    if weekDistance[2] == 0
    {
    let tPath3 = UIBezierPath(arcCenter: center3, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer3.path = tPath3.cgPath
    trackLayer3.strokeColor = UIColor.white.cgColor
    }
    else
    {
      let tPath3 = UIBezierPath(arcCenter: center3, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[2])-CGFloat.pi/2, clockwise: true)
      trackLayer3.path = tPath3.cgPath
      trackLayer3.strokeColor = UIColor.green.cgColor
    }
    trackLayer3.lineWidth = 3.5
    trackLayer3.lineCap = kCALineCapRound
    trackLayer3.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer3)
    
    let center4 = four.center
    let trackLayer4 = CAShapeLayer()
    if weekDistance[3] == 0
    {
    let tPath4 = UIBezierPath(arcCenter: center4, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer4.path = tPath4.cgPath
    trackLayer4.strokeColor = UIColor.white.cgColor
    }
    else
    {
      let tPath4 = UIBezierPath(arcCenter: center4, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[3])-CGFloat.pi/2, clockwise: true)
      trackLayer4.path = tPath4.cgPath
      trackLayer4.strokeColor = UIColor.green.cgColor
    }
    trackLayer4.lineWidth = 3.5
    trackLayer4.lineCap = kCALineCapRound
    trackLayer4.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer4)
    
    let center5 = five.center
    let trackLayer5 = CAShapeLayer()
    if weekDistance[4] == 0
    {
    let tPath5 = UIBezierPath(arcCenter: center5, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer5.path = tPath5.cgPath
    trackLayer5.strokeColor = UIColor.white.cgColor
    }
    else
    {
      let tPath5 = UIBezierPath(arcCenter: center5, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[4])-CGFloat.pi/2, clockwise: true)
      trackLayer5.path = tPath5.cgPath
      trackLayer5.strokeColor = UIColor.green.cgColor
    }
    trackLayer5.lineWidth = 3.5
    trackLayer5.lineCap = kCALineCapRound
    trackLayer5.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer5)
    
    let center6 = six.center
    let trackLayer6 = CAShapeLayer()
    if weekDistance[5] == 0
    {
    let tPath6 = UIBezierPath(arcCenter: center6, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer6.path = tPath6.cgPath
    trackLayer6.strokeColor = UIColor.white.cgColor
    }
    else
    {
      let tPath6 = UIBezierPath(arcCenter: center6, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[5])-CGFloat.pi/2, clockwise: true)
      trackLayer6.path = tPath6.cgPath
      trackLayer6.strokeColor = UIColor.green.cgColor
    }
    trackLayer6.lineWidth = 3.5
    trackLayer6.lineCap = kCALineCapRound
    trackLayer6.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer6)
    
    let center7 = seven.center
    let trackLayer7 = CAShapeLayer()
    if weekDistance[6] == 0
    {
    let tPath7 = UIBezierPath(arcCenter: center7, radius:15, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    trackLayer7.path = tPath7.cgPath
    trackLayer7.strokeColor = UIColor.white.cgColor
    }
    else
    {
      let tPath7 = UIBezierPath(arcCenter: center7, radius:15, startAngle: -CGFloat.pi/2, endAngle: 2*CGFloat.pi*CGFloat(barRatio[5])-CGFloat.pi/2, clockwise: true)
      trackLayer7.path = tPath7.cgPath
      trackLayer7.strokeColor = UIColor.green.cgColor
    }
    trackLayer7.lineWidth = 3.5
    trackLayer7.lineCap = kCALineCapRound
    trackLayer7.fillColor = UIColor.clear.cgColor
    view.layer.addSublayer(trackLayer7)
    //PART: DRAW the weekly progress bar
    super.viewDidLoad()
    }
  
  // define the annimation when tap the screen
  @objc private func Tap(){
    let banimation = CABasicAnimation(keyPath:"strokeEnd")
    banimation.toValue = 1
    banimation.duration = 2
    banimation.fillMode = kCAFillModeForwards
    banimation.isRemovedOnCompletion = false
    shapeLayer.add(banimation, forKey: "Day")
    Text.isHidden = false
    dRemain.isHidden = false
  }
}



//  TodayChartViewController.swift
//  Created by XILE on 7/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swift is used to visualize the data with charts, library SwiftCharts is used.
 */

import UIKit
import SwiftCharts

class TodayChartViewController: UIViewController {

  @IBOutlet weak var myStep: UILabel!
  @IBOutlet weak var upStairs: UILabel!
  @IBOutlet weak var downStairs: UILabel!

  //variable defination
  var chartview : BarsChart!
  var db: SQLiteDB!
  var myDistance: Int!
  var queryDate: NSDate!
  var goal: Int!
  var userID: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    db=SQLiteDB.shared
    _ = db.open()
    queryDate = NSDate()
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
    let queryDateF = dateFormat.string(from:queryDate as Date)
    let todayData = db.query(sql: "SELECT distance,step,duration,upstairs,downstarirs FROM userData5 WHERE exerciseDate='\(queryDateF)' ")
    if todayData.count>0{
      print("\(todayData)")
      let row = todayData[0]
      if let value1 = row["distance"] , let value2 = row["step"], let value3 = row["upstairs"], let value4 = row["downstarirs"]
      {
        myDistance = value1 as! Int
        myStep.text = "\(value2)"
        upStairs.text = "\(value3)"
        downStairs.text = "\(value4)"
      }
    }
    else
    {
      myDistance = 0
      myStep.text = "0"
      upStairs.text = "0"
      downStairs.text = "0"
    }
    
    
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
    
    let sqlWGoal = "SELECT * FROM user_AG WHERE uid = '\(userID)'"
    let weekResult = db.query(sql: sqlWGoal)
    
    if weekResult.count > 0{
      let a = weekResult[0]
      if let value = a["goal"]
      {
        let Weektarget = value as! Int
        goal=Weektarget/7
      }
    }
    else{goal = 1000}

    let chartConfig = BarsChartConfig(
      valsAxisConfig: ChartAxisConfig(from: 0, to: 3000, by: 500)
    )
    
    let frame = CGRect(x:20, y:200, width: 300, height: 250)
    let chart = BarsChart(
      frame: frame,
      chartConfig: chartConfig,
      xTitle: "",
      yTitle: "Distance",
      bars: [("Progress",Double(myDistance)),("Target",Double(goal))],
      color: UIColor.darkGray,
      barWidth: 60,
      animDuration: 1,
      animDelay: 1,
      horizontal: false
    )
    self.view.addSubview(chart.view)
    self.chartview = chart
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}


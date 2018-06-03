
//  WeekChartViewController.swift
//  Created by XILE on 7/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swift is used to visualize the data with charts, library SwiftCharts is used.
 */

import UIKit
import SwiftCharts

class WeekChartViewController: UIViewController {
  
  var chartview : BarsChart!
  var db: SQLiteDB!
  var weekDistance: [Int]!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    weekDistance = [0,0,0,0,0,0,0,0,0]
    db=SQLiteDB.shared
    _ = db.open()
    let sqlQuery = " SELECT * FROM userExercise WHERE DATE(exerciseDate) >= DATE('now', 'weekday 1', '-7 days') ORDER BY DATE(exerciseDate) ASC"
    let weekResult = db.query(sql: sqlQuery)
    print("\(weekResult)")
    let dayOfWeek = weekResult.count
    if dayOfWeek > 0 {
      for i in 1...dayOfWeek {
        let row = weekResult[i-1]
        if let value = row["distance"]
        {
          weekDistance[i-1] = value as! Int
        }
      }
    }
    else {
      for i in 0...8 {weekDistance[i]=0}
    }
    
    let chartConfig = BarsChartConfig(
      valsAxisConfig: ChartAxisConfig(from: 0, to: 5000, by: 500)
    )
    
    let a = weekDistance[0] as Int
    let b = weekDistance[1] as Int
    let c = weekDistance[2] as Int
    let d = weekDistance[3] as Int
    let e = weekDistance[4] as Int
    let f = weekDistance[5] as Int
    let g = weekDistance[6] as Int
    
    let frame = CGRect(x:15, y:130, width: 300, height: 390)
    let chart = BarsChart(
      frame: frame,
      chartConfig: chartConfig,
      xTitle: "",
      yTitle: "Distance",
      bars: [("Mon",Double(a)),("Tue",Double(b)),("Wed",Double(c)),("Thu",Double(d)),("Fri",Double(e)),("Sat",Double(f)),("Sun",Double(g))],
      color: UIColor.darkGray,
      barWidth: 15,
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


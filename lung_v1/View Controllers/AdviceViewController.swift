
//  AdviceViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to advice check and target set/reset feature, it checks whether doctors give
 *  new advice for current weekly exercise program. It also enable users to set/reset target their weekly
 *  targets based on doctors' advice.
 */

import UIKit
import OHMySQL

class AdviceViewController:UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{
  @IBOutlet weak var Advice: UILabel!
  @IBOutlet weak var myPicker: UIPickerView!
  @IBOutlet weak var Goal: UILabel!
  @IBOutlet weak var UserImage: UIImageView!
  @IBOutlet weak var docImage: UIImageView!
  
  //variable defination
  var first:String!
  var sec:String!
  var firstDigit: [String] = Array()
  var secDigit: [String] = Array()
  var db:SQLiteDB!
  var goalDate: NSDate!
  var goalDate1: NSDate!
  var userID: String!
  

  //Based on users' selction on scroll picker, set/reset weekly target and update the local database
  @IBAction func Set(_ sender: UIButton) {
      let a = first+sec
      let b = Int(a)!*100
      goalDate = NSDate()
      let dateFormat: DateFormatter = DateFormatter()
      dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
      let goalDateF = dateFormat.string(from:goalDate as Date)
      let sqlSET = "INSERT OR REPLACE INTO user_AG (uid,goal) VALUES ('\(userID)',\(b))"
      db.execute(sql: sqlSET)
      /* testing code
      let sqltest = "select * from userGoal"
      let g = db.query(sql: sqltest)
      print("\(g)")
       */
    
    //everytime after seting/resteing goal, send a response to doctor
    let user = OHMySQLUser(userName: "leo", password: "1994813xl", serverName:"test.carm2gv6dkhr.ap-southeast-2.rds.amazonaws.com", dbName: "test", port: 3306, socket: "")
    let coordinator = OHMySQLStoreCoordinator(user: user!)
    //coordinator.encoding = .UTF8MB4
    coordinator.connect()
    let context = OHMySQLQueryContext()
    context.storeCoordinator = coordinator
    let query = OHMySQLQueryRequestFactory.update("patient_advice", set: ["response":"Got it, goal set as \(b)M"],condition:" pid = '\(userID as! String)' and adviceDate = '\(goalDateF)'")
     try? context.execute(query)
    
      let alert = UIAlertController(title: "Goal set successfully", message: "Your goal of this week has been set to \(first as! String).\(sec as! String) KM", preferredStyle:.alert)
      alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      Advice.text = "Got it, I've set this week's goal as \(first as! String).\(sec as! String)Km."
      UserImage.isHidden = false
      docImage.isHidden = true
    
    
  }
  
  
  //Define a scroll picker view to enable user do selection using it
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return firstDigit.count
    }
    return secDigit.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return firstDigit[row]
    }
    return secDigit[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    first = firstDigit[pickerView.selectedRow(inComponent: 0)]
    sec = firstDigit[pickerView.selectedRow(inComponent: 1)]
    Goal.text = "You have select \(first as! String ).\(sec as! String ) KM for this week"
  }
    
  override func viewDidLoad() {
    UserImage.isHidden = true
    db=SQLiteDB.shared
    _ = db.open()
    
    goalDate1 = NSDate()
    let dateFormat: DateFormatter = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
    let goalDateF1 = dateFormat.string(from:goalDate1 as Date)
    
    //get user id from local database and use it to fetch the corresponding exercise target in the server
    let sql_id = "select * from user"
    let result = db.query(sql: sql_id)
    if result.count>0
    {
      let a = result[0]
      if let b = a["uid"]{
        userID = b as! String
        //print("!!!\(userID as! String)!!!") test
      }
    }
    
    //Connect to server to check if there is new advice given by doctors and update display
    let user = OHMySQLUser(userName: "leo", password: "1994813xl", serverName:"test.carm2gv6dkhr.ap-southeast-2.rds.amazonaws.com", dbName: "test", port: 3306, socket: "")
    let coordinator = OHMySQLStoreCoordinator(user: user!)
    //coordinator.encoding = .UTF8MB4
    coordinator.connect()
    let context = OHMySQLQueryContext()
    context.storeCoordinator = coordinator
    let querySql = OHMySQLQueryRequestFactory.select("patient_advice", condition:" pid = '\(userID as! String)' and adviceDate = '\(goalDateF1)'")
    let response = try? context.executeQueryRequestAndFetchResult(querySql)
    print("\(response)")
    if (response?.count)!>0{
      let b = response![0]
      if let value = b["advice"]{Advice.text = value as! String}
    }
    myPicker.dataSource = self
    myPicker.delegate = self
    
    for i in 0...35{
      firstDigit.append("\(i)")
    }
    for i in 0...9{
      secDigit.append("\(i)")
    }
    super.viewDidLoad()
  }
  
}

//  HomeViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*  This .swfit corresponds to main page, after successfully login,
 *  if this is the first time user uses this application, it will
 *  create new tables needed in local databse.
 */


import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController {
  
  @IBOutlet weak var Welcome: UILabel!
  
  // variables definition
  var name: String!
  var db:SQLiteDB!
    
  override func viewDidLoad() {
    super.viewDidLoad()

    //open DB, creating needed tables if it is the 1st use
    db=SQLiteDB.shared
    _ = db.open()
    
    //create tables
    let sqlCrateTable1 = "create table if not exists userExercise(exerciseDate date primary key,upstairs Int(8),downstarirs Int(8),step Int(8), distance Int(8),duration Int(8))"
    _ = db.execute(sql: sqlCrateTable1)
    
    let sqlCrateTable2 = "create table if not exists userCondition(uid integer primary key,heartRate varchar(8),respiratoryRate varchar(8),feel varchar(100),conditionDate date)"
    _ = db.execute(sql: sqlCrateTable2)
    
    let sqlCrateTable3 = "create table if not exists user(uid interger primary key)"
    _ = db.execute(sql: sqlCrateTable3)
    
    let sqlCrateTable4 = "create table if not exists user_AG(uid interger primary key, goal Int(8))"
    _ = db.execute(sql: sqlCrateTable4)
    
    /* Test use
    let sqlQ = "select * from userInfo"
    let b = db.query(sql: sqlQ)
    print("\(b)")
    */
    
    //Show patients' name on the screen after succcessfully login
    if let dispaly = name {
      Welcome.text = dispaly
    }
  
    //Reuqest authorization for pushing notification
    UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.badge, .sound])
    {
      (success,error) in
      if error != nil {print("unsuccessful")}
      else{print("successful")}
    }
  }
}

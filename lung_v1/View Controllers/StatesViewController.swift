
//  StatesViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to adding physical conditions feature, it enables users to upload
 *  their physical conditions after each exercise so that doctors better monitor their situations.
 */

import UIKit
import OHMySQL


class StatesViewController: UIViewController {

  @IBOutlet weak var HeartRate: UITextField!
  @IBOutlet weak var Respiratory: UITextField!
  @IBOutlet weak var Feel: UITextField!
  
  //variable defination
  var db:SQLiteDB!
  var exerciseDate: NSDate!
  var userID: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    db=SQLiteDB.shared
  }
  
  @IBAction func Submit(_ sender: UIButton) {
    
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
    
     exerciseDate = NSDate()
     let dateFormat: DateFormatter = DateFormatter()
     dateFormat.dateFormat = "yyyy-MM-dd 00:00:00"
     let exerciseDateF = dateFormat.string(from:exerciseDate as Date)
     let heart = HeartRate.text
     let respiratory = Respiratory.text
     let feel = Feel.text
     //save data both locally and in the server-side database
     if let a = heart, let b=respiratory,let c=feel
     {
      db.execute(sql: "insert into userCondition (uid,heartRate,respiratoryRate,feel,conditionDate) values ('\(userID)','\(a)','\(b)','\(c)','\(exerciseDateF)')")
      let query = OHMySQLQueryRequestFactory.insert("patient_feedback", set: ["pid": "\(userID as! String)", "feedbackDate": "\(exerciseDateF)","heartRate": "\(a)", "respiratoryRate":"\(b)", "feel":"\(c)"])
      try? context.execute(query)
     }
    
    
    //let g = db.query(sql:"select * from userState1")-----Test Use
    //print("\(g)")
    
    
    //After adding physical conditions, user can choose to back to mianpage or check his progress
    let alertController = UIAlertController(title: "State saved successfully!",
                                            message: "Check Progress？", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Yes", style: .cancel, handler: {
      action in
      self.performSegue(withIdentifier: "CP", sender:nil)
    })
    let okAction = UIAlertAction(title: "No", style: .default, handler: {
      action in
      self.performSegue(withIdentifier: "BM", sender:nil)
    })
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
}

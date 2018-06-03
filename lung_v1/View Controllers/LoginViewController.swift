
//  LoginViewController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to log in feature, it checks whether the input token
 *  matches records in database in server end, ensuring only people with approval
 *  have access to this application.
 */


import UIKit
import OHMySQL

class LoginViewController: UIViewController {
  
  @IBOutlet weak var TokenInput: UITextField!

  
  var pass: String!
  var db:SQLiteDB!
  override func viewDidLoad() {
    super.viewDidLoad()
    db=SQLiteDB.shared
    _ = db.open()
  }
  
  //Press: Ensure the input is valid
  @IBAction func Press(_ sender: UIButton) {
     secure()
  }
  
  func secure(){
    guard let myToken = TokenInput.text,!myToken.isEmpty else{
      let alert = UIAlertController(title: "Alert", message: "No token input", preferredStyle:.alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      return
    }
    login(token:myToken)
  }
  
  func login(token:String){
    //connect to server and verify the input token
    let user = OHMySQLUser(userName: "leo", password: "1994813xl", serverName:"test.carm2gv6dkhr.ap-southeast-2.rds.amazonaws.com", dbName: "test", port: 3306, socket: "")
    let coordinator = OHMySQLStoreCoordinator(user: user!)
    //coordinator.encoding = .UTF8MB4
    coordinator.connect()
    let context = OHMySQLQueryContext()
    context.storeCoordinator = coordinator
    let querySql = OHMySQLQueryRequestFactory.select("patient", condition:"token = '\(token)'")
    print("\(token)")
    let response = try? context.executeQueryRequestAndFetchResult(querySql)
    print("\(response)")
    if (response?.count)!>0{
      let b = response![0]
      if let value = b["pname"]{pass = value as! String}
      self.performSegue(withIdentifier: "login", sender: self)
     //once log in, store user id locally
      if let value1 = b["pid"]{
        let sql_insert = "insert into user (uid) values (\(value1))"
        db.execute(sql: sql_insert)
      }
    }else{
      let alert = UIAlertController(title: "Login Failed", message: "The token you entered is not correct", preferredStyle:.alert)
      alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? HomeViewController{
      destination.name = "Welcome Back: \(pass as! String)"
    }
  }
  

  }


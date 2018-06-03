//  ShowProgressController.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
/*
 *  This .swift corresponds to progress checking feature, it defines a new pageviewController
 *  to enable users to slide between windows to check their daily or weekly progress freely.
 */

import UIKit

class ShowProgressController: UIPageViewController, UIPageViewControllerDataSource {
  
  //variations defination
  var db:SQLiteDB!
  
  //define a new viewControllerList including two ViewControllers(Daily and Weekly)
  lazy var viewControllerList : [UIViewController] = {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc1 = storyboard.instantiateViewController(withIdentifier: "Today")
    let vc2 = storyboard.instantiateViewController(withIdentifier: "Week")
    return[vc1,vc2]
  }()
  
  //define the action going forward
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
    let preIndex = vcIndex - 1
    guard preIndex >= 0  else { return nil}
    return viewControllerList[preIndex]
  }
  
  //define the action going backward
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
    let nextIndex = vcIndex + 1
    guard viewControllerList.count > nextIndex else {return nil}
    return viewControllerList[nextIndex]
  }
  

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = self
    if let firstViewController = viewControllerList.first{
      self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

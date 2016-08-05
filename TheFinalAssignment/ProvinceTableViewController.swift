//
//  ProvinceTableViewController.swift
//  TheFinalAssignment
//
//  Created by 杨威 on 16/8/3.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class ProvinceTableViewController: UITableViewController {
  
  
  //MARK: - Modal
  
  var provinceList = [String]()
  
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = view.frame.height / CGFloat(Constants.numOfCellInPerScreen) - Constants.cellSpace
    configureProvinceData()
  }
  
  private func configureProvinceData(){
    let ban = NSBundle.mainBundle()
    let plistPath = ban.pathForResource("address", ofType: "plist")!
    //provinceDictArray 是一个dictionary的数组 
    if let dict = NSMutableDictionary(contentsOfFile: plistPath){
      if let provinceDictArray = dict.objectForKey("address") as? NSArray{
        provinceList = provinceDictArray.valueForKeyPath("name") as! [String]
        //provinceList = provinceDictArray.map{$0.objectForKey("name") as! String}
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
    
  // MARK: - Table view data source
  
  //how to add spacing between cells
  //#1 from stack overflow
  //设置numberofsection为数组长度 rowsinsection 为 1
  //设置heightForHeaderInsection 为想要的高度  
  //设置viewforHeaderinsection 为一个clear颜色的UIView
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 
    //return 1
    return provinceList.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    //return provinceList.count
    return 1
  }
  
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //有5个point的space
    return Constants.cellSpace
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionBG = UIView()
    sectionBG.backgroundColor = UIColor.clearColor()
    return sectionBG
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("province", forIndexPath: indexPath) as! ProvinceTableViewCell
      cell.bgImage = UIImage(named: "pic1")
      cell.name = provinceList[indexPath.section]
      //选中后 不变色
      cell.selectionStyle = .None
      cell.backgroundImage.layer.cornerRadius = 8
      cell.backgroundImage.clipsToBounds = true
    
      return cell
  }

  
  //MARK: - Constants
  private class Constants{
    static let numOfCellInPerScreen = 4
    static let cellSpace: CGFloat = 4
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

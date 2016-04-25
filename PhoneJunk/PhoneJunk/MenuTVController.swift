//
//  MenuTVController.swift
//  PhoneFiles
//
//  Created by Scott Bridgman on 3/10/16.
//  Copyright © 2016 Tohism. All rights reserved.
//

import UIKit
import EasyTipView

class MenuTVController: BasePhoneJunkTVC, EasyTipViewDelegate {
    
    let menuItems = ["What is PhoneFiles",
                     "How to Use",
                     "Suggestions",
                     "Important Note!",
                     "Rate Us",
                     "Support & Feedback",
                     "Upgrade: Unlimited files for $\(PREMIUM_COST)"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = VC_BG_COLOR
        navigationItem.title = "Menu"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
    func easyTipViewDidDismiss(tipView : EasyTipView){
        tipIsOpen = false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row){
        case 0:
            let msgStr = "There are photos and videos you take for memories. This app is for everything else. If you use your camera to store information, then this app is for you! Declutter your camera roll by keeping your non-memorable photos and videos (i.e. files) here for quick and easy access."
            showPopupMessage(msgStr, widthMult:0.9, heightMult:0.4, remove:false)
        case 1:
            self.removePopup()
            
            activeTips = fullTipList
            
            if !tipIsOpen {
                tipIsOpen = true
            
                guard let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? MenuCell else {
                    break
                }
                let prefs = getTipPreferences()
                EasyTipView.show(forView: cell,
                         withinSuperview: self.tableView,
                         text: "Popup tips will guide you through the app. Tap them to dismiss.",
                         preferences: prefs,
                         delegate: self)
            }
            
        case 2:
            break
        case 3:
            showPopupMessage("Everyday is a cloudless day in PhoneFiles. Files are only stored on your phone.", widthMult:0.9, heightMult:0.4, remove:false)
            break
        case 4:
            break
        case 5:
            //UIApplication.sharedApplication().openURL(NSURL(string : "LINK_GOES_HERE")!)
            break
        default:
            snp()
        }
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

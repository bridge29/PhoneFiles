//
//  MenuTVController.swift
//  PhoneFiles
//
//  Created by Scott Bridgman on 3/10/16.
//  Copyright © 2016 Tohism. All rights reserved.
//

import UIKit

class MenuTVController: BasePhoneJunkTVC {
    
    let menuItems = ["Elevator Pitch",
                     "Why to Use",
                     "How to Use",
                     "Important Note!",
                     "Upgrade: Unlimited files for $\(PREMIUM_COST)",
                     "FAQ",
                     "Rate Us",
                     "Support & Feedback"]

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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row){
        case 0:
            let msgStr = "There are photos and videos you have for memories. This app is for everything else. If you don't use your camera for to store info, then you are missing out on a great life hack. If you do, then this app is for you! Declutter your camera roll by keeping your non-memorable photos and videos (i.e. files) here for quick and easy access."
            showPopupMessage(msgStr, widthMult:0.9, heightMult:0.4, remove:false)
        case 1:
            // Go to list of ideas
            break
        case 2:
            activeTips = fullTipList
            showPopupMessage("Tips will pop up to guide you through this app. Tap them to dismiss.", remove:false)
        case 3:
            showPopupMessage("Every day is a cloudless day in PhoneFiles. Files are only stored on your phone, nothing gets synced anywhere (saves us on server cost 😃) but you can save/email/text files for safe keeping.", widthMult:0.9, heightMult:0.4, remove:false)
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

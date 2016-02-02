//
//  FolderTVController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/15/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData

class FolderTVController: BasePhoneJunkTVC, NSFetchedResultsControllerDelegate {
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let foldersFetchRequest = NSFetchRequest(entityName: "Folders")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        //let secondarySortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
        foldersFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: foldersFetchRequest,
            managedObjectContext: self.moc,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        
        //// NESTS FOR TAKING ACTIONS FOR USERS WITH NEW VERSIONS OF THE APP
        if (NSUserDefaults.standardUserDefaults().valueForKey("v1.0") == nil) {
            
            //// CREATE FOLDERS FOR FIRST TIME USERS
            for (name, isLocked) in [("Utility",false), ("Temp", false), ("Private", true)] {
                createFolder(name, isLocked: isLocked)
            }
            
            //// CREATE SAMPLE FILES FOR FIRST TIME USERS
            let newFile = NSEntityDescription.insertNewObjectForEntityForName("Files", inManagedObjectContext: self.moc)
            newFile.setValue("Passport Front", forKey: "title")
            newFile.setValue("front of passport", forKey: "desc")
            newFile.setValue(NSDate(), forKey: "create_date")
            newFile.setValue(NSDate(), forKey: "edit_date")
            newFile.setValue(fetchedResultsController.fetchedObjects![0], forKey: "whichFolder")
            
            saveContext()

            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "v1.0")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FolderCell", forIndexPath: indexPath)
        
        let folder = fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
        
        cell.textLabel?.text = folder.name
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("folder2file", sender: indexPath)
    }
    
    //override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //let managedObject:NSManagedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
        //self.moc.deleteObject(managedObject)
        
        // TODO: Ask if they are sure you want to delete folder w/ images, then ask for finger print. Then delete all images first
        // make left side for editing.
        
        //saveContext()
    //}
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
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
    
    // MARK: - IBActions
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "folder2file"){
            let dvc = segue.destinationViewController as! FileTVController
            let indexPath:NSIndexPath = sender as! NSIndexPath
            dvc.folder = fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
        }
    }

}

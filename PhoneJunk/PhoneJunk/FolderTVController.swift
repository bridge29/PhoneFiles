//
//  FolderTVController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/15/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication
import EasyTipView

class FolderTVController: BasePhoneJunkTVC, NSFetchedResultsControllerDelegate, EasyTipViewDelegate {
    
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
            for (name, isLocked, daysTilDelete) in [("Utility",false,0), ("Temp", false,7), ("Private", true,0)] {
                self.createFolder(name, isLocked: isLocked, daysTilDelete:daysTilDelete)
            }
            
            //// CREATE SAMPLE FILES FOR FIRST TIME USERS
            let newFile = NSEntityDescription.insertNewObjectForEntityForName("Files", inManagedObjectContext: self.moc)
            newFile.setValue("Passport Info", forKey: "title")
            newFile.setValue("", forKey: "desc")
            newFile.setValue(NSDate(), forKey: "create_date")
            newFile.setValue(NSDate(), forKey: "edit_date")
            newFile.setValue(fetchedResultsController.fetchedObjects![0], forKey: "whichFolder")
            saveContext()

            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "v1.0")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        ///// DEBUGGING
        //printFileContents()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        for folder in fetchedResultsController.fetchedObjects as! [Folders]{
            self.deleteTempFiles(folder)
        }
        
        showTips()
        
        /// TESTING: Menu
        //performSegueWithIdentifier("folder2menu", sender: nil)
    }
    
    func showTips(){
        
        for tip in activeTips {
            if tip.hasPrefix("folder") && !tipIsOpen {
                
                guard let cell2 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? FolderTVCell else {
                    return
                }
                
                let prefs = getTipPreferences()
                
                switch (tip){
                    
                    case "folder_1":
                        EasyTipView.show(forView: cell2.titleLabel,
                            withinSuperview: self.tableView,
                            text: "Here are your folders which will hold your photos and video files. Tap the name to view folder files.",
                            preferences: prefs,
                            delegate: self)
                    
                    case "folder_2":
                        EasyTipView.show(forView: cell2.cameraIMG,
                            withinSuperview: self.tableView,
                            text: "Tap the camera and video icons to quickly take photos and videos.",
                            preferences: prefs,
                            delegate: self)
                    
                    case "folder_3":
                        let cell1 = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! FolderTVCell
                        EasyTipView.show(forView: cell1.lockIMG,
                            withinSuperview: self.tableView,
                            text: "Lock icon shows the folder is locked. Locked folders can only be accessed by Touch ID.",
                            preferences: prefs,
                            delegate: self)
                    
                    case "folder_4":
                        EasyTipView.show(forView: cell2.videoIMG,
                            withinSuperview: self.tableView,
                            text: "Slide folder left to Edit/Delete",
                            preferences: prefs,
                            delegate: self)

                    case "folder_5":
                        EasyTipView.show(forItem: self.navigationItem.rightBarButtonItem!,
                            withinSuperview: self.navigationController!.view,
                            text: "Create a new folder",
                            preferences: prefs,
                            delegate: self)
                    default:
                        return
                }
                
                tipIsOpen = true
                activeTips.removeAtIndex(0)
                break
            }
        }
        
    }
    
    func easyTipViewDidDismiss(tipView : EasyTipView){
        tipIsOpen = false
        showTips()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: FolderTVCell = tableView.dequeueReusableCellWithIdentifier("FolderCell", forIndexPath: indexPath) as! FolderTVCell
        cell.folder            = fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
        cell.titleLabel.text   = (cell.folder.daysTilDelete == 0) ? cell.folder.name : "\(cell.folder.name!) - \(cell.folder.daysTilDelete)"
        
        if cell.folder.isLocked {
            cell.lockIMG.hidden = false
        } else {
            cell.lockIMG.hidden = true
        }
        
        let tapGest1 = UITapGestureRecognizer(target: self, action: "cellActionTapped:")
        tapGest1.numberOfTapsRequired = 1
        cell.cameraIMG.addGestureRecognizer(tapGest1)
        let tapGest2 = UITapGestureRecognizer(target: self, action: "cellActionTapped:")
        tapGest2.numberOfTapsRequired = 1
        cell.videoIMG.addGestureRecognizer(tapGest2)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! FolderTVCell
        checkAuth(cell, segueIdent: "folder2file")
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    func cellActionTapped(gesture:UIGestureRecognizer){
        
        if (maxFileCount > 0 && getFileCount() >= maxFileCount) {
            notifyAlert(self, title: "Uh Oh", message: "The free version only allows \(maxFileCount) files. Go to menu to upgrade to unlimited files for only $\(PREMIUM_COST).")
            return
        }
        
        let location : CGPoint = gesture.locationInView(self.tableView)
        let cellIndexPath:NSIndexPath = self.tableView.indexPathForRowAtPoint(location)!
        let cell = self.tableView.cellForRowAtIndexPath(cellIndexPath) as! FolderTVCell
        cell.tag = gesture.view!.tag
        self.performSegueWithIdentifier("folder2newFile", sender: cell)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // need to invoke this method to have editActions work. No code needed.
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: "  Edit  ") { action, index in
            self.performSegueWithIdentifier("folder2newFolder", sender: indexPath)
        }
        editAction.backgroundColor = UIColor.blueColor()
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            
            let folder = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
            let fetchRequest = NSFetchRequest(entityName: "Files")
            fetchRequest.predicate = NSPredicate(format: "whichFolder == %@", folder)
            
            do {
                let fetchResults = try self.moc.executeFetchRequest(fetchRequest)
                if fetchResults.count > 0 {
                    
                    let actionSheetController1: UIAlertController = UIAlertController(title: "Delete Check 1/2", message: "This folder contains files which will also be deleted. Are sure you want to delete the \"\(folder.name!)\" folder?", preferredStyle: .Alert)
                    let noAction1: UIAlertAction     = UIAlertAction(title: "Nope", style: .Default) { action -> Void in }
                    let deleteAction1: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                        
                        let actionSheetController2: UIAlertController = UIAlertController(title: "Delete Check 2/2", message: "Final prompt, are you sure you want to delete this folder?", preferredStyle: .Alert)
                        let noAction2: UIAlertAction     = UIAlertAction(title: "Nope", style: .Default) { action -> Void in }
                        let deleteAction2: UIAlertAction = UIAlertAction(title: "DELETE IT!", style: .Default) { action -> Void in
                            self.deleteFolder(folder)
                        }
                        
                        actionSheetController2.addAction(noAction2)
                        actionSheetController2.addAction(deleteAction2)
                        self.presentViewController(actionSheetController2, animated: true, completion: nil)
                        
                    }
                    
                    actionSheetController1.addAction(noAction1)
                    actionSheetController1.addAction(deleteAction1)
                    self.presentViewController(actionSheetController1, animated: true, completion: nil)
                    
                } else {
                    self.deleteFolder(folder)
                }
            } catch {
                fatalError("Failed fetch request: \(error)")
            }
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [editAction, deleteAction]
    }
    
    // MARK: - IBActions
    
    // MARK: - Other Methods
    
    func deleteFolder(folderToDelete:Folders){
        
        /// Delete All Files in Folder
        let fetchRequest = NSFetchRequest(entityName: "Files")
        fetchRequest.predicate = NSPredicate(format: "whichFolder == %@", folderToDelete)
        
        do {
            let fetchResults = try self.moc.executeFetchRequest(fetchRequest) as! [Files]
            for file in fetchResults {
                // must also delete the file itself 
                self.deleteFile(file)
                
            }
        } catch {
            fatalError("Failed fetch request: \(error)")
        }
        
        /// Delete Folder
        self.moc.deleteObject(folderToDelete)
        self.saveContext()
    }
    
    func checkAuth(cell:FolderTVCell, segueIdent:String) {
        if cell.folder.isLocked {
            let authenticationContext = LAContext()
            var error:NSError?
            guard authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
                notifyAlert(self, title: "Sorry", message: "Touch ID was not detected on your phone.")
                return
            }
            
            authenticationContext.evaluatePolicy(
                .DeviceOwnerAuthenticationWithBiometrics,
                localizedReason: "User Touch ID to view \(cell.folder.name!) folder",
                reply: {(success, error) -> Void in
                    
                    if( success ) {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.performSegueWithIdentifier(segueIdent, sender: cell)
                        })
                        
                    }else {
                        
                        switch error!.code {
                            //case LAError.SystemCancel.rawValue:
                                //print("Authentication cancelled by the system")
                            //case LAError.UserCancel.rawValue:
                                //print("Authentication cancelled by the user")
                            case LAError.UserFallback.rawValue:
                                //print("User wants to use a password")
                                // We show the alert view in the main thread (always update the UI in the main thread)
                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                    notifyAlert(self, title: "Sorry", message: "Only Touch ID can open locked folders at this time.")
                                })
                            default:
                                break
                                //print("Authentication failed")
                        }
                        
                    }
                    
                })
            
        } else {
            self.performSegueWithIdentifier(segueIdent, sender: cell)
        }
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
            
            case "folder2file":
                let dvc = segue.destinationViewController as! FileTVController
                let cell = sender as! FolderTVCell
                dvc.folder = cell.folder
            
            case "folder2newFile":
                let dvc = segue.destinationViewController as! NewFileViewController
                let cell = sender as! FolderTVCell
                dvc.folder = cell.folder
                dvc.fileType = (cell.tag == 10) ? "Photo" : "Video"
                dvc.firstAction = "take"
            
            case "folder2newFolder":
                let dvc = segue.destinationViewController as! NewFolderViewController
                if (object_getClass(sender).description() == "NSIndexPath"){
                    let indexPath  = sender as! NSIndexPath
                    dvc.editFolder = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Folders
                    dvc.editMode   = true
                }
            default:
                break
        }
    }

}

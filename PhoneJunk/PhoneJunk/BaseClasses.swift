//
//  BaseClasses.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/17/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData


class BasePhoneJunkVC: UIViewController {
    
    var moc: NSManagedObjectContext!
    var tipIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDel.managedObjectContext
    }
    
    //// Creates folder item in core data
    func createFolder(name:String, isLocked:Bool, daysTilDelete:Int = 0){
        
        //// Make fetch request to check if folder already exists.
        //// Can't have two folders with same name.
        
        let fetchRequest = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let fetchResults = try self.moc.executeFetchRequest(fetchRequest)
            if fetchResults.count > 0 {
                print("\(name) exists!")
                return
            }
        } catch {
            fatalError("Failed fetch request: \(error)")
        }
        
        let newFolder = NSEntityDescription.insertNewObjectForEntityForName("Folders", inManagedObjectContext: self.moc)
        newFolder.setValue(name, forKey: "name")
        newFolder.setValue(isLocked, forKey: "isLocked")
        newFolder.setValue(daysTilDelete, forKey:"daysTilDelete")
        saveContext()
    }
    
    func saveContext(){
        do {
            try self.moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func showPopupMessage(message:String, seconds:NSTimeInterval = 2.5, widthMult:CGFloat = 0.7){
        let mainView = self.view.superview!
        let labelWidth = mainView.bounds.width * widthMult
        let label = UILabel(frame: CGRect(x: (mainView.bounds.width - labelWidth)/2, y: mainView.bounds.height * 0.2, width: labelWidth, height: labelWidth * 0.5))
        label.text = message
        label.tag  = 101
        label.backgroundColor = VC_FG_COLOR
        label.layer.borderWidth  = 10
        label.layer.borderColor  = UIColor.orangeColor().CGColor
        label.layer.cornerRadius = 14.0
        label.clipsToBounds      = true
        label.textAlignment      = .Center
        label.lineBreakMode      = .ByWordWrapping
        label.numberOfLines      = 3
        label.font               = UIFont(name: "Helvetica Neue", size: 20)
        //label.sizeToFit()
        mainView.addSubview(label)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "removePopup", userInfo: nil, repeats: false)
    }
    
    func removePopup(){
        UIView.animateWithDuration(1.0, animations: {self.view.superview!.viewWithTag(101)?.alpha = 0.0},
            completion: {(value: Bool) in
                self.view.superview!.viewWithTag(101)?.removeFromSuperview()
        })
    }
}

class BasePhoneJunkTVC: UITableViewController {
    
    var moc: NSManagedObjectContext!
    var tipIsOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDel.managedObjectContext
    }
    
    func setNewFileDVC(dvc:NewFileViewController, sender:AnyObject?){
        
        let action = sender as! UIAlertAction
        let title  = action.title!
        
        if (title.rangeOfString("Take") != nil) {
            dvc.firstAction = "take"
        }else if title.rangeOfString("Choose") != nil {
            dvc.firstAction = "choose"
        }
        
        if (title.rangeOfString("Photo") != nil) {
            dvc.fileType = "Photo"
        }else if (title.rangeOfString("Video") != nil) {
            dvc.fileType = "Video"
        }else {
            dvc.fileType = title
        }
    }
    
    func segueFile2newFile(action: UIAlertAction!){
        self.performSegueWithIdentifier("file2newFile", sender: action)
    }
    
    func segueFolder2newFile(action: UIAlertAction!){
        self.performSegueWithIdentifier("folder2newFile", sender: action)
    }
    
    func presentNewFileOptions(senderName:String) {
        if (maxFileCount > 0 && getFileCount() >= maxFileCount) {
            notifyAlert(self, title: "Uh Oh", message: "The free version only allows \(maxFileCount) files. Go to menu to upgrade to unlimited files for only $\(PREMIUM_COST).")
            return
        }
        
        let ac = UIAlertController(title: "Create New File", message: nil, preferredStyle: .ActionSheet)
        
        for alertOption in ["Take Photo","Take Video","Choose Photo","Choose Video"] {
            if senderName == "folder"{
                ac.addAction(UIAlertAction(title: alertOption, style: .Default, handler: self.segueFolder2newFile))
            } else {
                ac.addAction(UIAlertAction(title: alertOption, style: .Default, handler: self.segueFile2newFile))
            }
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func showPopupMessage(message:String, seconds:NSTimeInterval = 2.5, widthMult:CGFloat = 0.7){
        let mainView = self.view.superview!
        let labelWidth = mainView.bounds.width * widthMult
        let label = UILabel(frame: CGRect(x: (mainView.bounds.width - labelWidth)/2, y: mainView.bounds.height * 0.2, width: labelWidth, height: labelWidth * 0.5))
        label.text = message
        label.tag  = 101
        label.backgroundColor = VC_FG_COLOR
        label.layer.cornerRadius = 14.0
        label.layer.borderColor  = VC_BORDER_COLOR.CGColor
        label.layer.borderWidth  = 8
        label.clipsToBounds      = true
        label.textAlignment      = .Center
        label.lineBreakMode      = .ByWordWrapping
        label.numberOfLines      = 3
        label.font               = UIFont(name: "Helvetica Neue", size: 20)
        //label.sizeToFit()
        mainView.addSubview(label)
        _ = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "removePopup", userInfo: nil, repeats: false)
    }
    
    func removePopup(){
        if let superview = self.view.superview {
            UIView.animateWithDuration(1.0, animations: {superview.viewWithTag(101)?.alpha = 0.0},
                completion: {(value: Bool) in
                    self.view.superview?.viewWithTag(101)?.removeFromSuperview()
            })
        }
    }
    
    //// Delete File
    func deleteFile(file:Files){
        
        if let fn = file.fileName {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(getFilePath(fn))
            } catch {
                fatalError("Failed to remove file in Documents Directory: \(error)")
            }
        }
        
        self.moc.deleteObject(file)
        self.saveContext()
    }
    
    func deleteTempFiles(folder:Folders){
        if folder.daysTilDelete > 0 {
            let fetchRequest = NSFetchRequest(entityName: "Files")
            fetchRequest.predicate = NSPredicate(format: "whichFolder == %@", folder)
            
            do {
                let files = try self.moc.executeFetchRequest(fetchRequest) as! [Files]
                for file in files{
                    let seconds = Int(NSDate.timeIntervalSinceReferenceDate() - file.edit_date)
                    if seconds > 86400 * Int(folder.daysTilDelete){
                        deleteFile(file)
                    }
                }
                
            } catch {
                fatalError("Failed fetch request: \(error)")
            }
        }
    }
    
    //// Creates folder item in core data
    func createFolder(name:String, isLocked:Bool, daysTilDelete:Int = 0){
        
        let fetchRequest = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let fetchResults = try self.moc.executeFetchRequest(fetchRequest)
            if fetchResults.count > 0 {
                print("\(name) exists!")
                return
            }
        } catch {
            fatalError("Failed fetch request: \(error)")
        }
        
        let newFolder = NSEntityDescription.insertNewObjectForEntityForName("Folders", inManagedObjectContext: self.moc)
        newFolder.setValue(name, forKey: "name")
        newFolder.setValue(isLocked, forKey: "isLocked")
        newFolder.setValue(daysTilDelete, forKey:"daysTilDelete")
        saveContext()
        //print("Created Folder: \(name)")
    }

    func saveContext(){
        do {
            try self.moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}

//class PaddingLabel: UILabel {
//    
//    let padding = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
//    
//    override func drawTextInRect(rect: CGRect) {
//        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
//    }
//    
//    // Override -intrinsicContentSize: for Auto layout code
//    override func intrinsicContentSize() -> CGSize {
//        let superContentSize = super.intrinsicContentSize()
//        let width = superContentSize.width + padding.left + padding.right
//        let heigth = superContentSize.height + padding.top + padding.bottom
//        return CGSize(width: width, height: heigth)
//    }
//    
//    // Override -sizeThatFits: for Springs & Struts code
//    override func sizeThatFits(size: CGSize) -> CGSize {
//        let superSizeThatFits = super.sizeThatFits(size)
//        let width = superSizeThatFits.width + padding.left + padding.right
//        let heigth = superSizeThatFits.height + padding.top + padding.bottom
//        return CGSize(width: width, height: heigth)
//    }
//    
//}
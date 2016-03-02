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

class BasePhoneJunkTVC: UITableViewController {
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDel.managedObjectContext
    }
    
    func showPopupMessage(message:String, seconds:NSTimeInterval = 2.0){
        let labelWidth = self.view.bounds.width * 0.5
        let label = UILabel(frame: CGRect(x: (self.view.bounds.width - labelWidth)/2, y: self.view.bounds.height * 0.2, width: labelWidth, height: labelWidth))
        label.text = message
        label.tag  = 101
        label.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(label)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "removePopup", userInfo: nil, repeats: false)
    }
    
    func removePopup(){
        UIView.animateWithDuration(1.0, animations: {self.view.viewWithTag(101)?.alpha = 0.0},
            completion: {(value: Bool) in
                self.view.viewWithTag(101)?.removeFromSuperview()
        })
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
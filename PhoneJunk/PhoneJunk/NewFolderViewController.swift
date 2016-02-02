//
//  NewFolderViewController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/17/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData

class NewFolderViewController: BasePhoneJunkVC, UITextFieldDelegate {

    @IBOutlet weak var folderName: UITextField!
    @IBOutlet weak var lockLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.folderName.delegate = self
    }
    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
//        print("TextField did begin editing method called")
//        return true
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    
    // MARK: - IBActions
    
    //// Toggle lock/unlocked text when user toggles switch
    //// enabled = locked
    @IBAction func switchChanged(sender: UISwitch) {
        self.lockLabel.text = (sender.on) ? "Locked" : "Unlocked"
    }
    
    
    @IBAction func saveFolder(sender: AnyObject) {
        
        let isLocked = (self.lockLabel.text == "Locked") ? true : false
        var name     = self.folderName.text!
        name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (name == "") {
            
            print("Folder must have a name")
            return
            
        } else {
        
            let fetchRequest = NSFetchRequest(entityName: "Folders")
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            
            do {
                let fetchResults = try self.moc.executeFetchRequest(fetchRequest)
                
                if fetchResults.count > 0 {
                    print("\(name) folder exists!")
                } else {
                    
                    //// Folder name is valid, save folder and pop view controller
                    self.createFolder(name, isLocked: isLocked)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } catch {
                fatalError("Failed fetch request: \(error)")
            }
        }
    }
    
    @IBAction func cancelFolder(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

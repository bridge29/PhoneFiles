//
//  NewFolderViewController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/17/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData
import EasyTipView

class NewFolderViewController: BasePhoneJunkVC, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var folderName: UITextField!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var daysTilDeletePicker: UIPickerView!
    var editMode = false
    var editFolder : Folders!
    var dtdArray = ["Never"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.folderName.delegate = self
        self.daysTilDeletePicker.delegate = self
        
        for num in 1...30{
            dtdArray.append("\(num)")
        }
        
        if editMode {
            self.folderName.text = self.editFolder.name
            self.lockSwitch.on   = self.editFolder.isLocked
            self.lockLabel.text = (self.editFolder.isLocked) ? "Locked" : "Unlocked"
            self.daysTilDeletePicker.selectRow(Int(self.editFolder.daysTilDelete), inComponent: 0, animated: true)
        }
        
        let firstWordOfTitle = (editMode) ? "Edit" : "New"
        self.navigationItem.title = "\(firstWordOfTitle) Folder"
    }
    
    // MARK: - Delegate Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dtdArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dtdArray[row]
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
    
    @IBAction func showQuestionMarkMessage(sender: UIButton) {
        switch (sender.tag) {
            case 11:
                notifyAlert(self, title: "Folder Name", message: "The name of your folder. Give a name that identifies the type of files in the folder (e.g. Recipes)")
            case 12:
                notifyAlert(self, title: "Lock Option", message: "If a folder is locked, the files can only be accessed using Touch ED. Use lock if you want to keep files private (e.g. passwords)")
            case 13:
                notifyAlert(self, title: "Days to Delete", message: "How many days to wait to delete a file. This helps reduce clutter with files you don't care to keep after a certain time (e.g. A boarding pass)")
            default:
                break
        }
    }
    
    @IBAction func saveFolder(sender: AnyObject) {
        
        let isLocked      = (self.lockLabel.text == "Locked") ? true : false
        let daysTilDelete = self.daysTilDeletePicker.selectedRowInComponent(0)
        var name          = self.folderName.text!
        name              = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (name == "") {
            
            notifyAlert(self, title: "Uh oh", message: "Folder must have a name")
            return
            
        } else if (!editMode) {
        
            let fetchRequest = NSFetchRequest(entityName: "Folders")
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            
            do {
                let fetchResults = try self.moc.executeFetchRequest(fetchRequest)
                
                if fetchResults.count > 0 {
                    notifyAlert(self, title: "Uh oh", message: "That folder name exists, try another one.")
                } else {
                    
                    //// Folder name is valid, save folder and pop view controller
                    self.createFolder(name, isLocked: isLocked, daysTilDelete: daysTilDelete)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } catch {
                fatalError("Failed fetch request: \(error)")
            }
        } else {
            self.editFolder.name = name
            self.editFolder.isLocked = isLocked
            self.editFolder.daysTilDelete = Int16(daysTilDelete)
            saveContext()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func cancelFolder(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

//
//  NewFileViewController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/18/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit
import MobileCoreServices
import AssetsLibrary

class NewFileViewController: BasePhoneJunkVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dataView: UIView!
    var folder      : Folders!
    var fileType    : String!
    var fileImage   : UIImage!
    var editFile    : Files!
    var avPlayerVC  : AVPlayerViewController!
    var urlVideo    : NSURL!
    var hasFileInfo = false
    var editMode    = false
    var firstAction = ""
    var isTextMode  = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstWordOfTitle = (editMode) ? "Edit" : "New"
        self.navigationItem.title = "\(firstWordOfTitle) \(fileType)"
        self.titleTextField.text  = (editMode) ? self.editFile.title : PRE_TITLE_TEXT
        self.descTextView.text    = (editMode) ? self.editFile.desc  : PRE_DESC_TEXT
        self.titleTextField.delegate = self
        self.descTextView.delegate   = self
        
        switch (fileType){
            case "Photo":
                self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.dataView.addSubview(self.imageView)
            case "Video":
                self.imageView.hidden = true
                self.avPlayerVC   = AVPlayerViewController()
                self.addChildViewController(self.avPlayerVC)
                self.avPlayerVC.view.frame = CGRectMake(0,0,self.dataView.bounds.width,self.dataView.bounds.height)
                self.dataView.addSubview(self.avPlayerVC.view)
            default:
                break
        }
        
        if (self.firstAction == "") {
            self.view.viewWithTag(10)?.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    
        if (editMode){
            
            switch (fileType){
                case "Photo":
                    self.imageView.image = UIImage(contentsOfFile: getFilePath(self.editFile.fileName!))
                case "Video":
                    self.urlVideo = NSURL(fileURLWithPath: getFilePath(self.editFile.fileName!))
                    let player    = AVPlayer(URL: self.urlVideo)
                    self.avPlayerVC.player = player
                default:
                    break
            }
        } else {
            
            switch (fileType){
            case "Photo":
                if (self.firstAction == "take" || self.firstAction == "choose"){
                    let imagePickCont = UIImagePickerController()
                    imagePickCont.delegate = self
                    if (self.firstAction == "take"){
                        imagePickCont.sourceType = UIImagePickerControllerSourceType.Camera
                    }else if (self.firstAction == "choose"){
                        imagePickCont.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    }
                    self.presentViewController(imagePickCont, animated: true, completion: nil)
                }
            case "Video":
                if (self.firstAction == "take" || self.firstAction == "choose"){
                    let ipcVideo = UIImagePickerController()
                    ipcVideo.delegate = self
                    if (self.firstAction == "take"){
                        ipcVideo.sourceType = UIImagePickerControllerSourceType.Camera
                    }else if (self.firstAction == "choose"){
                        ipcVideo.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    }
                    let kUTTypeMovieAnyObject : AnyObject = kUTTypeMovie as AnyObject
                    ipcVideo.mediaTypes = [kUTTypeMovieAnyObject as! String]
                    self.presentViewController(ipcVideo, animated: true, completion: nil)
                }
            default:
                snp()
            }
            self.firstAction = ""
        }
    }
    
    // MARK: - Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        animateTextField(false)
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == PRE_TITLE_TEXT){
            textField.text = ""
        }
        animateTextField(true)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == PRE_DESC_TEXT) {
            textView.text = ""
        }
        animateTextField(true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
        animateTextField(false)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.view.viewWithTag(10)?.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if (self.fileType == "Video") {
            self.urlVideo = info[UIImagePickerControllerMediaURL] as! NSURL
            self.dismissViewControllerAnimated(true, completion: nil)
            let player             = AVPlayer(URL: self.urlVideo)
            self.avPlayerVC.player = player

        }else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.fileImage       = image
            self.imageView.image = self.fileImage
        }
        self.view.viewWithTag(10)?.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func saveFile(sender: AnyObject) {
        
        var title    = self.titleTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var desc     = self.descTextView.text!
        title        = (title == PRE_TITLE_TEXT) ? "" : title
        desc         = (desc  == PRE_DESC_TEXT)  ? "" : desc
        let fileExt  = (fileType == "Photo") ? "jpg" : "mov"
        let fileName = (editMode) ? self.editFile.fileName! : "\(Int(NSDate().timeIntervalSince1970)).\(fileExt)"
        
        if (saveData(fileName)){
            
            if (editMode){
                self.editFile.edit_date = NSDate.timeIntervalSinceReferenceDate()
                self.editFile.title = title
                self.editFile.desc  = desc
            } else {
                let newFile = NSEntityDescription.insertNewObjectForEntityForName("Files", inManagedObjectContext: self.moc)
                newFile.setValue(fileType, forKey: "fileType")
                newFile.setValue(title, forKey: "title")
                newFile.setValue(desc, forKey: "desc")
                newFile.setValue(NSDate(), forKey: "create_date")
                newFile.setValue(NSDate(), forKey: "edit_date")
                newFile.setValue(fileName, forKey: "fileName")
                newFile.setValue(self.folder, forKey: "whichFolder")
            }
            saveContext()
        }else {
            print("File was not saved")
            notifyAlert(self, title: "Uh Oh", message: "\(fileType) was not saved. Take a \(fileType) or select one from your Camera Roll.")
            return
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelFile(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Other Methods
    
    func animateTextField(up: Bool) {
        
        if (up && isTextMode){
            return
        }
        isTextMode = up
        
        let movement:CGFloat = (up ? -200 : 200)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    func saveData(fileName:String) -> Bool{
        
        switch fileType {
            case "Photo":
                if let image = self.imageView.image {
                    UIImageJPEGRepresentation(image,1.0)!.writeToFile(getFilePath(fileName), atomically: true)
                    return true
                }
            case "Video":
                if let url = self.urlVideo {
                    let newFileURL = NSURL(fileURLWithPath: getFilePath(fileName))
                    let videoData = NSData(contentsOfURL: url)
                    videoData?.writeToURL(newFileURL, atomically: true)
                    return true
                }
            default:
                break
        }
        return false
    }

}

//// Keep in portrait mode
//extension UINavigationController {
//    public override func shouldAutorotate() -> Bool {
//        
//        if visibleViewController is NewFileViewController {
//            return false
//        }
//        return true
//    }
//    
//    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        
//        if visibleViewController is NewFileViewController {
//            return UIInterfaceOrientationMask.Portrait
//        }
//        return UIInterfaceOrientationMask.All
//    }
//}


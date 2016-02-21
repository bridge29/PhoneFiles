//
//  FileTVController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/16/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class FileTVController: BasePhoneJunkTVC, NSFetchedResultsControllerDelegate {
    
    var folder : Folders!
    var currView:FilesView!
    lazy var fetchedResultsController: NSFetchedResultsController = {
//        let filesFetchRequest = NSFetchRequest(entityName: "Files")
//        filesFetchRequest.predicate = NSPredicate(format: "whichFolder == %@", self.folder)
//        
//        let primarySortDescriptor = NSSortDescriptor(key: "create_date", ascending: ((self.folder.sortBy! == "recent") ? true : false))
//        //let secondarySortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
//        filesFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: self.getFileFetchRequest(),
            managedObjectContext: self.moc,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //// Folder must exist to load this TVC
        if (self.folder == nil) {
            print("Error: Folder was not established")
            self.navigationController?.popViewControllerAnimated(false)
        }

        self.navigationItem.title = self.folder.valueForKey("name") as? String
        
        self.frcFetch()

        if let num = NSUserDefaults.standardUserDefaults().objectForKey("\(self.folder.name)_filesView") as? Int {
            currView = FilesView(rawValue: num)
        }else {
            currView = FilesView.Small
            NSUserDefaults.standardUserDefaults().setObject(currView.rawValue, forKey: "\(self.folder.name)_filesView")
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
        
        let cell: FileTVCell = tableView.dequeueReusableCellWithIdentifier("FileCell", forIndexPath: indexPath) as! FileTVCell
        cell.file = fetchedResultsController.objectAtIndexPath(indexPath) as! Files
        
        if (cell.file.title == ""){
            cell.descViewTopConstraint.priority = 750
        }else{
            cell.descViewTopConstraint.priority = 250
        }
        
        cell.titleLabel.text   = cell.file.title
        cell.descTextView.text = cell.file.desc
        cell.dataViewWrapper.viewWithTag(20)?.removeFromSuperview()
        
        if let fileName = cell.file.fileName {
        
            if cell.file.fileType == "Photo"{
                
                cell.dataImageView.hidden = false
                cell.dataImageView.image = UIImage(contentsOfFile: getFilePath(fileName))
                cell.dataImageView.contentMode = UIViewContentMode.ScaleAspectFit
//                if let img = cell.dataImageView.image {
//                    cell.aspectRatioConstraint.priority = (img.size.width > img.size.height) ? 750 : 750
//                }
                
            } else {
                
                cell.dataImageView.hidden = true
                let url = NSURL(fileURLWithPath: getFilePath(fileName))
                let avPlayerVC = AVPlayerViewController()
                let player     = AVPlayer(URL: url)
                avPlayerVC.player = player
                self.addChildViewController(avPlayerVC)
                avPlayerVC.view.frame = CGRectMake(0,0,cell.dataViewWrapper.bounds.width, cell.dataViewWrapper.bounds.height)
                avPlayerVC.view.tag = 20
                cell.dataViewWrapper.addSubview(avPlayerVC.view)

                
//                let asset = AVURLAsset(URL: url, options: nil)
//                let imgGenerator = AVAssetImageGenerator(asset: asset)
//                do {
//                    let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
//                    let imageView = UIImageView(frame: CGRectMake(0,0,cell.dataViewWrapper.bounds.width, cell.dataViewWrapper.bounds.height))
//                    imageView.image = UIImage(CGImage: cgImage)
//                    cell.dataViewWrapper.addSubview(imageView)
//                } catch {
//                    print("An error occurred")
//                }
            }
        }
        
        //print(cell.subviews.count)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("file2display", sender: indexPath)
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
            self.performSegueWithIdentifier("file2editFile", sender: indexPath)
        }
        editAction.backgroundColor = UIColor.blueColor()
        
        // Added just as a filler between edit and delete
        let blankAction = UITableViewRowAction(style: .Normal, title: "     ") { action, index in
        }
        blankAction.backgroundColor = UIColor.whiteColor()
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            let fileToDelete = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Files
            self.deleteFile(fileToDelete)
            self.saveContext()
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [editAction, blankAction, deleteAction]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let file = fetchedResultsController.objectAtIndexPath(indexPath) as! Files
        if currView == .Small {
            return 80.0;
        }
        if file.fileType == "Photo" {
            if let img = UIImage(contentsOfFile: getFilePath(file.fileName!)){
                if img.size.width > img.size.height{
                    return self.view.bounds.width * (3/4.0)
                }else {
                    return self.view.bounds.width * (4/3.0)
                }
                
            }
        }
        return self.view.bounds.width * (3/4.0)
    }
    
    // MARK: - IBActions
    
    @IBAction func changeSort(sender: AnyObject) {
        
        self.folder.sortBy = (self.folder.sortBy + 1) % 4
        self.saveContext()
        self.fetchedResultsController.setValue(self.getFileFetchRequest(), forKey:"fetchRequest")
        self.frcFetch()
        self.tableView.reloadData()
        
//        let ac = UIAlertController(title: "Choose Sort Option", message: nil, preferredStyle: .ActionSheet)
//        
//        for alertOption in ["Create Date Recent","Create Date Oldest","Edit Date Recent","Edit Date Oldest"] {
//            ac.addAction(UIAlertAction(title: alertOption, style: .Default, handler: sortFiles))
//        }
//        
//        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func changeView(sender: AnyObject) {
        let newNum = (currView.rawValue + 1) % 3
        currView = FilesView(rawValue: newNum)
        NSUserDefaults.standardUserDefaults().setObject(currView.rawValue, forKey: "\(self.folder.name)_filesView")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
    }
    
    @IBAction func newFile(sender: AnyObject) {
        let ac = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .ActionSheet)
        
        for alertOption in ["Take Photo","Take Video","Choose Photo","Choose Video"] {
            ac.addAction(UIAlertAction(title: alertOption, style: .Default, handler: openNewFile))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: - Other Methods
    
    func getFileFetchRequest() -> NSFetchRequest {
        let filesFetchRequest = NSFetchRequest(entityName: "Files")
        filesFetchRequest.predicate = NSPredicate(format: "whichFolder == %@", self.folder)
        
        var sortDate  = "create_date"
        var sortOrder = "recent"
        
        switch (SortBy(rawValue: self.folder.sortBy)!){
            case .CreateRecent:
                sortDate  = "create_date"
                sortOrder = "recent"
            case .CreateOldest:
                sortDate  = "create_date"
                sortOrder = "oldest"
            case .EditRecent:
                sortDate  = "edit_date"
                sortOrder = "recent"
            case .EditOldest:
                sortDate  = "edit_date"
                sortOrder = "oldest"
        }
        
        print("HI \(sortDate) \(sortOrder)")
        
        let primarySortDescriptor = NSSortDescriptor(key: sortDate, ascending: ((sortOrder == "recent") ? true : false))
        //let secondarySortDescriptor = NSSortDescriptor(key: "commonName", ascending: true)
        filesFetchRequest.sortDescriptors = [primarySortDescriptor]
        return filesFetchRequest
    }
    
    func frcFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred: \(error)")
        }
    }
    
    func openNewFile(action: UIAlertAction!){
        self.performSegueWithIdentifier("file2newFile", sender: action)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "file2display") {
            let dvc = segue.destinationViewController as! DisplayViewController
            let indexPath:NSIndexPath = sender as! NSIndexPath
            dvc.currFile = fetchedResultsController.objectAtIndexPath(indexPath) as! Files
            dvc.fileList = fetchedResultsController.fetchedObjects as! [Files]
            dvc.currIdx = indexPath.row
            return
        }
        
        let dvc = segue.destinationViewController as! NewFileViewController
        dvc.folder   = self.folder
        
        if (segue.identifier == "file2newFile"){
            
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
            
        } else if (segue.identifier == "file2editFile") {
            
            let indexPath:NSIndexPath = sender as! NSIndexPath
            let file = fetchedResultsController.objectAtIndexPath(indexPath) as! Files
            dvc.fileType = file.fileType
            dvc.editMode = true
            dvc.editFile = file
        }
    }
    
}







//
//  DisplayViewController.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 1/9/16.
//  Copyright © 2016 Tohism. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {

    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    var fileList : [Files]!
    var currFile : Files!
    var currIdx = 0
    var hideDetails = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "prevFile")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.mainView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "nextFile")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.mainView.addGestureRecognizer(swipeLeft)
        
        let tapGest = UITapGestureRecognizer(target: self, action: "mainViewTapped")
        tapGest.numberOfTapsRequired = 1
        self.mainView.addGestureRecognizer(tapGest)
        
        showFile()
    }
    
    func mainViewTapped() {
        self.hideDetails       = !self.hideDetails
        self.titleLabel.hidden = self.hideDetails
        self.descLabel.hidden  = self.hideDetails
    }
    
    func showFile() {
        
        self.titleLabel.text = self.currFile.title
        self.descLabel.text  = self.currFile.desc
        
        if currFile.fileType == "Photo" {
            self.imageView.image = UIImage(contentsOfFile: getFilePath(currFile.fileName!))
        }
    }
    
    func prevFile () {
        if currIdx <= 0 {
            //pl("At first photo")
            return
        }
        
        self.currIdx--
        self.currFile = self.fileList[self.currIdx]
        showFile()
    }
    
    func nextFile () {
        if currIdx + 1 >= self.fileList.count {
            //pl("At last photo")
            return
        }
        
        self.currIdx++
        self.currFile = self.fileList[self.currIdx]
        showFile()
    }
    
    @IBAction func exitDisplay(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

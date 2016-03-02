//
//  settings.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/18/15.
//  Copyright © 2015 Tohism. All rights reserved.
//
// TODO:
// Menu
// -Pop up messgae (used to show when sorting changes, also used for things like "text sent")
// -Display scene with tab buttons for text/email/save/crop
// -Menu table view
//    - What is PhoneJunk, Upgrade: Unlimited Files for $1.99, Folder Suggestions, File Suggestions, Rate Us, Contact Us
// VERSION 2:
//     - cloud/non-cloud option 
//     - Photo shoot feature (also will be in separate app)

import UIKit

let fileTypes      = ["Photo","Video"] //,"Audio","Text"]
let PRE_TITLE_TEXT = "Title..."
let PRE_DESC_TEXT  = "Description..."
let PREMIUM_COST   = "1.99"

enum FilesView: Int {
    case Small  = 0
    case Medium = 1
    case Large  = 2
}

enum SortBy: Int16 {
    case CreateRecent = 0
    case CreateOldest = 1
    case EditRecent   = 2
    case EditOldest   = 3
}

func getSortName(sortBy:SortBy) -> String{
    switch (sortBy) {
    case .CreateRecent:
        return "Create Date Recent First"
    case .CreateOldest:
        return "Create Date Oldest First"
    case .EditRecent:
        return "Last Edit Recent First"
    case .EditOldest:
        return "Last Edit Oldest First"
    }
}

var securityMethod : String {
    get {
        var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("securityMethod") as? String
        if returnValue == nil //Check for first run of app
        {
            returnValue = "finger" // securityMethod can be finger or pass.
        }
        return returnValue!
    }
    set {
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "securityMethod")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var maxFileCount : Int {
    get {
        var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("maxFileCount") as? Int
        if returnValue == nil {
            returnValue = 10
        }
        return returnValue!
    }
    set {
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "maxFileCount")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

func getDocumentPath() -> String{
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
}

func getFilePath(fileName:String) -> String{
    return getDocumentPath().stringByAppendingString("/" + fileName)
}

func getFileCount() -> Int{
    do {
        let allFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(getDocumentPath())
        var files:[String] = []
        for file in allFiles{
            if file.hasPrefix("1") && (file.hasSuffix("jpg") || file.hasSuffix("mov")) {
                files.append(file)
            }
        }
        return files.count
    } catch {
        print("Error: \(error)")
    }
    return 0
}

func printFiles(){
    do {
        let allFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(getDocumentPath())
        var files:[String] = []
        for file in allFiles{
            if file.hasPrefix("14") && (file.hasSuffix("jpg") || file.hasSuffix("mov")) {
                files.append(file)
            }
        }
        print("\(files.count) files:")
        for file in files{
            print(file)
        }
    } catch {
        print("Error: \(error)")
    }
}

func getFileDateLabelText(date:NSTimeInterval, useDateFormat:Bool=true) ->String{
    
    if (useDateFormat){
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateFormat = "MM/dd"
        return formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate:date))
        
    }else{
        
        let seconds = Int(NSDate.timeIntervalSinceReferenceDate() - date)
        var num = 1
        var unit = "min"
        
        switch(seconds){
        case 0..<60:
            num  = 1
            unit = "min"
        case 60..<3600:
            num  = seconds/60
            unit = "min"
        case 3600..<86400:
            num  = seconds/3600
            unit = "hour"
        case  86400..<1209600:
            num  = seconds/86400
            unit = "day"
        default:
            return "\(seconds/604800)w"
        }
        unit = (num == 1) ? unit : unit + "s"
        return "\(num) \(unit)"
    }
}

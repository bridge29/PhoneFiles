//
//  settings.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/18/15.
//  Copyright © 2015 Tohism. All rights reserved.
//
// TODO:
// Menu
// Pop up messgae (used to show when sorting changes)
// 
// VERSION 2:
//     - cloud/non-cloud option 
//     - Photo shoot feature (also will be in separate app)

import UIKit

let fileTypes = ["Photo","Video"] //,"Audio","Text"]
let PRE_TITLE_TEXT = "Title..."
let PRE_DESC_TEXT  = "Description..."

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

var securityMethod : String {
    get {
        var returnValue: String? = NSUserDefaults.standardUserDefaults().objectForKey("securityMethod") as? String
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

func getDocumentPath() -> String{
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
}

func getFilePath(fileName:String) -> String{
    return getDocumentPath().stringByAppendingString("/" + fileName)
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
        case  86400..<604800:
            num  = seconds/86400
            unit = "day"
        default:
            return "\(seconds/604800)w"
        }
        unit = (num == 1) ? unit : unit + "s"
        return "\(num) \(unit)"
    }
}

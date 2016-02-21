//
//  settings.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/18/15.
//  Copyright © 2015 Tohism. All rights reserved.
//
// TODO:
// Menu
// Sorting functionality in files scene
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

func getDocumentPath() -> String{
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
}

func getFilePath(fileName:String) -> String{
    return getDocumentPath().stringByAppendingString("/" + fileName)
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
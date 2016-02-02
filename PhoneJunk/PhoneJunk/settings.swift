//
//  settings.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/18/15.
//  Copyright © 2015 Tohism. All rights reserved.
//
// TODO:
// Design Folder table view
//      -Add photo, video, and unlock/lock icons
// Design New Folder scene
//      -include lock/unlock, days to delete (temp folder)
// Folder lock feature
// Photo shoot feature
// Menu

import UIKit

let fileTypes = ["Photo","Video"] //,"Audio","Text"]
let PRE_TITLE_TEXT = "Title..."
let PRE_DESC_TEXT  = "Description..."

func getFilePath(fileName:String) -> String{
    let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    return documentPath.stringByAppendingString("/" + fileName)
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
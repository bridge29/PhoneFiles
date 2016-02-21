//
//  FolderTVCell.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 2/4/16.
//  Copyright © 2016 Tohism. All rights reserved.
//

import UIKit

class FolderTVCell: UITableViewCell {
    
    @IBOutlet weak var lockIMG: UIImageView!
    @IBOutlet weak var videoIMG: UIImageView!
    @IBOutlet weak var cameraIMG: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var folder: Folders!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.videoIMG.userInteractionEnabled = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

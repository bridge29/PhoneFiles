//
//  FileTVCell.swift
//  PhoneJunk
//
//  Created by Scott Bridgman on 12/21/15.
//  Copyright © 2015 Tohism. All rights reserved.
//

import UIKit

class FileTVCell: UITableViewCell {

    @IBOutlet weak var descViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var dataViewWrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    var file: Files!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

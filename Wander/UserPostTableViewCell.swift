//
//  UserPostTableViewCell.swift
//  Wander
//
//  Created by Siddharth Garg on 23/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import MediaPlayer

class UserPostTableViewCell: UITableViewCell {
  
    @IBOutlet weak var videoView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
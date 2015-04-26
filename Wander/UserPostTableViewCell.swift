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
  
    @IBOutlet weak var videoImageView: UIImageView! {
        didSet {
            if self._videoURL != nil {
                var thumbnail : UIImage = FileUtils.generateThumbnail(self._videoURL, size: videoImageView.frame.size)
                videoImageView.clipsToBounds = true
                videoImageView.image = thumbnail
            }
        }
    }
    
    @IBOutlet weak var showCommentsButton: UIButton!
    
    var _videoURL : NSURL!
    var videoURL : NSURL! {
        get {
            return self._videoURL
        }
        set {
            self._videoURL = newValue
            
            if videoImageView != nil {
                var thumbnail : UIImage = FileUtils.generateThumbnail(newValue, size: videoImageView.frame.size)
                videoImageView.clipsToBounds = true
                videoImageView.image = thumbnail
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

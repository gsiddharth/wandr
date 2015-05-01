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
  
    var _videoURL : NSURL!
    
    @IBOutlet weak var showCommentsButton: UIButton!
    
    @IBOutlet weak var videoImageView: UIImageView! {
        didSet {
            if self._videoURL != nil {
                var thumbnail : UIImage = FileUtils.generateThumbnail(self._videoURL, size: videoImageView.frame.size, isPortrait : false)
                videoImageView.clipsToBounds = true
                videoImageView.image = thumbnail
            }
        }
    }
    
    var videoURL : NSURL! {
        get {
            return self._videoURL
        }
        set {
            self._videoURL = newValue
            
            if videoImageView != nil {
                println(videoImageView.frame.size.height.description + " " + videoImageView.frame.size.width.description)
                var thumbnail : UIImage = FileUtils.generateThumbnail(newValue, size: videoImageView.frame.size, isPortrait : false)
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

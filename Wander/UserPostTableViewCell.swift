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
                videoImageView.clipsToBounds = true
                loadImageFromURL()
            }
        }
    }
    
    func loadImageFromURL(){
        if self.videoImageView.image != nil {
            
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                var error: NSError?
                var imgData = NSData(contentsOfURL: self._videoURL, options: NSDataReadingOptions(), error: &error)
            
                dispatch_async(dispatch_get_main_queue()) {
                    if imgData != nil {
                        var image = UIImage(data: imgData!)
                        if image != nil {
                            self.videoImageView.image = image
                        }
                    }
                }
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
                videoImageView.clipsToBounds = true
                loadImageFromURL()
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

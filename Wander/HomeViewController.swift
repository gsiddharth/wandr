//
//  HomeViewController.swift
//  Wander
//
//  Created by Siddharth Garg on 24/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import SwiftHTTP

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellTableIdentifier = "UserPostTableCellIdentifier"

    var library : ALAssetsLibrary!
    
    var videoURLs : [NSURL] = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.library = ALAssetsLibrary()
        

        tableView.registerClass(UserPostTableViewCell.self,
            forCellReuseIdentifier: cellTableIdentifier)
        
        let nib = UINib(nibName: "UserPostTableViewCell", bundle: nil)
        
        tableView.registerNib(nib,
            forCellReuseIdentifier: cellTableIdentifier)
        

        
        var request = HTTPTask()
        
        request.responseSerializer = JSONResponseSerializer()
        
        let params: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        
        request.POST(Networking.instance.getVideoInformationURL("Mumbai", longitude: 0, latitude: 0), parameters: params) { (response : HTTPResponse) -> Void in
            
            if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                
                if let err = response.error {
                    
                }else{
                    if let result : = dict["Result"] as? Dictionary<String,AnyObject> {
                    }
                }
            }
        }
        
        FileUtils.getAllVideo(self.library, album: Constants.albumName) { (url : NSURL) -> Void in
            self.videoURLs.append(url)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellTableIdentifier) as? UserPostTableViewCell
        
        if (cell == nil) {
            cell = UserPostTableViewCell()
        }
    
        cell?.videoURL = videoURLs[indexPath.row]
            
        return cell!
    }
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

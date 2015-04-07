//
//  HomeViewController.swift
//  Wander
//
//  Created by Siddharth Garg on 24/03/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellCount : Int = 0
    
    let tableIdentifier = "UserPostsTableIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UserPostTableViewCell.self,
            forCellReuseIdentifier: "UserPostTableCellIdentifier")
        
        let nib = UINib(nibName: "UserPostTableCellIdentifier", bundle: nil)
        
        tableView.registerNib(nib,
            forCellReuseIdentifier: "UserPostTableCellIdentifier")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(self.tableIdentifier) as? UserPostTableViewCell
        
        if (cell == nil) {
            
            cell = UserPostTableViewCell()
        }
        
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

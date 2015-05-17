//
//  LoginViewController.swift
//  Wander
//
//  Created by Siddharth Garg on 22/02/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit
import SwiftHTTP

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        var username = self.usernameTextField.text
        var password = self.passwordTextField.text
        
        self.resignFirstResponder()
        
        if identifier == "LoginSuccessSegue" {
            
            var request = HTTPTask()
            
            request.requestSerializer = JSONRequestSerializer()
            request.responseSerializer = JSONResponseSerializer()
            
            let params: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            
            request.POST(Networking.instance.getLoginURL(username, password: password), parameters: params, success: { (response : HTTPResponse) -> Void in

                println(response.responseObject)
                
                if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                    
                    if let err: AnyObject = dict["ErrorDescription"] {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.statusLabel.text = err as? String
                        }
                    }else{
                        if let sessionSecret:AnyObject = dict["SessionSecret"] as? Dictionary<String,AnyObject> {
                            Networking.instance.sessionSecret = (sessionSecret["Secret"] as? String)!
                            Networking.instance.sessionKey = (sessionSecret["Key"] as? String)!
                            println(Networking.instance.sessionSecret)
                            self.loadHomeView()
                        }
                    }
                }
                
                }, failure: { (err : NSError, response : HTTPResponse?) -> Void in
                
            })
            
            return false
        }
        
        return true
    }
    
    func loadHomeView(){
        var homeViewController : HomeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeViewController") as! HomeViewController
        
        var navigationController : UINavigationController = UINavigationController(rootViewController: homeViewController)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Networking.instance.sessionSecret != "" && Networking.instance.sessionKey != "" {
            loadHomeView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

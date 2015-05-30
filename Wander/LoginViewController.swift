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
                        
            let params: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            
            request.POST(Networking.instance.getLoginURL(username, password: password), parameters: params, completionHandler: { (resp : HTTPResponse) -> Void in
                
                var response = Convertors.toMap(resp)
                
                if let dict = response.object as? Dictionary<String,AnyObject> {

                    if let err = response.error {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if let status : String = dict["Status"] as? String{
                                self.statusLabel.text = status
                            } else {
                                self.statusLabel.text = "Error while logging in"
                            }
                            
                        }
                        
                    }else{
                        
                        if let result : Dictionary<String,AnyObject> = dict["Result"] as? Dictionary<String,AnyObject> {
                            
                            if let sessionSecret:AnyObject = result["SessionSecret"] as? Dictionary<String,AnyObject> {
                                
                                Networking.instance.sessionSecret = (sessionSecret["Secret"] as? String)!
                                Networking.instance.sessionKey = (sessionSecret["Key"] as? String)!
                                
                                self.loadHomeView()
                            }
                        }
                    }
                } else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.statusLabel.text = "Error while logging in"
                    }
                }
                
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
        
        var request = HTTPTask()
        Networking.instance.setRequestHeaders(&request)
        
        let params: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

        request.POST(Networking.instance.getAuthenticateURL(), parameters: params,
            completionHandler: { (response : HTTPResponse) -> Void in
            if let err = response.error {
                return
            } else {
                self.loadHomeView()
            }
        })
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

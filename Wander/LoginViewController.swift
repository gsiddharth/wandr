//
//  LoginViewController.swift
//  Wander
//
//  Created by Siddharth Garg on 22/02/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        var username = "sid"
        var password = "sid"
        
        self.resignFirstResponder()
        
        if identifier == "LoginSuccessSegue" {
            if self.usernameTextField.text == username && self.passwordTextField.text == password {
                return true
            } else {
                self.statusLabel.text = "Incorrect username or password"
                return false
            }
        }
        
        return true
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

//
//  RegisterViewController.swift
//  Wander
//
//  Created by Siddharth Garg on 22/02/15.
//  Copyright (c) 2015 All Those who Wander. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var password2TextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        // Conditions to be coded
        // 1. password == password2
        // 2. email shouldn't already exist
        // 3. username shouldn't already exist
        
        self.resignFirstResponder()
        
        if identifier == "ProfileSuccessSegue" {

            if passwordTextField.text == password2TextField.text {
                return true
            } else {
                self.statusLabel.text = "Passwords do not match"
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

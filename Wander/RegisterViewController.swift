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
    
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    
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
        self.backgroundScrollView.sc
        registerForKeyboardNotifications()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func getActiveObject() -> UITextField! {
        if usernameTextField.isFirstResponder() {
            return usernameTextField
        } else if nameTextField.isFirstResponder() {
            return nameTextField
        } else if emailTextField.isFirstResponder() {
            return emailTextField
        } else if passwordTextField.isFirstResponder() {
            return passwordTextField
        } else if password2TextField.isFirstResponder() {
            return password2TextField
        } else{
            return nil
        }
    }
    
    func keyboardWillShow(aNotification:NSNotification) {
    
        if let info = aNotification.userInfo {
            if var kbRect = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
                kbRect = self.view.convertRect(kbRect, fromView : nil)
                var contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0)
                self.backgroundScrollView.contentInset = contentInsets
                self.backgroundScrollView.scrollIndicatorInsets = contentInsets
                
                var aRect = self.view.frame
                aRect.size.height -= kbRect.size.height
                
                if let activeField = getActiveObject(){
                
                    if (!CGRectContainsPoint(aRect, activeField.frame.origin)){
                        self.backgroundScrollView.scrollRectToVisible(activeField.frame, animated: true)
                    }
                }
            }
        }
    }
    
    func keyboardWillHide(aNotification:NSNotification) {
        
    }
    
    
}

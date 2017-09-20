//
//  LoginVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/9/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit


class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var passwordTextField: InsetTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        dismissKeyboardGestureRecognizer()
        
    }

    @IBAction func signInBtnPressed(_ sender: Any) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, error) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing: error?.localizedDescription))
                }
                
                AuthService.instance.registerUser(withEmail: email, andPassword: pass, userCreationComplete: { (success, regisrationError) in
                    if success {
                        AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, nil) in
                            self.dismiss(animated: true, completion: nil)
                            print("Successfully registered user!")
                        })
                    } else {
                        print(String(describing: error?.localizedDescription))
                    }
                })
            })
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

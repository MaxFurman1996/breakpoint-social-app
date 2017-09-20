//
//  AuthVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/9/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase

class AuthVC: UIViewController {


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
        
        dismissKeyboardGestureRecognizer()
    }

    @IBAction func signInWithFacebookBtnPressed(_ sender: Any) {
    }
    @IBAction func signInWithGoogleBtnPressed(_ sender: Any) {
    }
    @IBAction func signInWithEmailBtnPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    

}

//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/10/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase

class CreatePostVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        sendBtn.bindToKeyboard()
        
        dismissKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailLbl.text = Auth.auth().currentUser?.email
        
        DataService.instance.getProfilePhoto(forUserId: (Auth.auth().currentUser?.uid)!) { (photo) in
            self.profileImageView.image = photo
        }
    }
    
    

    @IBAction func sendBtnPressed(_ sender: Any) {
        let text: String? = textView.text
        if text != nil && text != "Say something here..." && text != "" {
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: text!, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: nil, sendComplete: { (isComplete) in
                if isComplete {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.sendBtn.isEnabled = true
                    print("There was an error!")
                }
            })
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension CreatePostVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}

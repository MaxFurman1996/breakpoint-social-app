//
//  UIViewController+Ext.swift
//  breakpoint
//
//  Created by Max Furman on 9/10/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit


//extension to provide keyboard hiding when you tap outside of keyboard
extension UIViewController {
    
    func dismissKeyboardGestureRecognizer(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func presentDetail(_ viewControllerToPresent: UIViewController){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissDetail(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
}

//
//  ShadowView.swift
//  breakpoint
//
//  Created by Max Furman on 9/9/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }

    func setupView(){
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}

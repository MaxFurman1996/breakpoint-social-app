//
//  RoundedImageView.swift
//  breakpoint
//
//  Created by Max Furman on 9/18/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
        super.awakeFromNib()
    }

}

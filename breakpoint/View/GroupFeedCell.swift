//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Max Furman on 9/16/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var messageView: UILabel!
    
    
    func configureCell(profileImage image: UIImage, userEmail email: String, content: String) {
        profileImageView.image = image
        emailLbl.text = email
        messageView.text = content
    }

}

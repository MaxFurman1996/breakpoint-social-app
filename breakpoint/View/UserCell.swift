//
//  UserCell.swift
//  breakpoint
//
//  Created by Max Furman on 9/11/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var showing: Bool = false
    
    func configureCell(profileImage: UIImage, username: String, isSelected: Bool){
        profileImageView.image = profileImage
        usernameLbl.text = username
        
        if isSelected{
            checkImageView.isHidden = false
        } else {
            checkImageView.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            if !showing {
                checkImageView.isHidden = false
                showing = true
            } else {
                checkImageView.isHidden = true
                showing = false
            }
        }
    }

}

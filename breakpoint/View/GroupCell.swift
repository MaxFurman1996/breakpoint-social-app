//
//  GroupCell.swift
//  breakpoint
//
//  Created by Max Furman on 9/15/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var groupDescLbl: UILabel!
    @IBOutlet weak var memberCountLbl: UILabel!
    
    func configureCell(withTitle title: String, withDescription description: String, memberCount: Int){
        groupTitleLbl.text = title
        groupDescLbl.text = description
        memberCountLbl.text = "\(memberCount) members."
    }

}

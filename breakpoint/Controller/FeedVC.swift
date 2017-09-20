//
//  FeedVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/8/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = [Message]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_FEED.observe(.value) { (snaphot) in
            DataService.instance.getAllFeedMessages { (feedMessages) in
                self.messages = feedMessages.reversed()
                self.tableView.reloadData()
            }
        }
    }
}

extension FeedVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else {
            return UITableViewCell()
        }

        
        //let defaultImage: UIImage = UIImage(named: "defaultProfileImage")!
        
        let message: Message = messages[indexPath.row]
        DataService.instance.getUsername(forUID: message.senderId) { (username) in
            DataService.instance.getProfilePhoto(forUserId: message.senderId, handler: { (photo) in
                
                cell.configureCell(profileImage: photo, userEmail: username, content: message.content)
            })
        }
        

        
        return cell
    }
}


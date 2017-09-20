//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/16/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var group: Group?
    var groupMessages: [Message] = [Message]()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        sendBtnView.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLbl.text = group?.groupTitle
        DataService.instance.getEmails(forGroup: group!) { (returnedEmails) in
            self.membersLbl.text = returnedEmails.joined(separator: ", ")
        }
        
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllGroupMessages(forGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                self.tableView.reloadData()
                
                if self.groupMessages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 0) , at: .none, animated: false)
                }
            })
        }
    }
    

    
    @IBAction func sendBtnPressed(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: messageTextField.text!, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: group?.key, sendComplete: { (isCompleted) in
                if isCompleted {
                    self.messageTextField.isEnabled = true
                    self.sendBtn.isEnabled = true
                    self.messageTextField.text = ""
                    self.dismissKeyboard()
                }
            })
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
}


extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell") as? GroupFeedCell else {
            return UITableViewCell()
        }
        
        //let image: UIImage = UIImage(named: "defaultProfileImage")!
        let message: Message = groupMessages[indexPath.row]
//        DataService.instance.getUsername(forUID: message.senderId) { (username) in
//            cell.configureCell(profileImage: image, userEmail: username, content: message.content)
//        }
        DataService.instance.getUsername(forUID: message.senderId) { (username) in
            DataService.instance.getProfilePhoto(forUserId: message.senderId, handler: { (photo) in
                
                cell.configureCell(profileImage: photo, userEmail: username, content: message.content)
            })
        }
        return cell
    }
}

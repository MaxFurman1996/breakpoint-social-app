//
//  CreateGroupsVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/11/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupsVC: UIViewController {

    @IBOutlet weak var titleTextField: InsetTextField!
    @IBOutlet weak var descriptionTextField: InsetTextField!
    @IBOutlet weak var emailSearchTextField: InsetTextField!
    @IBOutlet weak var groupMembersLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var emailArray: [String] = [String]()
    var chosenUserArray : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        emailSearchTextField.delegate = self
        descriptionTextField.delegate = self
        titleTextField.delegate = self
        titleTextField.returnKeyType = .done
        descriptionTextField.returnKeyType = .done
        emailSearchTextField.returnKeyType = .done
        emailSearchTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
    }
    
    @objc func textFieldDidChanged(){
        
        if emailSearchTextField.text == "" {
            emailArray = []
            tableView.reloadData()
        } else {
            DataService.instance.getEmail(forSearchQuery: emailSearchTextField.text!, handler: { (returnedEmailArray) in
                self.emailArray = returnedEmailArray
                self.tableView.reloadData()
            })
        }
        
    }

    @IBAction func doneBtnPressed(_ sender: Any) {
        if titleTextField.text != "" && descriptionTextField.text != ""{
            DataService.instance.getIds(forUsernames: chosenUserArray, handler: { (ids) in
                var userIds = ids
                userIds.append((Auth.auth().currentUser?.uid)!)
                DataService.instance.createGroup(withTitle: self.titleTextField.text!, withDescription: self.descriptionTextField.text!, forUsersIds: userIds, sendComplete: { (groupCreated) in
                    if groupCreated {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("Group can't be created.")
                    }
                })
            })
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}


extension CreateGroupsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else { return UITableViewCell() }
        let image: UIImage = UIImage(named: "defaultProfileImage")!
        let email: String = emailArray[indexPath.row]
        let selected: Bool!
        if chosenUserArray.contains(email) {
            selected = true
        } else {
            selected = false
        }
        cell.configureCell(profileImage: image, username: email, isSelected: selected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else { return }
        let email = cell.usernameLbl.text!
        if !chosenUserArray.contains(email) {
            chosenUserArray.append(email)
            groupMembersLbl.text = chosenUserArray.joined(separator: ", ")
            doneBtn.isHidden = false
        } else {
            chosenUserArray = chosenUserArray.filter({ $0 != email })
            if chosenUserArray.count >= 1 {
                groupMembersLbl.text = chosenUserArray.joined(separator: ", ")
            } else {
                groupMembersLbl.text = "add people to your group"
                doneBtn.isHidden = true
            }
        }
    }
}

extension CreateGroupsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

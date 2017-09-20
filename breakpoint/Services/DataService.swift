//
//  DataService.swift
//  breakpoint
//
//  Created by Max Furman on 9/8/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService{
    static var instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    private var _REF_STORAGE_IMAGES = STORAGE_BASE.child("profile_images")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference{
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference{
        return _REF_FEED
    }
    
    var REF_STORAGE_IMAGES : StorageReference {
        return _REF_STORAGE_IMAGES
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>){
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupKey: String?,
                    sendComplete: @escaping (_ status: Bool ) -> ()){
        if groupKey != nil {
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["content" : message, "senderId" : uid])
            sendComplete(true)
        } else {
            REF_FEED.childByAutoId().updateChildValues(["content" : message, "senderId" : uid])
            sendComplete(true)
        }
    }
    
    func uploadProfileImageUrl(forUser userId: String, profileImageUrl: String, handler: @escaping (_ isCompleted: Bool) -> ()) {
        REF_USERS.child(userId).updateChildValues(["profileImageUrl" : profileImageUrl])
        handler(true)
    }
    
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> ()){
//        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
//            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
//            for user in userSnapshot{
//                if user.key == uid{
//                    handler(user.childSnapshot(forPath: "email").value as! String)
//                }
//            }
//        }
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (userSnapshot) in
            handler(userSnapshot.childSnapshot(forPath: "email").value as! String)
        }
    }
    
    func getProfilePhoto(forUserId uid: String, handler: @escaping (_ profileImage: UIImage) -> ()){
        
        DataService.instance.REF_USERS.child(uid).observe(.value) { (user) in
            
            guard let profileImageUrl = user.childSnapshot(forPath: "profileImageUrl").value as? String else {
                handler(UIImage(named: "defaultProfileImage")!)
                return
            }
            print(profileImageUrl)
            let ref = Storage.storage().reference(forURL: profileImageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil {
                    print("Unable to download image from Firebase storage")
                } else {
                    print("Image downloaded from Firebase storage")
                    handler(UIImage(data: data!)!)
                }
            })
        }
    }
    
    func getAllFeedMessages(handler: @escaping (_ messages: [Message]) -> ()){
        var messageArray: [Message] = [Message]()

        REF_FEED.observeSingleEvent(of: .value) { (feedSnapshot) in
            guard let feedSnapshot = feedSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for message in feedSnapshot{
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let content = message.childSnapshot(forPath: "content").value as! String
                let message: Message = Message(senderId: senderId, content: content)
                messageArray.append(message)
            }
            handler(messageArray)
        }
        
    }
    
    func getAllGroupMessages(forGroup group: Group, handler: @escaping (_ messages: [Message]) -> ()){
        var groupMessageArray: [Message] = [Message]()
        REF_GROUPS.child(group.key).child("messages").observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupMessages = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for groupMessage in groupMessages{
                let senderId = groupMessage.childSnapshot(forPath: "senderId").value as! String
                let content = groupMessage.childSnapshot(forPath: "content").value as! String
                let message: Message = Message(senderId: senderId, content: content)
                groupMessageArray.append(message)
            }
            handler(groupMessageArray)
        }
    }
    
    func getEmail(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()){
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (usersSnapshot) in
            guard let users = usersSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in users {
                let email = user.childSnapshot(forPath: "email").value as! String
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping (_ idsArray: [String]) -> ()){
        var idsArray: [String] = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (usersSnapshot) in
            guard let users = usersSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in users {
                let email = user.childSnapshot(forPath: "email").value as! String
                if usernames.contains(email){
                    idsArray.append(user.key)
                }
            }
            handler(idsArray)
        }
    }
    
    func createGroup(withTitle title: String, withDescription description: String, forUsersIds ids: [String], sendComplete: @escaping (_ groupCreate: Bool) -> ()){
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "description": description, "members": ids])
        sendComplete(true)
    }
    
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupSnapshot {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    let group = Group(title: title, description: description, key: group.key, members: memberArray, memberCount: memberArray.count)
                    groupsArray.append(group)
                }
            }
            handler(groupsArray)
        }
    }
    
    
    func getEmails(forGroup group: Group, handler: @escaping (_ emailArray: [String]) -> ()){
        var emailArray : [String] = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot{
                if group.members.contains(user.key){
                    let email = user.childSnapshot(forPath: "email").value as! String
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
}












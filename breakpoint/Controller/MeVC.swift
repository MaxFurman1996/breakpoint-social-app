//
//  MeVC.swift
//  breakpoint
//
//  Created by Max Furman on 9/9/17.
//  Copyright © 2017 Max Furman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailLbl.text = Auth.auth().currentUser?.email
        DataService.instance.REF_USERS.observe(.value) { (snapshot) in
            if let snap = snapshot.children.allObjects as? [DataSnapshot] {
                for user in snap {
                    if user.key == Auth.auth().currentUser?.uid {
                        guard let profileImageUrl = user.childSnapshot(forPath: "profileImageUrl").value as? String else {
                            self.profileImage.image = UIImage(named: "defaultProfileImage")
                            return
                        }
                        let email = user.childSnapshot(forPath: "email").value as! String
                        self.emailLbl.text = email
                        let img = MeVC.imageCache.object(forKey: profileImageUrl as NSString)
                        if img != nil {
                            self.profileImage.image = img
                        } else {
                            let ref = Storage.storage().reference(forURL: profileImageUrl)
                            ref.getData(maxSize: 2 * 1024 * 1024, completion: {(data, error) in
                                if error != nil {
                                    print("Unable to download image from Firebase storage")
                                } else {
                                    print("Image downloaded from Firebase storage")
                                    if let imgData = data {
                                        if let img = UIImage(data: imgData){
                                            self.profileImage.image = img
                                            MeVC.imageCache.setObject(img, forKey: profileImageUrl as NSString)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func pickImageBtnPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        let logoutPopUp = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do{
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch{
                print(error.localizedDescription)
            }
        }
        logoutPopUp.addAction(logoutAction)
        present(logoutPopUp, animated: true, completion: nil)
    }
    
}


extension MeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            if let imageData = UIImageJPEGRepresentation(image, 0.2){
                let imgUid = UUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                DataService.instance.REF_STORAGE_IMAGES.child(imgUid).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                    if error != nil {
                        print("Unable to upload image to Firebase storage")
                    } else {
                        print("Successfully uploaded image to Firebase storage")
                        let downloadUrl = metadata?.downloadURL()?.absoluteString
                        if let url = downloadUrl {
                            DataService.instance.uploadProfileImageUrl(forUser: (Auth.auth().currentUser?.uid)!, profileImageUrl: url, handler: { (success) in
                                if success {
                                    self.profileImage.image = image
                                    print("Profile image successfully saved")
                                } else {
                                    print("Can't save profile image")
                                }
                            })
                        }
                    }
                })
            }
            
        } else {
            print("Image wasn't selected")
        }
        dismiss(animated: true, completion: nil)
    }
    
   
}

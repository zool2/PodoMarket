//
//  EditProfileViewController.swift
//  PodoMarket
//
//  Created by 정주리 on 2021/03/25.
//  Copyright © 2021 zool2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Toast_Swift

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let db = Firestore.firestore()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var nickname: String = ""
    var loginID: String = ""
    var imageURL: String = ""
    
    var coverView:UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y:0, width:414, height:896)
        view.backgroundColor = UIColor.white
        view.alpha = 0.5
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        
        settingViews()
        loginStatus()
    }

    func settingViews() {
        spinner.isHidden = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.isUserInteractionEnabled = true
        nickname = appDelegate.userInfo.nickName
        textField.text = self.nickname
    }
    
    func loginStatus() {
        nickname = self.appDelegate.userInfo.nickName
        loginID = self.appDelegate.userInfo.loginID
        imageURL = self.appDelegate.userInfo.imageProfileURL
        
        imageView.sd_setImage(with: URL(string: imageURL))
        textField.text = "\(nickname)"
    }
    
    @objc func imagePicker() {
    
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveModificationsTapped(_ sender: Any) {
        
        guard let newNickname = textField.text else { return }
        
        self.view.addSubview(self.coverView)
        spinner.isHidden = false
        spinner.startAnimating()
        
        let imageData = self.imageView.image!.pngData()!
        let storage = Storage.storage()
        let storageRef = storage.reference()
                            
        let riversRef = storageRef.child("userProfileImage").child("\(loginID).png")
            _ = riversRef.putData(imageData, metadata: nil) { metadata, error in
                                
            guard metadata != nil else { return } // return = an error occurred!
            
            // 업로드한 imgUrl을 다운로드
            riversRef.downloadURL { url, error in
                
                guard let downloadURL = url else {
                    return
                }
                // storage에서 프로필이미지 URL가져오기
                self.imageURL = downloadURL.absoluteString
                
                // firestore에 회원정보 저장.
                let db = Firestore.firestore()
                
                db.document("users/\(self.loginID)").updateData([
                    "nickname" : newNickname,
                    "profileImageURL" : self.imageURL
                ]) { error in
                    if error != nil {
                        print("업데이트 안됨.")
                    } else {
                        print("업데이트 완료")
                        self.appDelegate.userInfo.nickName = newNickname // 파이어베이스에 저장된 정보
                        self.appDelegate.userInfo.imageProfileURL = self.imageURL
                        self.spinner.stopAnimating()
                        self.spinner.isHidden = true
                        self.view.makeToast("정보 수정 완료!",
                        duration: 2,
                        point: CGPoint(x: 207, y: 300),
                        title: nil,
                        image: nil,
                        style: .init(),
                        completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
}

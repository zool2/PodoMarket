//
//  SignUpViewController.swift
//  PodoMarket
//
//  Created by 주리 on 8/20/19.
//  Copyright © 2019 zool2. All rights reserved.

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import NVActivityIndicatorView
import Toast_Swift

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lableError: UILabel!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    @IBOutlet weak var textFieldNickname: UITextField!
    @IBOutlet weak var buttonSignup: UIButton!
    
    var imageViewStatus = false
    
    var coverView:UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y:0, width:414, height:896)
        view.backgroundColor = UIColor.white
        view.alpha = 0.5
        
        return view
    }()
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 180, y: 448, width: 50, height: 50),
    type: .ballRotateChase,
    color: .black,
    padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        settingViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK:- 포트폴리오 코드
    @IBAction func signUpTapped(_ sender: Any) {
        
        // textField 데이터 공백 없애기
        let nickname = textFieldNickname.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = textFieldEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = textFieldConfirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nickname == "" || email == "" ||
            password == "" || confirmPassword == "" {
            showError("모든 입력란을 작성해주세요!")
            return
        }
        
        if imageViewStatus == false {
            showError("프로필 사진을 설정해주세요!")
            return
        }
        
        if password != confirmPassword {
            showError("비밀번호가 일치하지 않습니다!")
            return
        }
        
        setUpLoadingView()
        
        // 회원 계정 생성
        Auth.auth()
            .createUser( withEmail: email,
                         password: password) { result, error in
                 
            if let error = error {
                print(error)
                self.showError("회원가입에 실패하셨습니다. 형식을 잘 지켜주세요")
                return
            }
                            
            let uid = result!.user.uid
            print("uid: \(uid)")
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let town = appDelegate.townSetting.town
                
            // profile image를 storage에 저장.
            let imageData = self.imageView.image!.pngData()!
                
            let storage = Storage.storage()
            let storageRef = storage.reference()
                
            // 프로필 이미지: 사용자 email이름으로 저장.
            let riversRef = storageRef.child("userProfileImage").child("\(email).png")
                
            // storage에 프로필 이미지 업로드
            _ = riversRef.putData(imageData, metadata: nil) { metadata, error in
                
                guard metadata != nil else { return }
                
                riversRef.downloadURL { url, error in
                    
                    guard let downloadURL = url else { return }
                    
                    // storage에서 프로필 이미지 다운로드
                    let downloadImageURL = downloadURL.absoluteString
                    
                    // firestore에 회원정보 업로드 후 로그인View 이동.
                    let db = Firestore.firestore()
                    
                    db.document("users/\(email)").setData([
                        "email": email,
                        "nickname": nickname,
                        "town": town,
                        "profileImageURL": downloadImageURL
                    ]) { error in
                        if error != nil {
                            print("저장 안됨.")
                        } else {
                            print("회원정보 저장됨")
                        }
                    }
                    
                    self.indicator.stopAnimating()
                    
                    self.makeToast(message: "회원가입이 완료되었습니다!")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
                        loginVC.loginID = email
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
    }
    
    func settingViews() {
        lableError.alpha = 0
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.isUserInteractionEnabled = true
        
        buttonSignup.layer.cornerRadius = 5
    }
    
    func setUpLoadingView() {
        self.view.addSubview(self.coverView)
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
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
        self.imageViewStatus = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func showError(_ message: String ) {
        lableError.text = message
        lableError.alpha = 1
    }
    
    func makeToast(message: String) {
        self.view.makeToast(message,
        duration: 2,
        point: CGPoint(x: 207, y: 300),
        title: nil,
        image: nil,
        style: .init(),
        completion: nil)
    }
    
}

//func loadLogInVC() {
//    let LogInViewController =
//        storyboard?.instantiateViewController(withIdentifier:"LogInViewController") as? LogInViewController
//
//    view.window?.rootViewController = LogInViewController
//    view.window?.makeKeyAndVisible()
//}

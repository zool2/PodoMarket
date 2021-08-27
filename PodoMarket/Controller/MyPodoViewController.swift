//
//  MyPodoViewController.swift
//  PodoMarket
//
//  Created by 주리 on 8/20/19.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class MyPodoViewController: UIViewController {

    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var lableUserLoginStatus: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonSoldOutList: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var nickname: String = ""
    var loginID: String = ""
    var imageURL: String = ""
    var imageUser: UIImage = UIImage(named: "user.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        loginStatus()
    }
    
    func loginStatus() {
        nickname = self.appDelegate.userInfo.nickName
        loginID = self.appDelegate.userInfo.loginID
        imageURL = self.appDelegate.userInfo.imageProfileURL
        
        if nickname == "" {
            lableUserLoginStatus.text = "로그인"
            imageView.image = self.imageUser
            contentView.isHidden = true
        } else {
            lableUserLoginStatus.text = "\(nickname)"
            buttonSignUp.isHidden = true
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.sd_setImage(with: URL(string:imageURL)) // 초기화면 이미지
        }
    }

    @IBAction func buttonSignUp(_ sender: Any) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        self.navigationController?.pushViewController(signUpVC!, animated: true)
    }
    
    @IBAction func userStatusTapped(_ sender: Any) {
        if lableUserLoginStatus.text == "로그인" {
            let LoginVC = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController
            self.navigationController?.pushViewController(LoginVC!, animated: true)
        } else {
            let UserProfileVC = storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileViewController
            self.navigationController?.pushViewController(UserProfileVC!, animated: true)
        }
    }

}

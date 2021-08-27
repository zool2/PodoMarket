//
//  FindTownViewController.swift
//  PodoMarket
//
//  Created by TJ on 13/08/2019.
//  Copyright © 2019 zool2. All rights reserved.
//
// 연습용 위해 바꾼 것 - recieveTownName ""에 서초동 넣고, buttonGoHome hidden 해제 해둠.

import UIKit
import FirebaseAuth
import Firebase

class FindTownViewController: UIViewController {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var buttonTownFind: UIButton!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelAskEnter: UILabel!
    @IBOutlet weak var buttonGoHome: UIButton!

    var recieveTownName: String = "" // WebView에서 동네 이름 받아옴.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        setUpView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgWeb" {
            if let destinationVC = segue.destination as? WebViewController {
                destinationVC.mainVC = self
            }
        }
    }

    @IBAction func goHomeViewTapped(_ sender: Any) {
        
        saveTownName()
        
        labelAddress.text = ""
        recieveTownName = ""
        
        let homeTabbar = storyboard?.instantiateViewController(withIdentifier: "HomeTabbarController") as? UITabBarController
        self.present(homeTabbar!, animated: true, completion: nil)
    }
    
    func setUpView() {
        buttonTownFind.layer.cornerRadius = 5
        buttonGoHome.layer.cornerRadius = 5
        
        labelAddress.text = recieveTownName
        
        if recieveTownName != "" {
            buttonGoHome.isHidden = false
            labelAskEnter.isHidden = false
        } else {
            buttonGoHome.isHidden = true
            labelAskEnter.isHidden = true
        }
    }
    
    func saveTownName() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let myLoginID = appDelegate.userInfo.loginID
        
        if myLoginID == "" {
            appDelegate.townSetting.town = recieveTownName
            print("savetown:\(appDelegate.townSetting.town)")
        } else { // 회원
            appDelegate.userInfo.town = recieveTownName
            appDelegate.townSetting.town = recieveTownName
            print("savetown:\(appDelegate.townSetting.town)")
        }
    }
 
}



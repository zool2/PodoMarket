//
//  SplashViewController.swift
//  PodoMarket
//
//  Created by TJ on 24/09/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class SplashViewController: UIViewController {
    
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRemoteConfig()
    }
    
    func setRemoteConfig() {
        
        remoteConfig = RemoteConfig.remoteConfig() //firebase로 서버에서 관리할 수 있게 함.
        
        let remoteConfigSettings = RemoteConfigSettings()
        
        remoteConfig.configSettings = remoteConfigSettings
        
        // 서버값 받기 (원격 구성 데이터 받아오기, 지속시간 설정)
        remoteConfig.fetch(withExpirationDuration: TimeInterval(5)) { status, error -> Void in
            
            if status == .success {
                print("Config fetched!") //성공
                self.remoteConfig.activate()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
            self.displayRemoteKeyValue()
        }
    }
    
    // firebase Remote Config의 키 값 받아오기 = plist 또는 firebase remote config에서 설정한 값
    func displayRemoteKeyValue() {
    
        // Firebase에서 설정한 값. 
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        // splash_message_caps 기본값 = false 앱 실행, true = 서버 점검
        if caps == true { // true 앱 강제 종료
            let alert = UIAlertController(title: "공지사항",
                                          message: message,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인",
                                          style: UIAlertAction.Style.default,
                                          handler: { action in
                                                    exit(0) })) // 0을 넣으면 앱이 꺼짐
            self.present(alert, animated: true, completion: nil)
            
        } else { // false 앱 시작
            let startVC = self.storyboard?.instantiateViewController(withIdentifier: "StartVC") as! StartViewController
            
            self.navigationController?.pushViewController(startVC, animated: true)
        }
    }

}

// https://studyhard24.tistory.com/52
// https://github.com/firebase/quickstart-ios/tree/master/config
// RemoteConfigDefaults.plist 추가해서 하는 방법
//        let caps = remoteConfig.defaultValue(forKey: "splash_message_caps")!.boolValue
//        let message = remoteConfig.defaultValue(forKey: "splash_message")!.stringValue

// func setRemoteConfig에서
// remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
// 활성화 안해도 실행 됨.


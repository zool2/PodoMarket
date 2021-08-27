//
//  AppDelegate.swift
//  PodoMarket
//
//  Created by TJ on 02/08/2019.
//  Copyright © 2019 zool2. All rights reserved.
//   3/22 iOS target 12.2
// pod 'ObjectMapper', '~>3.1'

//MARK: "#pragma mark" 와 비슷
//TODO: 언젠간 하고 말꺼얌!
//FIXME: 이거 고쳐주삼!
//???: 이게 뭘까?

import UIKit
import Firebase
import FirebaseFirestore

struct UserInfo {
    var loginID: String = ""
    var nickName: String = ""
    var town: String = ""
    var imageProfileURL: String = ""
}

struct TownSetting{
    var town: String = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?

    // 사이드 메뉴 설정
    lazy var myPodoMenu: MyPodoMenuNavigationController? = nil
    lazy var homeViewController: HomeViewController? = nil
    
    var userInfo: UserInfo = UserInfo()
    var townSetting: TownSetting = TownSetting()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        _ = Firestore.firestore()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//        
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }

}

//extension AppDelegate: MessagingDelegate {
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//
//        let dataDict:[String: String] = ["token": fcmToken]
//        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//        // TODO: If necessary send token to application server.
//        // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage){
//        print("Message Data", remoteMessage.appData)
//    }
//}

// func didFinishLaunchingWithOptions
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
//        } else {
//            // let settings: UIUserNotificationSettings
//            let _ : UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerForRemoteNotifications()
//        }
        //메시지 대리자 설정
//        Messaging.messaging().delegate = self
//        application.registerForRemoteNotifications()

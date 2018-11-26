//
//  AppDelegate.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 10/12/17.
//  Copyright © 2017 EmberRoar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwifteriOS
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
//import GoogleMobileAds

//how to autoarrange text CTRL + I

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate  {
    
    var window: UIWindow?
    var drawerContainer : MMDrawerController?
    static var onBoardingCompleted: Bool?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "onboardingComplete"){
            AppDelegate.onBoardingCompleted = true
        }else {
            AppDelegate.onBoardingCompleted = false
        }
        
        buildNavigationDrawerInterface()
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        showPushNotification(application: application)
        UserDefaults.standard.set("UtRNXcs08szsUw7kSJOso9aWY9420", forKey: "twitterConsumerKey") //GET_YOUR_OWN_KEY
        UserDefaults.standard.set("HvNG0OzkAGKB9420XZxxLXIp0vqCfhinHMytYukMmUy89YjmyaXrhP", forKey: "twitterConsumerSecretKey")//GET_YOUR_OWN_KEY
        
        return true
    }
    
    //this is not working, figure it out
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("remote message ", remoteMessage)
    }
    
    //this is the solution so that you dont have to keep
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Swifter.handleOpenURL(url)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Swifter.handleOpenURL(url as URL)
        
        return true
    }
    
    //    func application(application: UIApplication!, openURL url: NSURL!, sourceApplication: String!, annotation: AnyObject!) -> Bool {
    //        Swifter.handleOpenURL(url as URL)
    //
    //        return true
    //    }
    
    //    func applicationWillResignActive(_ application: UIApplication) {
    //        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    //        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    //    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //this doesn't mean you wont get notifications, it just means you wont be wasting bandwidth
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    //    func applicationWillEnterForeground(_ application: UIApplication) {
    //        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //how to do messaging https://www.youtube.com/watch?v=LBw5tuTvKd4
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
       // print("userInfo: ", userInfo)
        showPushNotification(application: application)
        // print("messageID: ", userInfo["gcm_message_id"]!)
    }
    
    
    //    func applicationWillTerminate(_ application: UIApplication) {
    //        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //    }
    
    func buildNavigationDrawerInterface () {
        print("speed in appdelegate")
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let onBoardingPage = mainStoryBoard.instantiateViewController(withIdentifier: "OnBoardViewController") as! OnBoardMain
        let mainPage:TabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        let loginMenu:AuthViewReal = mainStoryBoard.instantiateViewController(withIdentifier: "AuthViewReal") as! AuthViewReal
        
        if (AppDelegate.onBoardingCompleted)!{
            drawerContainer = MMDrawerController(center: mainPage, leftDrawerViewController: loginMenu)
        }else {
            drawerContainer = MMDrawerController(center: onBoardingPage, leftDrawerViewController: loginMenu)
        }
        window?.rootViewController = drawerContainer
    }
    
    
    @objc func refreshToken(notification: NSNotification){
        let refreshToken = InstanceID.instanceID().token()!
        print("*** ", refreshToken)
    }
    
    func showPushNotification (application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginMenu:AuthViewReal = mainStoryBoard.instantiateViewController(withIdentifier: "AuthViewReal") as! AuthViewReal
        let mainPage:TabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        drawerContainer = MMDrawerController(center: mainPage, leftDrawerViewController: loginMenu)
        window?.rootViewController = drawerContainer
        mainPage.selectedIndex = 0
    }
    
    //how to do messaging https://www.youtube.com/watch?v=LBw5tuTvKd4
    
    func doRandomShit(){
        
    }
    
}


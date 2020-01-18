//
//  AppDelegate.swift
//  bDriver
//
//  Created by TakashiYamamoto on 2017/01/08.
//  Copyright (c) 2017年 VagabondWorks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var myNavigationController: UINavigationController?
    
    var my1ViewController:ScanViewController!
    var my2ViewController:ControlViewController!
    var my3ViewController:SettingViewController!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("# AppDelegate:application() invoked.")
        
        // アプリが勝手にスリープしないようにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        //ViewControllerのインスタンス化
        //let myViewController: ViewController = ViewController()
        my3ViewController = SettingViewController()
        my2ViewController = ControlViewController()
        my1ViewController = ScanViewController()

        
        self.my1ViewController.setControlViewController(my2ViewController)
        
        self.my2ViewController.setScanViewController(my1ViewController)
        self.my2ViewController.setSettingViewController(my3ViewController)
        
        self.my3ViewController.setControlViewController(my2ViewController)
        self.my3ViewController.setScanViewController(my1ViewController)
        
        // アニメーションを設定する.
        my1ViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        my2ViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        my3ViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        
        //UINavigationControllerのインスタンス化とrootViewControllerの指定
        myNavigationController = UINavigationController(rootViewController: my1ViewController)
        
        //UIWindowのインスタンス化
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        //UIWindowのrootViewControllerにnavigationControllerを指定
        self.window?.rootViewController = myNavigationController
        
        //UIWindowの表示
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("# AppDelegate:applicationWillResignActive() invoked.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationWillResignActive"), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("# AppDelegate:applicationDidEnterBackground() invoked.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("# AppDelegate:applicationWillEnterForeground() invoked.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("# AppDelegate:applicationDidBecomeActive() invoked.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationDidBecomeActive"), object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("# AppDelegate:applicationWillTerminate() invoked.")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationWillTerminate"), object: nil)
    }
    
    
}


//
//  bDriver2App.swift
//  bDriver2
//
//  Created by OfCourseIStillLoveYou on 2022/03/27.
//

import SwiftUI
//var bDriver = bCoreDriver()
//bDriver.initDeviceControl()
//bDriver.startBLE()

@main
struct bDriver2App: App {
    @Environment(\.scenePhase) private var scenePhase
    var bDriver = bCoreDriver()
  
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(bDriver)
            //bDriver.initDeviceControl()
            //bDriver.startBLE()
        }
      
      
      
    .onChange(of: scenePhase) { scene in
      switch scene {
        case .active:
          print("scenePhase: active")
          UIApplication.shared.isIdleTimerDisabled = true
          //bDriver.initDeviceControl()
          //bDriver.startBLE()
          //bDriver.timerStart()

        case .inactive:
          print("scenePhase: inactive")
          
        case .background:
          print("scenePhase: background")
          bDriver.timerStop()
          bDriver.motionStop()
          bDriver.disconnectBLE()
          UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
          Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            exit(0)
          }

        @unknown default: break
      }
    }
  }
}


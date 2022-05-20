//
//  bDriver.swift
//  bDriver
//
//  Created by OfCourseIStillLoveYou on 2022/03/27.
//  Copyright © 2022 vagabondworks. All rights reserved.
//

import Foundation
//import Network
//import NetworkExtension
//import SystemConfiguration.CaptiveNetwork

import SwiftUI
//import Combine

//import CoreLocation
//import AVFoundation

import CoreBluetooth

//import Starscream

import UIKit
import CoreMotion


//
// NVM
//
struct bDriverConfig : Codable {
  
  var id   : String = ""
  var name : String = ""
  
  var style : Int = 1
  
  var mot1Flip : Bool = false
  var mot2Flip : Bool = false
  var srv1Flip : Bool = false
  var srv2Flip : Bool = false
  var srv3Flip : Bool = false
  var srv4Flip : Bool = false
  
  var mot1Hide : Bool = false
  var mot2Hide : Bool = false
  var srv1Hide : Bool = false
  var srv2Hide : Bool = false
  var srv3Hide : Bool = false
  var srv4Hide : Bool = false
  
  var srv2Sync : Bool = false
  var srv3Sync : Bool = false
  var srv4Sync : Bool = false
  
  var srv1Motion : Int = 1
  var srv2Motion : Int = 1
  var srv3Motion : Int = 1
  var srv4Motion : Int = 1

  var sliderValueSrv1Trim : Double = 50.0
  var sliderValueSrv2Trim : Double = 50.0
  var sliderValueSrv3Trim : Double = 50.0
  var sliderValueSrv4Trim : Double = 50.0
}

struct bDriverGCConfig : Codable {
  var srv1Selecter : Int = 1
  var srv2Selecter : Int = 2
  var srv3Selecter : Int = 3
  var srv4Selecter : Int = 4
}

struct bCoreList {
  var id : String
  var name : String
  var color : Color
  var peripheral    : CBPeripheral!
  
  init(id : String, name : String, color : Color, peripheral    : CBPeripheral) {
    self.id = id
    self.name = name
    self.color = color
    self.peripheral = peripheral
  }
}

//
//
//
class bCoreDriver : NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
  
  @Published var config   = bDriverConfig()
  @Published var gcConfig = bDriverGCConfig()
  @Published var bleList : [bCoreList] = []
  
  @Published var newName : String = ""
  
  @Published var  mot1LabelHide : Bool = false
  @Published var  mot2LabelHide : Bool = false
  @Published var  srv1LabelHide : Bool = false
  @Published var  srv2LabelHide : Bool = false
  @Published var  srv3LabelHide : Bool = false
  @Published var  srv4LabelHide : Bool = false
  @Published var  led1LabelHide : Bool = false
  @Published var  led2LabelHide : Bool = false
  @Published var  led3LabelHide : Bool = false
  @Published var  led4LabelHide : Bool = false
  
  @Published var  gameControllerConnected : Bool = false
  @Published var  gameControllerHide      : Bool = true
  @Published var  gameControllerString    : String = ""
  
  @Published var  style1Hide : Bool = true
  @Published var  style2Hide : Bool = false
  @Published var  style3Hide : Bool = false
  @Published var  style4Hide : Bool = false
  @Published var  style5Hide : Bool = false
  
  @Published var posMXSX : CGFloat = 0
  @Published var posMXSX0 : CGFloat = 0
  @Published var posMXSX1 : CGFloat = 0

  let motionManager = CMMotionManager()
  var motionStarted : Bool = false
  
  func motionStart() {
    if self.motionManager.isDeviceMotionAvailable {
      self.motionManager.deviceMotionUpdateInterval = 0.1
      self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
        self.updateMotionData(deviceMotion: motion!)
      })
    }
      
    motionStarted = true
  }
  
  func motionStop() {
    motionStarted = false
    self.motionManager.stopDeviceMotionUpdates()
  }
  
  private func updateMotionData(deviceMotion:CMDeviceMotion) {
    var pitch : Double = (deviceMotion.attitude.roll/Double.pi * 100.0 + 50)
    var roll  : Double = (deviceMotion.attitude.pitch/Double.pi * 100.0 + 50)
    var yaw   : Double = (deviceMotion.attitude.yaw/Double.pi * 100.0 + 50)
    
    if pitch < 0 {
      pitch = 0
    }
    if pitch > 100 {
      pitch = 100
    }
    if roll < 0 {
      roll = 0
    }
    if roll > 100 {
      roll = 100
    }
    if yaw < 0 {
      yaw = 0
    }
    if yaw > 100 {
      yaw = 100
    }
    //let pStr = String(pitch)
    //let rStr = String(roll)
    //let yStr = String(yaw)

    //print("pitch = " + pStr + "/ roll = " + rStr + "/ yaw = " + yStr)
    
    if self.gameControllerConnected == false {
      // Roll Pitcj Yaw to slider
      if (self.config.srv1Motion == 2) {
        self.sliderValueSrv1 = roll
      } else
      if (self.config.srv1Motion == 3) {
        self.sliderValueSrv1 = pitch
      } else
      if (self.config.srv1Motion == 4) {
        self.sliderValueSrv1 = yaw
      }
      if (self.config.srv2Motion == 2) {
        self.sliderValueSrv2 = roll
      } else
      if (self.config.srv2Motion == 3) {
        self.sliderValueSrv2 = pitch
      } else
      if (self.config.srv2Motion == 4) {
        self.sliderValueSrv2 = yaw
      }
      if (self.config.srv3Motion == 2) {
        self.sliderValueSrv3 = roll
      } else
      if (self.config.srv3Motion == 3) {
        self.sliderValueSrv3 = pitch
      } else
      if (self.config.srv3Motion == 4) {
        self.sliderValueSrv3 = yaw
      }
      if (self.config.srv4Motion == 2) {
        self.sliderValueSrv4 = roll
      } else
      if (self.config.srv4Motion == 3) {
        self.sliderValueSrv4 = pitch
      } else
      if (self.config.srv4Motion == 4) {
        self.sliderValueSrv4 = yaw
      }
      
      if self.config.style == 5 {
        if self.config.srv1Motion != 1 {
          // MX Style Steering position feedback
          self.posMXSX = posMXSX0 + posMXSX1 * (self.sliderValueSrv1 - 50)/50
        }
      }
    }
  }
  
  func styleUpdate() {
    if (self.config.style == 1) {
      self.style1Hide = false
      self.style2Hide = true
      self.style3Hide = true
      self.style4Hide = true
      self.style5Hide = true
    } else
    if (self.config.style == 2) {
      self.style1Hide = true
      self.style2Hide = false
      self.style3Hide = true
      self.style4Hide = true
      self.style5Hide = true
    } else
    if (self.config.style == 3) {
      self.style1Hide = true
      self.style2Hide = true
      self.style3Hide = false
      self.style4Hide = true
      self.style5Hide = true
    } else
    if (self.config.style == 4) {
      self.style1Hide = true
      self.style2Hide = true
      self.style3Hide = true
      self.style4Hide = false
      self.style5Hide = true
    } else
    if (self.config.style == 5) {
      self.style1Hide = true
      self.style2Hide = true
      self.style3Hide = true
      self.style4Hide = true
      self.style5Hide = false
    }
  }
  
  override init() {
    super.init()
    print("SYS> bCoreDriver.init()")
    self.initDeviceControl()
    self.startBLE()
    self.motionStart()
  }
  
  func initDeviceControl() {
    print("SYS> initDeviceControl()")
    
    self.sliderValueMot1 = 50.0
    self.sliderValueMot2 = 50.0
    self.sliderValueSrv1 = 50.0
    self.sliderValueSrv2 = 50.0
    self.sliderValueSrv3 = 50.0
    self.sliderValueSrv4 = 50.0
    
    self.buttonValueLED1 = false
    self.buttonColorLED1 = Color.gray
    self.buttonValueLED2 = false
    self.buttonColorLED2 = Color.gray
    self.buttonValueLED3 = false
    self.buttonColorLED3 = Color.gray
    self.buttonValueLED4 = false
    self.buttonColorLED4 = Color.gray

    self.hideBLEList = false
    self.hideActivityIndicator = true
    self.isWaitingForBLEConnection = false

    //self.isTimerRunning = false
    //self.loadWiFiList()
  }
  
  func saveConfig() {
    print("SYS> saveConfig()")
    print(self.config)
    if (self.bCoreID.hasPrefix("bCore_")) && (self.bCoreID.count == 18) {
      
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      //encoder.keyEncodingStrategy = .convertToSnakeCase
      if let value = try? encoder.encode(self.config) {
        print(String(bytes: value, encoding: .utf8)!)
        UserDefaults.standard.set(value, forKey: self.bCoreID)
      }
    } else {
      print(" Invalid ID : " + self.bCoreID)
    }
  }
  
  func loadConfig() {
    print("SYS> loadConfig()")
    if (self.bCoreID.hasPrefix("bCore_")) && (self.bCoreID.count == 18) {
      
      if let savedValue = UserDefaults.standard.data(forKey: self.bCoreID) {
        print(String(bytes: savedValue, encoding: .utf8)!)
        
        let decoder = JSONDecoder()
        if let value = try? decoder.decode(bDriverConfig.self, from: savedValue) {
          //DispatchQueue.main.async {
            self.config = value
          //}
          self.styleUpdate()
        }
      } else {
        // 値がない場合の処理
        print(" No saved data ID : " + self.bCoreID)
        self.config.id = self.bCoreID
        self.config.name = self.bCoreID
      }
    } else {
      print(" Invalid ID : " + self.bCoreID)
    }
    print("self.config")
    print(self.config)
  }

  // for Game Controller
  func saveGCConfig() {
    print("SYS> saveGCConfig()")
    print(self.gcConfig)
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    //encoder.keyEncodingStrategy = .convertToSnakeCase
    if let value = try? encoder.encode(self.gcConfig) {
      print(String(bytes: value, encoding: .utf8)!)
      UserDefaults.standard.set(value, forKey: "GCConfig")
    }
  }
  
  // for Game Controller
  func loadGCConfig() {
    print("SYS> loadGCConfig()")
    
      if let savedValue = UserDefaults.standard.data(forKey: "GCConfig") {
        print(String(bytes: savedValue, encoding: .utf8)!)
        
        let decoder = JSONDecoder()
        if let value = try? decoder.decode(bDriverGCConfig.self, from: savedValue) {
          //DispatchQueue.main.async {
            self.gcConfig = value
          //}
        }
      } else {
        // 値がない場合の処理
        print(" No saved GC Config data")
      }
    print("self.gcConfig")
    print(self.gcConfig)
  }
  
  
  
  //
  // BLE Scan to find bCore
  //
  @Published var hideBLEList: Bool = false
  var centralManager: CBCentralManager!
  var peripheral    : CBPeripheral!
  var bCoreservice  : CBService!
  var characteristicGetBatteryVoltage : CBCharacteristic!
  var characteristicBurstCommand      : CBCharacteristic!
  var characteristicGetFunctions      : CBCharacteristic!
  var bleScanActive : Bool = false
  var isConnected2bCore     : Bool = false
  @Published var connectionStatus : String = "No Connection"
  @Published var connectionColor : Color = Color.gray
  @Published var showQuitAlartConnectionLost : Bool = false
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch (central.state) {
      case .unknown:
        print("BLE> DidUpdateState:unknown")
      case .resetting:
        print("BLE> DidUpdateState:resetting")
      case .unsupported:
        print("BLE> DidUpdateState:unsupported")
      case .unauthorized:
        print("BLE> DidUpdateState:unauthorized")
      case .poweredOff:
        print("BLE> DidUpdateState:poweredOff")
      case .poweredOn:
        print("BLE> DidUpdateState:poweredOn")
        if (bleScanActive == false) {
          print("BLE> Start BLE scan")
          self.bleScanActive = true
          self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
      @unknown default:
        print("BLE> DidUpdateState:unknown")
    }
    return
  }
  
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any],
                      rssi RSSI: NSNumber
  ) {
    //
    let localname = advertisementData["kCBAdvDataLocalName"]

    if (localname != nil) {
      let id = (localname ?? "Nil")as! String
      //print("BLE> DidDiscoverPperipheral [ \(id) , \(id.count)]")
      
      if (id.hasPrefix("bCore_") && (id.count == 18)) {
        print("BLE> DidDiscover bCore : \(id) / RSSI : \(RSSI)")
        var found : Bool = false
        for list in self.bleList {
          // Already list has this item
          if (list.id == id) {
            found = true
            print("Found List ID : \(id) - already in the list")
          }
        }
        if (found == false) {
          // Add new item to List
          var tmpname : String = id
          if let configData = UserDefaults.standard.data(forKey: id) {
            let decoder = JSONDecoder()
            if let tconfig = try? decoder.decode(bDriverConfig.self, from: configData) {
              tmpname = tconfig.name
            }
          }
          print("New List ID   [\(id)]")
          print("New List Name [\(tmpname)]")
          if (tmpname == "") {
            tmpname = id
          }
          
          // SwiftUIの表示データはprint("New List Name : " +  tmpname)Forgroundになってからしか変更してはいけないので
          let rssi : Int = Int(truncating: RSSI)
          var color : Color = Color.gray
          if (rssi > -45) {
            color = Color.blue
          } else 
          if (rssi > -60) {
            color = Color.green
          } else
          if (rssi > -75) {
            color = Color.yellow
          } else
          if (rssi > -90) {
            color = Color.red
          } else {
            color = Color.black
          }
          
          DispatchQueue.main.async {
            self.bleList.append(bCoreList(id: id, name: tmpname, color: color, peripheral: peripheral))
          }
          
          print("Current List Size : \(String(self.bleList.count))")
          //print(self.bleList)
        }
      }
    }
  }
  
  // デバイスへの接続が成功すると呼ばれる
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("BLE> Connected!")
    self.peripheral!.delegate = self
    //指定されたサービスを探す
    self.peripheral!.discoverServices([CBUUID(string: "389CAAF0-843F-4D3B-959D-C954CCE14655")])
  }

  // デバイスへの接続が失敗すると呼ばれる
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("BLE> Connect failed...")
  }
  
  // デバイスへの接続が切断されると
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print("BLE> Disconected \(String(describing: error))")
    
    self.bCoreConnectionLost()
    
  }
  
  // サービスの検索が成功したら呼ばれる
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("BLE> Discover Services")
    //let service: CBService = self.peripheral!.services![0]
    self.bCoreservice = self.peripheral!.services![0]
    self.peripheral!.discoverCharacteristics(nil, for: bCoreservice)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    print("BLE> Find Characteristics")
    
    //let data = [送信したいデータ]
    //ペリフェラルの保持しているキャラクタリスティクスから特定のものを探す
    for i in service.characteristics!{
      if (i.uuid.uuidString == "389CAAF1-843F-4D3B-959D-C954CCE14655") {
        // Battery Voltage
        print(" Find Characteristics Battery Voltage")
        self.characteristicGetBatteryVoltage = i
      }
      if (i.uuid.uuidString == "389CAAF5-843F-4D3B-959D-C954CCE14655") {
        // Burst Command
        print(" Find Characteristics Burst Command")
        self.characteristicBurstCommand = i
      }
      if (i.uuid.uuidString == "389CAAFF-843F-4D3B-959D-C954CCE14655") {
        // Get Function
        print(" Find Characteristics Get Function")
        self.characteristicGetFunctions = i
        self.peripheral.readValue(for: self.characteristicGetFunctions)
      }
      
      if (self.characteristicGetFunctions != nil) &&
         (self.characteristicBurstCommand != nil) &&
         (self.characteristicGetBatteryVoltage != nil) {
        
        self.bCoreConnectionStart()
      }

    }
  }
  
  
  var getBatteryVoltageFlag : Bool = false
  func getBatteryVoltage() {
    if (self.getBatteryVoltageFlag == false) {
      self.peripheral.readValue(for: self.characteristicGetBatteryVoltage)
      self.getBatteryVoltageFlag = true
    }
  }
  
  /// キャラクタリスティック値取得・変更時(コマンド送信後、受信時に呼ばれる)
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      print("BLE Read Error! :\(String(describing: error))")
      // 失敗処理
      return
    }
    guard let data = characteristic.value else {
      // 失敗処理
      return
    }
    
    if (characteristic == self.characteristicGetFunctions) && (data.count == 2) {
      let bytedata = [CUnsignedChar](data)
      print("BLE Read GetFunctions:\(bytedata)")
      // bytedata[0] 0x03
      if (bytedata[0] & 0x01) == 0x00 {
        self.mot1LabelHide = true
      }
      if (bytedata[0] & 0x02) == 0x00 {
        self.mot2LabelHide = true
      }
      // bytedata[1] 0xFF
      if (bytedata[1] & 0x01) == 0x00 {
        self.srv1LabelHide = true
      }
      if (bytedata[1] & 0x02) == 0x00 {
        self.srv2LabelHide = true
      }
      if (bytedata[1] & 0x04) == 0x00 {
        self.srv3LabelHide = true
      }
      if (bytedata[1] & 0x08) == 0x00 {
        self.srv4LabelHide = true
      }
      if (bytedata[1] & 0x10) == 0x00 {
        self.led1LabelHide = true
      }
      if (bytedata[1] & 0x20) == 0x00 {
        self.led2LabelHide = true
      }
      if (bytedata[1] & 0x40) == 0x00 {
        self.led3LabelHide = true
      }
      if (bytedata[1] & 0x80) == 0x00 {
        self.led4LabelHide = true
      }
    }
    if (characteristic == self.characteristicGetBatteryVoltage) && (data.count == 2) {
      //print("BLE Read GetBatteryVoltage:\(data.count)")
      let bytedata = [CUnsignedChar](data)
      //print("BLE Read GetBatteryVoltage:\(bytedata)")
      
      var vol : Int32 = 0
      vol += Int32(bytedata[1])
      vol *= 256
      vol += Int32(bytedata[0])
      //print("Voltage : \(NSString(format:"%0.2f", Float(vol)/1000.0) as String)[V] \(bytedata)")
      
      // SwiftUIの表示データはForgroundになってからしか変更してはいけないので
      DispatchQueue.main.async {
        //self.infoBatteryString = "Bat:-.--[V]"
        self.infoBatteryString = "Bat:" + (NSString(format:"%0.2f", Float(vol)/1000.0) as String) + "[V]"
        self.infoBatteryColor = Color.white
      }
      self.getBatteryVoltageFlag = false
    }
  }
  
  func startBLE() {
    print("BLE> startBLE()")
    self.centralManager = CBCentralManager(delegate: self, queue: nil)

    return
  }
  
  func stopBLE() {
    print("BLE> stopBLE()")
    //
    //
    //
    self.centralManager.stopScan()
    // SwiftUIの表示データはForgroundになってからしか変更してはいけないので
    DispatchQueue.main.async {
      self.hideBLEList = true
    }
    return
  }
  
  //
  // UI Control
  //
  @Published var sliderValueMot1 : Double = 50.0
  @Published var sliderValueMot2 : Double = 50.0
  @Published var sliderValueSrv1 : Double = 50.0
  @Published var sliderValueSrv2 : Double = 50.0
  @Published var sliderValueSrv3 : Double = 50.0
  @Published var sliderValueSrv4 : Double = 50.0
  
  @Published var buttonColorLED1 : Color = Color.gray
  @Published var buttonColorLED2 : Color = Color.gray
  @Published var buttonColorLED3 : Color = Color.gray
  @Published var buttonColorLED4 : Color = Color.gray
  
  var buttonValueLED1 : Bool = false
  var buttonValueLED2 : Bool = false
  var buttonValueLED3 : Bool = false
  var buttonValueLED4 : Bool = false

  //
  // LED toggle Control
  //
  func buttonLED1Action() {
    if (self.buttonValueLED1 == false) {
      self.buttonValueLED1 = true
      self.buttonColorLED1 = Color.green
    } else {
      self.buttonValueLED1 = false
      self.buttonColorLED1 = Color.gray
    }
  }
  func buttonLED2Action() {
    if (self.buttonValueLED2 == false) {
      self.buttonValueLED2 = true
      self.buttonColorLED2 = Color.green
    } else {
      self.buttonValueLED2 = false
      self.buttonColorLED2 = Color.gray
    }
  }
  func buttonLED3Action() {
    if (self.buttonValueLED3 == false) {
      self.buttonValueLED3 = true
      self.buttonColorLED3 = Color.green
    } else {
      self.buttonValueLED3 = false
      self.buttonColorLED3 = Color.gray
    }
  }
  func buttonLED4Action() {
    if (self.buttonValueLED4 == false) {
      self.buttonValueLED4 = true
      self.buttonColorLED4 = Color.green
    } else {
      self.buttonValueLED4 = false
      self.buttonColorLED4 = Color.gray
    }
  }

  
  //
  // Timer
  //
  var timer : Timer!
  var count : Int = 0
  var isTimerRunning : Bool = false
  
  func timerStart() {
    print("TM> timerStart()")
    self.isTimerRunning = true
    self.timer?.invalidate()
    self.count = 0
    //self.isConnected2bCore = false
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true)
    {
      _ in
      self.timerAction()
    }
  }
  
  func timerStop() {
    print("TM> timerStop()")
    if (self.isTimerRunning == true) {
      self.isTimerRunning = false
      self.timer.invalidate()
    }
  }
  
  func timerAction() {
    self.count = self.count &+ 1
    
    if (self.isConnected2bCore == true) {
      //print("TM> timerAction(connected)")
      // Send Burst Commsnd
      // Read Battery Info
      self.sendBurestCommand()
      self.getBatteryVoltage()
      //
      //
      //
    } else {
      //print("TM> timerAction(not connected)")
    }
  }
  
  func bCoreConnectionStart() {
    
    print("BLE> bCoreConnectionStart()")

    self.loadConfig()
    self.saveConfig()
    
    print("bCore Connection Start!!!")
    // SwiftUIの表示データはForgroundになってからしか変更してはいけないので
    DispatchQueue.main.async {
      //self.connectionStatus = self.iCoreSSID
      self.connectionStatus = self.bCoreName
      self.connectionColor = Color.white
    }
    self.isConnected2bCore = true
    
    self.isWaitingForBLEConnection = false
    self.hideActivityIndicator = true
    
    self.hideBLEList = true
    self.timerStart()
    
    return;
  }
  
  func bCoreConnectionLost() {
    print("BLE> bCoreConnectionLost()")
    
    // 切れたタイミング
    self.isConnected2bCore = false
    self.timerStop()
    
    print("bCore ConnectionLost!!!")
    // SwiftUIの表示データはForgroundになってからしか変更してはいけないので
    DispatchQueue.main.async {
      self.connectionStatus = "No Connection"
      self.connectionColor = Color.gray
      self.infoBatteryString = "Bat:-.--[V]"
      self.infoBatteryColor = Color.gray
      
      self.showQuitAlartConnectionLost = true
    }

    return;
  }
  
  //
  // BLE Connect
  //
  
  @Published var isWaitingForBLEConnection : Bool = false
  @Published var hideActivityIndicator: Bool = true
  
  var bCoreID   : String = "bdCore_F008D156731C"
  var bCoreName : String = "bdCore_F008D156731C"

  // Call when tapped bCore List on UI
  func bleConnect(id : String, name : String, peripheral : CBPeripheral) {
    self.bCoreID = id
    self.bCoreName = name
    self.peripheral = peripheral
    
    self.bleScanActive = false
    self.centralManager.stopScan()
    
    self.connect2bCoreBLE()
  }

  
  func connect2bCoreBLE() {
    print("BLE> connectbCoreBLE()")
    print(" ID   : " + self.bCoreID)
    print(" Name : " + self.bCoreName)
    
    centralManager!.connect(self.peripheral!, options: nil)
    
    self.isWaitingForBLEConnection = true
    self.hideActivityIndicator = false
    
  }
  
  func disconnectBLE() {
    print("BLE> disconnectBLE()")
    if (self.isConnected2bCore == true) {
      centralManager!.cancelPeripheralConnection(self.peripheral!)
    }
  }

  
  //                         Mot1  Mot2  LED   Srv1  Srv2  Srv3  Srv4
  var burstData : [UInt8] = [0x80, 0x80, 0x0f, 0x80, 0x80, 0x80, 0x80]
  var mot1prev : Int = 128
  var mot2prev : Int = 128
  
  func setBurstData() {
    
    // LED
    self.burstData[2] = 0x00
    if (self.buttonValueLED1 == true) {
      self.burstData[2] = self.burstData[2] + 0x01
    }
    if (self.buttonValueLED2 == true) {
      self.burstData[2] = self.burstData[2] + 0x02
    }
    if (self.buttonValueLED3 == true) {
      self.burstData[2] = self.burstData[2] + 0x04
    }
    if (self.buttonValueLED4 == true) {
      self.burstData[2] = self.burstData[2] + 0x08
    }

    var tmp : Int
    var ratio : Double
    
    // Mot1
    if (self.config.mot1Hide == true) {
      ratio = 50.0
    } else {
      if (self.config.mot1Flip == true) {
        ratio = 100.0 - self.sliderValueMot1
      } else {
        ratio = self.sliderValueMot1
      }
    }
    tmp = Int(255.0 * ratio / 100.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    if (128-16 < tmp) && (tmp < 128+16)  {tmp = 128}
    if (mot1prev > 128) && (tmp < 128)   {tmp = 128}
    if (mot1prev < 128) && (tmp > 128)   {tmp = 128}
    self.burstData[0] = UInt8(tmp)
    self.mot1prev = tmp
    
    // Mot2
    if (self.config.mot2Hide == true) {
      ratio = 50.0
    } else {
      if (self.config.mot2Flip == true) {
        ratio = 100.0 - self.sliderValueMot2
      } else {
        ratio = self.sliderValueMot2
      }
    }
    tmp = Int(255.0 * ratio / 100.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    if (128-16 < tmp) && (tmp < 128+16)  {tmp = 128}
    if (mot2prev > 128) && (tmp < 128)   {tmp = 128}
    if (mot2prev < 128) && (tmp > 128)   {tmp = 128}
    self.burstData[1] = UInt8(tmp)
    self.mot2prev = tmp
    
    // Sync
    /*
    if (self.config.srv2Sync == true) {
      self.sliderValueSrv2 = self.sliderValueSrv1
    }
    if (self.config.srv3Sync == true) {
      self.sliderValueSrv3 = self.sliderValueSrv1
    }
    if (self.config.srv4Sync == true) {
      self.sliderValueSrv4 = self.sliderValueSrv1
    }
    */

    // Srv1
    if (self.config.srv1Flip == true) {
      ratio = 100.0 - self.sliderValueSrv1
    } else {
      ratio = self.sliderValueSrv1
    }
    tmp = Int(255.0 * ratio / 100.0) + Int(16.0 * (self.config.sliderValueSrv1Trim - 50.0) / 50.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    self.burstData[3] = UInt8(tmp)
    // Srv2
    if (self.config.srv2Flip == true) {
      ratio = 100.0 - self.sliderValueSrv2
    } else {
      ratio = self.sliderValueSrv2
    }
    tmp = Int(255.0 * ratio / 100.0) + Int(16.0 * (self.config.sliderValueSrv2Trim - 50.0) / 50.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    self.burstData[4] = UInt8(tmp)
    // Srv3
    if (self.config.srv3Flip == true) {
      ratio = 100.0 - self.sliderValueSrv3
    } else {
      ratio = self.sliderValueSrv3
    }
    tmp = Int(255.0 * ratio / 100.0) + Int(16.0 * (self.config.sliderValueSrv3Trim - 50.0) / 50.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    self.burstData[5] = UInt8(tmp)
    // Srv4
    if (self.config.srv4Flip == true) {
      ratio = 100.0 - self.sliderValueSrv4
    } else {
      ratio = self.sliderValueSrv4
    }
    tmp = Int(255.0 * ratio / 100.0) + Int(16.0 * (self.config.sliderValueSrv4Trim - 50.0) / 50.0)
    if (tmp > 255) {tmp = 255}
    if (tmp < 0  ) {tmp = 0 }
    self.burstData[6] = UInt8(tmp)
    
  }
  
  //
  // Send Burst Command
  //
  func sendBurestCommand() {
    self.setBurstData()
    //print("BLE> sendBurestCommand(\(self.burstData)");
    
    
    
    let senddata = Data(_: self.burstData)
    self.peripheral.writeValue(senddata, for: self.characteristicBurstCommand!, type: CBCharacteristicWriteType.withoutResponse)
    
    return
  }
  
  //
  // Bsttery Information
  //
  private var infoBatteryVoltage : Double = 0.0
  @Published var infoBatteryString : String = "Bat:-.--[V]"
  @Published var infoBatteryColor : Color = Color.gray
  
  
}


struct bDriver_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hello, bCore!")
  }
}

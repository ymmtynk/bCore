//
//  SecondViewController.swift
//  BLEController

//
//  Created by TakashiYamamoto on 2015/05/24.
//  Copyright (c) 2015年 TakashiYamamoto. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion


public class ControlViewController: UIViewController, CBPeripheralDelegate{

    var myScanViewController: ScanViewController!
    var mySettingViewController: SettingViewController!

    var myServiceUuids: NSMutableArray = NSMutableArray()
    var myService: NSMutableArray = NSMutableArray()
    
    var myCentralManager: CBCentralManager!
    var myTargetPeriperal: CBPeripheral!
    var myTargetService: CBService!
 
    var myCharacteristicsUuids: NSMutableArray = NSMutableArray()
    var myCharacteristics: NSMutableArray = NSMutableArray()

    var getBatteryVoltageCharacteristic: CBCharacteristic!
    var setMotorPWMCharacteristic: CBCharacteristic!
    var setPortOutCharacteristic: CBCharacteristic!
    var setServoPositionCharacteristic: CBCharacteristic!
    var getFunctionsCharacteristic: CBCharacteristic!
    var burstCommandCharacteristic: CBCharacteristic!
    
    var voltageLabel: UILabel!
    
    var myMotionManager: CMMotionManager!
    var pitchAngle: Float = 0
    
    //var labelST: UILabel!
    //var labelAX: UILabel!
    
    var labelV: UILabel!
    var labelH: UILabel!
    var labelVD: UILabel!
    var labelHD: UILabel!
    
    var labelHDXPos: CGFloat!
    var labelVDYPos: CGFloat!
    var labelHDXStr: CGFloat!
    var labelVDYStr: CGFloat!
    
    var valueStr:  Float = 0
    var valueAxel: Float = 0
    
    var portOut  = [UIButton](repeating: UIButton(), count: 4)
    
    var servoValid = [Bool](repeating: Bool(false), count: 4)
    var motorValid = [Bool](repeating: Bool(false), count: 4)
    var portValid  = [Bool](repeating: Bool(false), count: 4)
   
    var servoSwing:   Float = 1.0        // rec
    var servoTrim:    Float = 0          // rec
    var subservoTrim: Float = 0          // rec
    var strSW:     Bool = true           // rec
    var servoFlip: Bool = false          // rec
    var motorFlip: Bool = false          // rec
    
    var deviceName: String = "tmp"       // rec

    let wait_time: CUnsignedInt = 25000         // BLEのコマンドウェイト　25msec
    
    var comControl: Bool = false
    
    var comIndex: Int = 0
    var comTimer: Timer!
    
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("#2 ControlViewController:viewDidLoad() invoked.")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willResignActive(_:)),    name: NSNotification.Name(rawValue: "applicationWillResignActive"),    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.didEnterBackground(_:)),  name: NSNotification.Name(rawValue: "applicationDidEnterBackground"),  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willEnterForeground(_:)), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.didBecomeActive(_:)),     name: NSNotification.Name(rawValue: "applicationDidBecomeActive"),     object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willTerminate(_:)),       name: NSNotification.Name(rawValue: "applicationWillTerminate"),       object: nil)
        
        self.view.isMultipleTouchEnabled = true
        
        //self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor = UIColor(red: 123/255, green: 10/255, blue: 10/255, alpha: 1)

        let statusBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        // ジョイスティック風の模様をラベルでかく
        let labelHWidth: CGFloat = self.view.frame.width/10*4
        let labelHHeight: CGFloat = (self.view.frame.height - statusBarHeight)/10*4
        let labelVWidth: CGFloat = labelHHeight
        let labelVHeight: CGFloat = (self.view.frame.height - statusBarHeight)/10*9
        
        // 左のスティック
        self.labelH = UILabel(frame: CGRect(
            x: self.view.frame.width/3 - labelHWidth/2,
            y: (self.view.frame.height - statusBarHeight)/2 - labelHHeight/2 + statusBarHeight,
            width: labelHWidth,
            height: labelHHeight
            )
        )
        self.labelH.backgroundColor = UIColor.clear
        self.labelH.layer.borderColor = UIColor.white.cgColor
        self.labelH.layer.borderWidth = 10
        self.labelH.layer.cornerRadius = self.labelH.frame.height/2
        self.view.addSubview(self.labelH)
        
        // 右のスティック
        self.labelV = UILabel(frame: CGRect(
            x: self.view.frame.width/4*3 - labelVWidth/2,
            y: (self.view.frame.height - statusBarHeight)/2 - labelVHeight/2 + statusBarHeight,
            width: labelVWidth,
            height: labelVHeight
            )
        )
        self.labelV.backgroundColor = UIColor.clear
        self.labelV.layer.borderColor = UIColor.white.cgColor
        self.labelV.layer.borderWidth = 10
        self.labelV.layer.cornerRadius = self.labelV.frame.width/2
        self.view.addSubview(self.labelV)
        
        // スティックの中で動く奴をラベルでかく
        self.labelHDXPos = self.labelH.frame.origin.x + self.labelH.frame.width/2 - (labelHHeight - 10)/2
        self.labelVDYPos = self.labelV.frame.origin.y + self.labelV.frame.height/2 - (labelVWidth - 10)/2
        
        self.labelHDXStr = self.labelH.frame.width/2 - labelHHeight/2
        self.labelVDYStr = self.labelV.frame.height/2 - labelVWidth/2
        
        // 左の丸
        self.labelHD = UILabel(frame: CGRect(
            x: self.labelHDXPos,
            y: self.labelH.frame.origin.y + self.labelH.frame.height/2 - (labelHHeight - 10)/2,
            width:  labelHHeight - 10,
            height: labelHHeight - 10
            )
        )
        self.labelHD.backgroundColor = UIColor.clear
        self.labelHD.layer.borderColor = UIColor.white.cgColor
        self.labelHD.layer.borderWidth = 10
        self.labelHD.layer.cornerRadius = self.labelHD.frame.height/2
        self.view.addSubview(self.labelHD)
        
        // 右の丸
        self.labelVD = UILabel(frame: CGRect(
            x: self.labelV.frame.origin.x + self.labelV.frame.width/2 - (labelVWidth - 10)/2,
            y: self.labelVDYPos,
            width:  labelVWidth - 10,
            height: labelVWidth - 10
            )
        )
        self.labelVD.backgroundColor = UIColor.clear
        self.labelVD.layer.borderColor = UIColor.white.cgColor
        self.labelVD.layer.borderWidth = 10
        self.labelVD.layer.cornerRadius = self.labelVD.frame.width/2
        self.view.addSubview(self.labelVD)
        
        /*
        // DEBUG用のラベル
        self.labelST = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        self.labelST.textColor = UIColor.white
        self.labelST.textAlignment = NSTextAlignment.center
        self.labelST.text = "\(self.valueStr)"
        self.labelST.layer.position = CGPoint(x: self.labelH.frame.origin.x + self.labelH.frame.width/2 - 50, y: self.labelH.frame.origin.y - 20)
        self.view.addSubview(self.labelST)
        
        // DEBUG用のラベル
        self.labelAX = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        self.labelAX.textColor = UIColor.white
        self.labelAX.textAlignment = NSTextAlignment.center
        self.labelAX.text = "\(self.valueAxel)"
        self.labelAX.layer.position = CGPoint(x: self.labelV.frame.origin.x + self.labelV.frame.width/2 - 50, y: self.labelV.frame.origin.y - 20)
        self.view.addSubview(self.labelAX)
        */
        
        //
        //
        //
        //self.loadSaveData()
        
        // Bar Button に Editのボタンをつける
        let myBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(ControlViewController.onClickMyBarButton(_:)))
        self.navigationItem.setRightBarButton(myBarButton, animated: true)
        
        // MotionManagerを生成.
        self.myMotionManager = CMMotionManager()
        // 更新周期を設定.
        self.myMotionManager.deviceMotionUpdateInterval = 0.05
        
        // 電圧表示部
        self.voltageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/6.0*4.0, height: self.view.frame.height*0.1))
        self.voltageLabel.textColor = UIColor.white
        self.voltageLabel.textAlignment = NSTextAlignment.center
        self.voltageLabel.text = "Pow: -.--[V]"
        self.voltageLabel.layer.position = CGPoint(x: self.view.frame.width/2, y: voltageLabel.frame.height/2+statusBarHeight)
        self.view.addSubview(self.voltageLabel);

        // Port Out
        for i in 0..<4 {
            self.portOut[i] = UIButton(
                frame: CGRect(x: 0,
                              y: 0,
                              width: self.view.frame.width/8,
                              height: (self.view.frame.height-statusBarHeight)/10*2
            ))
            self.portOut[i].backgroundColor = UIColor.darkGray
            self.portOut[i].layer.masksToBounds = true
            self.portOut[i].setTitle("PO\(i+1)", for: UIControlState())
            self.portOut[i].setTitleColor(UIColor.white, for: UIControlState())
            self.portOut[i].layer.cornerRadius = self.portOut[i].frame.height/2
            self.portOut[i].layer.position = CGPoint(
                x: self.view.frame.width*0.6/4*(CGFloat(i)+0.5),
                y: self.view.frame.height - (self.portOut[i].frame.height/2 + CGFloat(5.0))
            )
            self.portOut[i].tag = i
            self.portOut[i].addTarget(self, action: #selector(ControlViewController.onClickPortOutButton(_:)), for: UIControlEvents.touchUpInside)
            self.portOut[i].isHidden = true
            self.view.addSubview(portOut[i]);
        }
        
        //self.comTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.comUpdate), userInfo: nil, repeats: true)
    }
    
    //
    //
    //
    func willResignActive(_ notification: Notification) {
        print("#2 ControlViewController:willResignActive() invoked.");
    }
    
    //
    //
    //
    func didEnterBackground(_ notification: Notification) {
        print("#2 ControlViewController:didEnterBackground() invoked.");
        //
        self.backtoScanViewController()
    }
    
    //
    //
    //
    func willEnterForeground(_ notification: Notification) {
        print("#2 ControlViewController:willEnterForeground() invoked.");
    }
    
    //
    //
    //
    func didBecomeActive(_ notification: Notification) {
        print("#2 ControlViewController:didBecomeActive() invoked.");
        
    }
    
    //
    //
    //
    func willTerminate(_ notification: Notification) {
        print("#2 ControlViewController:willTerminate() invoked.")
        //
    }
    
    
    // 接続先のPeripheralを設定(ViewControllerから接続時に呼ばれる)
    func setPeripheral(_ target: CBPeripheral) {
        print("#2 ControlViewController:setPeripheral() invoked.")
        self.myTargetPeriperal = target
        print(target)

        //self.title = "[" + myTargetPeriperal.name! + "]"     // タイトルを更新
        
        print(" Set Title [\(self.deviceName)] invoked.")
        self.title = "[" + self.deviceName + "]"     // タイトルを更新
        //mySettingViewController.devNameField.text = self.deviceName
    }
    
    // CentralManagerを設定(ViewControllerから接続時に呼ばれる)
    func setCentralManager(_ manager: CBCentralManager) {
        print("#2 ControlViewController:setCentralManager() invoked.")
        self.myCentralManager = manager
        print(manager)
    }
    
    // Serviceの検索(ViewControllerから接続時に呼ばれる)
    func searchService() {
        print("#2 ControlViewController:searchService() invoked.")
        self.myTargetPeriperal.delegate = self
        self.myTargetPeriperal.discoverServices(nil)
    }
    
    
    /*
    public func periphera(
        _ peripheral: CBPeripheral,
        didModifyServices error: Error?) {
        peripheral.discoverServices(<#T##serviceUUIDs: [CBUUID]?##[CBUUID]?#>)
    }
    */
    
    // didDiscoverServices
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        print("#2 ControlViewController:peripheral(didDiscoverServices) invoked.")
        
        for service in peripheral.services! {
            myServiceUuids.add(service.uuid)
            myService.add(service)
            print("P: \(peripheral.name) - Discovered service S:'\(service.uuid)'")
        }
        
        let services: NSArray = peripheral.services! as NSArray
        
        for obj in services {
            if let service = obj as? CBService {
                
                if service.uuid.isEqual(CBUUID(string: "389CAAF0-843F-4D3B-959D-C954CCE14655")) {
                    self.myTargetService = service
                }
            }
        }
        
        if self.myTargetService == nil {
            // 目的のUUIDのServiceがない場合アラート出して前画面に戻る
            let myAlert : UIAlertController = UIAlertController(
                title: "Error!",
                message: "Service[UUID:389CAAF0-843F-4D3B-959D-C954CCE14655] not found.",
                preferredStyle: .alert
            )
            let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
                print("Action OK!")
            }
            
            myAlert.addAction(myOkAction)
            present(myAlert, animated: true, completion: nil)
            
            self.backtoScanViewController()
        } else {
            // Serviceがある場合はCharacteristicをサーチする
            searchCharacteristics()
        }
    }

    
    // Characteristicをサーチする
    func searchCharacteristics() {
        print("#2 ControlViewController:searchCharacteristics() invoked.")

        self.myTargetPeriperal.delegate = self
        self.myTargetPeriperal.discoverCharacteristics(nil, for: self.myTargetService)
    }
    
    //
    //
    //
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        print("#2 ControlViewController:peripheral(didDiscoverCharacteristicsForService) invoked.")
        
        let characteristics: NSArray = service.characteristics! as NSArray
        
        for obj in characteristics {
            
            if let characteristic = obj as? CBCharacteristic {
                    
                myCharacteristicsUuids.add(characteristic.uuid)
                myCharacteristics.add(characteristic)
                
                print("\(characteristic)")
                print("properties: \(characteristic.properties.rawValue)")
                
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAF1-843F-4D3B-959D-C954CCE14655")) {
                    self.getBatteryVoltageCharacteristic = characteristic
                    print("Found! getBatteryVoltageCharacteristic:389CAAF1-843F-4D3B-959D-C954CCE14655")
                } else
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAF2-843F-4D3B-959D-C954CCE14655")) {
                    self.setMotorPWMCharacteristic = characteristic
                    print("Found! setMotorPWMCharacteristic:389CAAF2-843F-4D3B-959D-C954CCE14655")
                } else
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAF3-843F-4D3B-959D-C954CCE14655")) {
                    self.setPortOutCharacteristic = characteristic
                    print("Found! setPortOutCharacteristic:389CAAF3-843F-4D3B-959D-C954CCE14655")
                } else
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAF4-843F-4D3B-959D-C954CCE14655")) {
                    self.setServoPositionCharacteristic = characteristic
                    print("Found! setServoPositionCharacteristic:389CAAF4-843F-4D3B-959D-C954CCE14655")
                } else
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAFF-843F-4D3B-959D-C954CCE14655")) {
                    self.getFunctionsCharacteristic = characteristic
                    print("Found! getFunctionsCharacteristic:389CAAFF-843F-4D3B-959D-C954CCE14655")
                } else
                if characteristic.uuid.isEqual(CBUUID(string: "389CAAF5-843F-4D3B-959D-C954CCE14655")) {
                    self.burstCommandCharacteristic = characteristic
                    print("Found! burstCommandCharacteristic:389CAAF5-843F-4D3B-959D-C954CCE14655 !!! New Characteristic !!!")
                }
            }
        }
        
        if     (self.getBatteryVoltageCharacteristic == nil)
            || (self.setMotorPWMCharacteristic == nil)
            || (self.setPortOutCharacteristic == nil)
            || (self.setServoPositionCharacteristic == nil)
            || (self.getFunctionsCharacteristic == nil) {
            // Characterinsticがない場合アラート出して前画面に戻る
            print("lack of Characterinstics")
            
            let myAlert : UIAlertController = UIAlertController(
                title: "Error!",
                message: "Incomplete Characterinstics.",
                preferredStyle: .alert
            )
            let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
                print("Action OK!")
            }
            
            myAlert.addAction(myOkAction)
            present(myAlert, animated: true, completion: nil)
            
            self.backtoScanViewController()
        }
        
        //
        // 必要なCharcteristicが揃っていたら、セーブデータをロードする
        //
        self.loadSaveData()

        //
        // 各ファンクションの持ち数を取得する
        // この応答で各機能のValid/Invalidを決定する
        while (self.comControl != false) {
            print(">>>")
        }
        self.myTargetPeriperal.readValue(for: self.getFunctionsCharacteristic)
        self.comControl = true
        usleep(wait_time)
        self.comControl = false

        // voltageの今現在の状態を取得する
        self.getBatteryVoltage()
        self.comControl = true
        usleep(wait_time*4)
        self.comControl = false

        self.comIndex = 0
        
        //
        // MotionManager回す
        //
        self.myMotionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {(rpyData, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            guard let data = rpyData else {
                return
            }
            
            if self.strSW == true {
                self.pitchAngle = Float(data.attitude.pitch/M_PI*180.0)
                self.valueStr = self.pitchAngle/90.0
                //self.labelST.text = "\(self.valueStr)"
                self.labelHD.frame.origin.x = self.labelHDXPos + self.labelHDXStr * CGFloat(self.valueStr)
            }
        }
        )
        
        //
        // Start Timer
        //
        self.comTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                             target: self,
                                             selector: #selector(self.comUpdate),
                                             userInfo: nil,
                                             repeats: true)
        self.comTimer.fire()
    }
    
    
    
    //
    //
    //
    public func    comUpdate() {
        print("#2 ControlViewController:comUpdate(\(self.comIndex)) invoked.")
        
        if self.burstCommandCharacteristic == nil {
            self.voltageLabel.textColor = UIColor.white
            
            if (self.comIndex == 0) || (self.comIndex == 5) {
                self.updateServo(index: 0)
                self.comIndex += 1
            } else
            if (self.comIndex == 1) || (self.comIndex == 6) {
                self.updateServo(index: 1)
                self.comIndex += 1
            } else
            if (self.comIndex == 2) || (self.comIndex == 7) {
                self.updateServo(index: 2)
                self.comIndex += 1
            } else
            if (self.comIndex == 3) || (self.comIndex == 8) {
                self.updatePWM()
                self.comIndex += 1
            } else
            if self.comIndex == 4 {
                self.updatePortOut()
                self.comIndex += 1
            } else {
                self.getBatteryVoltage()
                self.comIndex = 0
            }
        } else {
            self.voltageLabel.textColor = UIColor.yellow
            if self.comIndex == 0 {
                self.getBatteryVoltage()
                self.comIndex += 1
            } else {
                self.updateBurst()
                self.comIndex += 1
                if self.comIndex >= 10 {
                    self.comIndex = 0
                }
            }
        }
    }
    
    
    //
    // タッチを感知した際に呼ばれるメソッド.
    //
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("#2 ControlViewController:touchesBegan() invoked.")
        
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: self.view)
        

        if (location.x < self.view.frame.width/10*6) {
            // 左６割ステアリング操作
            if self.strSW == false {
                
                var diff: CGFloat = location.x - self.view.frame.width/3
                diff = diff / self.labelHDXStr * 100
                if (diff > 100) {
                    diff = 100
                }
                if (diff < -100) {
                    diff = -100
                }
                
                self.valueStr = Float(diff/100.0)
                //self.labelST.text = "\(self.valueStr)"
                self.labelHD.frame.origin.x = self.labelHDXPos + self.labelHDXStr * CGFloat(self.valueStr)
            }
            
        } else {
            // 右４割　スロットル操作
            var diff: CGFloat = -(location.y -
                (self.view.frame.height + self.navigationController!.navigationBar.frame.size.height)/2)
            diff = diff / self.labelVDYStr * 100
            if (diff > 100) {
                diff = 100
            }
            if (diff < -100) {
                diff = -100
            }
            
            self.valueAxel = Float(diff/100.0)
            //self.labelAX.text = "\(self.valueAxel)"
            self.labelVD.frame.origin.y = self.labelVDYPos - self.labelVDYStr * CGFloat(self.valueAxel)
            //self.updatePWM()
        }
    }
    
    //
    // ドラッグを感知した際に呼ばれるメソッド.
    // (ドラッグ中何度も呼ばれる)
    //
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("#2 ControlViewController:touchesMoved() invoked.")
        
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: self.view)
        
        if (location.x < self.view.frame.width/10*6) {
            // 左６割ステアリング操作
            if self.strSW == false {
                
                var diff: CGFloat = location.x - self.view.frame.width/3
                diff = diff / self.labelHDXStr * 100
                if (diff > 100) {
                    diff = 100
                }
                if (diff < -100) {
                    diff = -100
                }
                
                self.valueStr = Float(diff/100.0)
                //self.labelST.text = "\(self.valueStr)"
                self.labelHD.frame.origin.x = self.labelHDXPos + self.labelHDXStr * CGFloat(self.valueStr)
            }
            
        } else {
            // 右４割　スロットル操作
            var diff: CGFloat = -(location.y - (self.view.frame.height + self.navigationController!.navigationBar.frame.size.height)/2)
            diff = diff / self.labelVDYStr * 100
            if (diff > 100) {
                diff = 100
            }
            if (diff < -100) {
                diff = -100
            }
        
            self.valueAxel = Float(diff/100.0)
            //self.labelAX.text = "\(self.valueAxel)"
            self.labelVD.frame.origin.y = self.labelVDYPos - self.labelVDYStr * CGFloat(self.valueAxel)
            //self.updatePWM()
        }
    }
    
    //
    // 指が離れたことを感知した際に呼ばれるメソッド.
    //
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("#2 ControlViewController:touchesEnded() invoked.")
        
        // タッチイベントを取得.
        let aTouch: UITouch = touches.first!
        
        // 移動した先の座標を取得.
        let location = aTouch.location(in: self.view)
        
        if (location.x < self.view.frame.width/10*6) {
            // 左６割ステアリング操作
            if self.strSW == false {
                
                self.valueStr = 0.0
                //self.labelST.text = "\(self.valueStr)"
                self.labelHD.frame.origin.x = self.labelHDXPos
            }
            
        } else {
            // 右４割　スロットル操作
            self.valueAxel = 0.0
            //self.labelAX.text = "\(self.valueAxel)"
            self.labelVD.frame.origin.y = self.labelVDYPos
            //self.updatePWM()
        }
    }
    
    
    //
    // Get Battery Voltage
    //
    func getBatteryVoltage()
    {
        // voltageの今現在の状態を取得する
        //while (self.comControl != false) {
        //    print(">>>")
        //}
        self.myTargetPeriperal.readValue(for: self.getBatteryVoltageCharacteristic)
        //self.comControl = true
        //usleep(wait_time)
        //self.comControl = false
    }
    
    
    //
    // Port Out Control
    //
    func updatePortOut() {
        print("#2 ControlViewController:updatePortOut() invoked.")
        
        var value : CUnsignedChar = 0x00
        if self.portOut[0].backgroundColor == UIColor.white {
            value += 0x01
        }
        if self.portOut[1].backgroundColor == UIColor.white {
            value += 0x02
        }
        if self.portOut[2].backgroundColor == UIColor.white {
            value += 0x04
        }
        if self.portOut[3].backgroundColor == UIColor.white {
            value += 0x08
        }
        
        let data : Data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        print("\(self.setPortOutCharacteristic) \(data)")
        
        if self.setPortOutCharacteristic != nil {
            //while (self.comControl != false) {
            //    print(">>>")
            //}
            self.myTargetPeriperal.writeValue(
                data,
                for: self.setPortOutCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            //self.comControl = true
            //usleep(wait_time)
            //self.comControl = false
        } else {
            print("setPortOutCharacteristic = nil!!")
        }
    }
    
    
    //
    // PWM Control
    //
    func updatePWM() {
        print("#2 ControlViewController:updatePWM() invoked.")

        var pwmValue : [CUnsignedChar] = [0x00, 0x80]
        pwmValue[0] = CUnsignedChar(1)
        
        var tmp: Float = 128.0
        
        if self.motorFlip == false {
            tmp = tmp + 127 * self.valueAxel
        } else {
            tmp = tmp - 127 * self.valueAxel
        }
        if (tmp > 255) {
            tmp = 255
        }
        if (tmp < 0  ) {
            tmp = 0
        }
        pwmValue[1] = CUnsignedChar(tmp)
        
        if (pwmValue[1] < 0x90) && (0x70 < pwmValue[1]) {
            pwmValue[1] = 0x80
        }
        
        let pwmData : Data = Data(buffer: UnsafeBufferPointer(start: &pwmValue, count: 2))
        print("\(self.setMotorPWMCharacteristic) \(pwmData)")
        
        if self.setMotorPWMCharacteristic != nil {
            //while (self.comControl != false) {
            //    print(">>>")
            //}
            self.myTargetPeriperal.writeValue(
                pwmData,
                for: self.setMotorPWMCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            //self.comControl = true
            //usleep(wait_time)
            //self.comControl = false
        } else {
            print("setMotorPWMCharacteristic = nil!!")
        }
    }

    
    //
    // Servo Control
    //
    func updateServo() {
        print("#2 ControlViewController:updateServo() invoked.")
        //if self.myMotionManager.isDeviceMotionActive {
            if (self.servoValid[0] == true) {
                self.updateServo(index: 0)
            }
            if (self.servoValid[1] == true) {
                self.updateServo(index: 1)
            }
            if (self.servoValid[2] == true) {
                self.updateServo(index: 2)
            }
        //} else {
        //    print(">>>self.myMotionManager.isDeviceMotionActive is inactive")
        //}
    }
    
    //
    //
    //
    func updateServo(index: Int) {
        print("#2 ControlViewController:updateServo(\(index)) invoked.")
        
        if self.servoValid[index] == false {
            return
        }
        
        var servoValue : [CUnsignedChar] = [0x00, 0x80]
        servoValue[0] = CUnsignedChar(index)
        
        var tmp: Float = 128
            
        if index == 0 {
           tmp = tmp + self.servoTrim
            
            if self.servoFlip == false {
                tmp = tmp + 127 * self.valueStr * self.servoSwing
            } else {
                tmp = tmp - 127 * self.valueStr * self.servoSwing
            }
        } else {
            tmp = tmp + self.subservoTrim
            
            if self.servoFlip == false {
                if index == 2 {
                    tmp = tmp + 127 * self.valueStr * self.servoSwing
                } else {
                    tmp = tmp - 127 * self.valueStr * self.servoSwing
                }
            } else {
                if index == 2 {
                    tmp = tmp - 127 * self.valueStr * self.servoSwing
                } else {
                    tmp = tmp + 127 * self.valueStr * self.servoSwing
                }
            }
        }
        
        if tmp < 0 {
            tmp = 0
        } else if tmp > 0xFF {
            tmp = 0xFF
        }
        servoValue[1] = CUnsignedChar(tmp)
        
        let servoData : Data = Data(buffer: UnsafeBufferPointer(start: &servoValue, count: 2))
        print("\(self.setServoPositionCharacteristic) \(servoData)")
        
        if self.setServoPositionCharacteristic != nil {
            //while (self.comControl != false) {
            //    print(">>>")
            //}
            self.myTargetPeriperal.writeValue(
                servoData,
                for: self.setServoPositionCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            //self.comControl = true
            //usleep(wait_time)
            //self.comControl = false
        } else {
            print("setServoPositionCharacteristic = nil!!")
        }
    }
    
    
    
    //
    //  BurstCommand Update
    //
    func updateBurst() {
        print("#2 ControlViewController:updateBurst() invoked.")
        
        //                                  PWM0  PWM1  LEDs  Srv0  Srv1  Srv2  Srv3
        var burstValue : [CUnsignedChar] = [0x80, 0x80, 0x00, 0x80, 0x80, 0x80, 0x80]
        
        // PWM1
        var tmp: Float = 128.0
        if self.motorFlip == false {
            tmp = tmp + 127 * self.valueAxel
        } else {
            tmp = tmp - 127 * self.valueAxel
        }
        if (tmp > 255) {
            tmp = 255
        }
        if (tmp < 0  ) {
            tmp = 0
        }
        burstValue[1] = CUnsignedChar(tmp)
        
        if (burstValue[1] < 0x90) && (0x70 < burstValue[1]) {
            burstValue[1] = 0x80
        }
        
        // LEDs
        var value : CUnsignedChar = 0x00
        if self.portOut[0].backgroundColor == UIColor.white {
            value += 0x01
        }
        if self.portOut[1].backgroundColor == UIColor.white {
            value += 0x02
        }
        if self.portOut[2].backgroundColor == UIColor.white {
            value += 0x04
        }
        if self.portOut[3].backgroundColor == UIColor.white {
            value += 0x08
        }
        burstValue[2] = CUnsignedChar(value)
        
        // Servo 0
        tmp = 128.0 + self.servoTrim
        if self.servoFlip == false {
            tmp = tmp + 127 * self.valueStr * self.servoSwing
        } else {
            tmp = tmp - 127 * self.valueStr * self.servoSwing
        }
        if tmp < 0 {
            tmp = 0
        } else if tmp > 0xFF {
            tmp = 0xFF
        }
        burstValue[3] = CUnsignedChar(tmp)
       
        // Servo 1
        tmp = 128.0 + self.subservoTrim
        if self.servoFlip == false {
            tmp = tmp - 127 * self.valueStr * self.servoSwing
        } else {
            tmp = tmp + 127 * self.valueStr * self.servoSwing
        }
        if tmp < 0 {
            tmp = 0
        } else if tmp > 0xFF {
            tmp = 0xFF
        }
        burstValue[4] = CUnsignedChar(tmp)
        
        // Servo 2
        tmp = 128.0 + self.subservoTrim
        if self.servoFlip == false {
            tmp = tmp + 127 * self.valueStr * self.servoSwing
        } else {
            tmp = tmp - 127 * self.valueStr * self.servoSwing
        }
        if tmp < 0 {
            tmp = 0
        } else if tmp > 0xFF {
            tmp = 0xFF
        }
        burstValue[5] = CUnsignedChar(tmp)
        
        let burstData : Data = Data(buffer: UnsafeBufferPointer(start: &burstValue, count: 7))
        print("\(self.burstCommandCharacteristic) \(burstData)")

        if self.burstCommandCharacteristic != nil {
            self.myTargetPeriperal.writeValue(
                burstData,
                for: self.burstCommandCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
        } else {
            print("burstCommandCharacteristic = nil!!")
        }
       
        
        
    }
    
    
    
    //
    // Bar Button Event
    // move to Edit View
    func onClickMyBarButton(_ sender: UIBarButtonItem){
        print("#2 ControlViewController:onClickMyBarButton() invoked.")
        //mySettingViewController.devNameField.text = self.deviceName
        //mySettingViewController.updateView()
        self.navigationController?.pushViewController(self.mySettingViewController, animated: true)
    }

    //
    // Port Out Button toggle
    //
    func onClickPortOutButton(_ sender: UIButton){
        print("#2 ControlViewController:onClickPortOutButton() invoked.")
        
        if self.portOut[sender.tag].backgroundColor == UIColor.darkGray {
            self.portOut[sender.tag].backgroundColor = UIColor.white
            self.portOut[sender.tag].setTitleColor(UIColor.darkGray, for: UIControlState())
            //self.portOut[sender.tag].setTitle("Off", forState: UIControlState.Normal)
        } else {
            self.portOut[sender.tag].backgroundColor = UIColor.darkGray
            self.portOut[sender.tag].setTitleColor(UIColor.white, for: UIControlState())
            //self.portOut[sender.tag].setTitle("On", forState: UIControlState.Normal)
        }
        
        //updatePortOut()
    }
    
    //
    // ペリフェラルからの値の通知
    //
    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        //println("#2 ControlViewController:peripheral(didUpdateValueForCharacteristic) invoked")
        
        // Functions値の通知
        if characteristic.uuid.isEqual(self.getFunctionsCharacteristic.uuid) {
            
            print("getFunctionsCharacteristic: \(self.getFunctionsCharacteristic)")
            
            var data : [CUnsignedChar] = [0,0]
            (characteristic.value! as NSData).getBytes(&data, length: 2)
            print(">>> Function 0 (Dummy): \(data[0]>>4)")        // dummy
            print(">>> Function 1 (Motor): \(data[0]&0x0f)")      // motorPWM
            print(">>> Function 2 (PortO): \(data[1]>>4)")        // portOut
            print(">>> Function 3 (Servo): \(data[1]&0x0f)")      // servoControl

            // PortOuytの初期化
            for i in 0..<4 {
                self.portOut[i].backgroundColor = UIColor.darkGray
                self.portOut[i].setTitleColor(UIColor.white, for: UIControlState())
            }
            if (data[1]&0x10) != 0x00 {
                self.portValid[0] = true
                self.portOut[0].isHidden = false
            } else {
                self.portValid[0] = false
            }
            if (data[1]&0x20) != 0x00 {
                self.portValid[1] = true
                self.portOut[1].isHidden = false
            } else {
                self.portValid[1] = false
            }
            if (data[1]&0x40) != 0x00 {
                self.portValid[2] = true
                self.portOut[2].isHidden = false
            } else {
                self.portValid[2] = false
            }
            if (data[1]&0x80) != 0x00 {
                self.portValid[3] = true
                self.portOut[3].isHidden = false
            } else {
                self.portValid[3] = false
            }
            self.updatePortOut()
            
            // PWMの初期化
            self.valueAxel = 0
            self.updatePWM()
            
            if (data[0]&0x01) != 0x00 {
                self.motorValid[0] = true
            } else {
                self.motorValid[0] = false
            }
            if (data[0]&0x02) != 0x00 {
                self.motorValid[1] = true
            } else {
                self.motorValid[1] = false
            }
            
            // Servoの初期化
            self.valueStr = 0
            self.updateServo()
            
            if (data[1]&0x01) != 0x00 {
                self.servoValid[0] = true
            } else {
                self.servoValid[0] = false
            }
            if (data[1]&0x02) != 0x00 {
                self.servoValid[1] = true
            } else {
                self.servoValid[1] = false
            }
            if (data[1]&0x04) != 0x00 {
                self.servoValid[2] = true
            } else {
                self.servoValid[2] = false
            }
            if (data[1]&0x08) != 0x00 {
                self.servoValid[3] = true
            } else {
                self.servoValid[3] = false
            }
        }
        
        // Voltageの値の通知
        if characteristic.uuid.isEqual(self.getBatteryVoltageCharacteristic.uuid) {
            
            //println("getBatteryVoltageCharacteristic: \(self.getBatteryVoltageCharacteristic)")
            
            var data : [CUnsignedChar] = [0,0]
            (characteristic.value! as NSData).getBytes(&data, length: 2)
            var vol : Int32 = 0
            vol += Int32(data[1])
            vol *= 256
            vol += Int32(data[0])
            //println("Voltage : \(vol) \(data)")
            voltageLabel.text = "Pow:" + (NSString(format:"%0.2f", Float(vol)/1000.0) as String) + "[V]"
        }
    }

    
    //
    // ペリフェラルからのStatusの通知
    //
    @nonobjc func peripheral(
        _ peripheral: CBPeripheral!,
        didUpdateNotificationStatusForCharacteristic characteristic: CBCharacteristic!,
        error: Error!
    ) {
        print("#2 ControlViewController:peripheral(didUpdateNotificationStatusForCharacteristic) invoked.")
        
        
    }
    
    
    //
    // ペリフェラルからの設定へのリプライ
    //
    public func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
        ) {
            print("#2 ControlViewController:peripheral(didWriteValueForCharacteristic) invoked.")
            
            
    }
    
    
    //
    //
    //
    func cleanup_condition() {
        print("#2 ControlViewController:cleanup_condition() invoked.")
        
        self.comTimer.invalidate()
        
        //print(" self.myMotionManager.isDeviceMotionActive = \( self.myMotionManager.isDeviceMotionActive )")
        self.myMotionManager.stopDeviceMotionUpdates()
        //print(" self.myMotionManager.isDeviceMotionActive = \( self.myMotionManager.isDeviceMotionActive )")
        //
        //
        //
        //self.savedData()
        
        //println(">>>SecondViewController:cleanup_condition(3) invoked")
        voltageLabel.text = "Pow: -.--[V]"
        
        for i in 0..<4 {
            self.portOut[i].backgroundColor = UIColor.darkGray
            self.portOut[i].setTitleColor(UIColor.white, for: UIControlState())
            self.portOut[i].isHidden = true
        }
        self.updatePortOut()
        
        self.valueAxel = 0
        self.updatePWM()
        
        self.valueStr = 0
        self.updateServo()
        
        //println(">>>SecondViewController:cleanup_condition(10) invoked")
        if (self.myCentralManager != nil) {
            print(">>>myCentralManager.cancelPeripheralConnection")
            self.myCentralManager.cancelPeripheralConnection(self.myTargetPeriperal)
        }
        
        //println(">>>SecondViewController:cleanup_condition(12) invoked")
        self.myCentralManager = nil
        self.myTargetPeriperal = nil
        self.myTargetService = nil
        
        //println(">>>SecondViewController:cleanup_condition(13) invoked")
        self.getBatteryVoltageCharacteristic = nil
        self.getFunctionsCharacteristic = nil
        self.setMotorPWMCharacteristic = nil
        self.setServoPositionCharacteristic = nil

        print(">>>cleanup_condition() done")
    }
    
    //
    //
    //
    func backtoScanViewController() {
        print("#2 ControlViewController:backtoScanViewController() invoked.")
        // Viewの移動する.
        
        
        //self.cleanup_condition()
        print(">>>navigationController.pushViewController(\(self.myScanViewController))")
        
        //self.navigationController?.pushViewController(self.myScanViewController, animated: true)
        //_ = self.navigationController?.popViewController(animated: true)
        self.savedData()
        _ = self.navigationController?.popToRootViewController(animated: true)
        //exit(0)
    }

    
    
    //
    //
    //
    //override func didMoveToParentViewController(parent: UIViewController?) {
    override public func willMove(toParentViewController parent: UIViewController?) {
        print("#2 ControlViewController:willMoveToParentViewController(\(parent)) invoked.")
        
        if parent == nil {
            cleanup_condition()
        }
    }
    
    
    func setScanViewController(_ vctrl: ScanViewController) {
        print("#2 ControlViewController:setScanViewController() invoked.")
        
        self.myScanViewController = vctrl
    }
    
    func setSettingViewController(_ vctrl: SettingViewController) {
        print("#2 ControlViewController:setSettingViewController() invoked.")
        
        self.mySettingViewController = vctrl
    }
    
    //
    //
    //
    func loadSaveData() {
        print("#2 ControlViewController:loadSaveData() invoked.")
        
        print("<<<<<<<<<< Load Data for \(self.myTargetPeriperal.name) >>>>>>>>>>")
        let ud: UserDefaults = UserDefaults.standard
 
        //let devName: AnyObject! = ud.objectForKey("\(self.myTargetPeriperal.name)_DeviceName")
        //print("\(self.myTargetPeriperal.name)_DeviceName : \(devName)")
        //
        //if devName != nil {
        //    self.deviceName = devName as! String
        //}
        
        let strS : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_StrSW") as AnyObject!
        print("\(self.myTargetPeriperal.name)_StrSW : \(strS)")
        
        if strS != nil {
            self.strSW = strS as! Bool
            
            if self.strSW == true {
                self.labelHD.layer.borderColor = UIColor.lightGray.cgColor
            }
            
        } else {
            self.strSW = true
        }
        
        let motorF : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_MotorFlip") as AnyObject!
        print("\(self.myTargetPeriperal.name)_MotorFlip : \(motorF)")
        
        if motorF != nil {
            self.motorFlip = motorF as! Bool
        } else {
            self.motorFlip = false
        }
        
        let servoF : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_ServoFlip") as AnyObject!
        print("\(self.myTargetPeriperal.name)_ServoFlip : \(servoF)")
        
        if servoF != nil {
            self.servoFlip = servoF as! Bool
        } else {
            self.servoFlip = false
        }
        
        let servoS : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_ServoSwing") as AnyObject!
        print("\(self.myTargetPeriperal.name)_ServoSwing : \(servoS)")
        
        if servoS != nil {
            self.servoSwing = servoS as! Float
        } else {
            self.servoSwing = 1.0
        }
        
        let servoT : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_ServoTrim") as AnyObject!
        print("\(self.myTargetPeriperal.name)_ServoTrim : \(servoT)")
        
        if servoT != nil {
            self.servoTrim = servoT as! Float
        } else {
            self.servoTrim = 0
        }
        
        let subServoT : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_SubservoTrim") as AnyObject!
        print("\(self.myTargetPeriperal.name)_SubservoTrim : \(subServoT)")
        
        if subServoT != nil {
            self.subservoTrim = subServoT as! Float
        } else {
            self.subservoTrim = 0
        }
    }
    
    func savedData() {
        print("#2 ControlViewController:savedData() invoked.")
        
        if self.myTargetPeriperal != nil {
            print("<<<<<<<<<< Save Data for \(myTargetPeriperal.name) >>>>>>>>>>")
            let ud: UserDefaults = UserDefaults.standard

            print("\(self.myTargetPeriperal.name)_DeviceName : \(self.deviceName)")
            ud.set(self.deviceName, forKey: "\(self.myTargetPeriperal.name)_DeviceName")
            
            print("\(self.myTargetPeriperal.name)_StrSW : \(self.strSW)")
            ud.set(self.strSW, forKey: "\(self.myTargetPeriperal.name)_StrSW")
        
            print("\(self.myTargetPeriperal.name)_MotorFlip : \(self.motorFlip)")
            ud.set(self.motorFlip, forKey: "\(self.myTargetPeriperal.name)_MotorFlip")
        
            print("\(self.myTargetPeriperal.name)_ServoFlip : \(self.servoFlip)")
            ud.set(self.servoFlip, forKey: "\(self.myTargetPeriperal.name)_ServoFlip")
        
            print("\(self.myTargetPeriperal.name)_ServoSwing : \(self.servoSwing)")
            ud.set(self.servoSwing, forKey: "\(self.myTargetPeriperal.name)_ServoSwing")
        
            print("\(self.myTargetPeriperal.name)_ServoTrim : \(self.servoTrim)")
            ud.set(self.servoTrim, forKey: "\(self.myTargetPeriperal.name)_ServoTrim")
        
            print("\(self.myTargetPeriperal.name)_SubservoTrim : \(self.subservoTrim)")
            ud.set(self.subservoTrim, forKey: "\(self.myTargetPeriperal.name)_SubservoTrim")
        }
    }
    
}

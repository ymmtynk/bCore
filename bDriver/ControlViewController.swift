//
//  SecondViewController.swift
//  BLEController

//
//  Created by TakashiYamamoto on 2015/05/24.
//  Copyright (c) 2015年 TakashiYamamoto. All rights reserved.
//

import UIKit
import CoreBluetooth

class ControlViewController: UIViewController, CBPeripheralDelegate{

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
    
    var voltageLabel: UILabel!
    
    var motorPWMNum: Int = 0
    var portOutNum: Int = 0
    var servoControllNum: Int = 0
    
    var motorPWM = [UISlider](repeating: UISlider(), count: 2)
    var portOut  = [UIButton](repeating: UIButton(), count: 4)
    var servoControl = [UISlider](repeating: UISlider(), count: 4)
    var motorLabel = [UILabel](repeating: UILabel(), count: 2)
    var servoLabel = [UILabel](repeating: UILabel(), count: 4)
    
    var servoValid = [Bool](repeating: Bool(false), count: 4)
    var motorValid = [Bool](repeating: Bool(false), count: 4)
    var portValid  = [Bool](repeating: Bool(false), count: 4)
   
    var servoTrim = [Float](repeating: Float(0), count: 4)          // rec
    var servoFlip = [Bool](repeating: Bool(false), count: 4)         // rec
    var servoSync = [Bool](repeating: Bool(false), count: 4)         // rec
    var servoEnable = [Bool](repeating: Bool(true), count: 4)        // rec

    var motorFlip = [Bool](repeating: Bool(false), count: 4)         // rec
    var motorEnable = [Bool](repeating: Bool(true), count: 4)        // rec

    var portEnable = [Bool](repeating: Bool(false), count: 4)        // rec
    
    var deviceName: String = "tmp"                                      // rec

    var myTimer2: Timer!
    var myCounter: Int32 = 0
    
    let wait_time: CUnsignedInt = 25000         // BLEのコマンドウェイト　25msec
    let timer_interval: Double = 0.5            // データ問い合わせ周期　0.5秒間隔
    
    var comControl: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("#2 ControlViewController:viewDidLoad() invoked.");
        
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willResignActive(_:)),    name: NSNotification.Name(rawValue: "applicationWillResignActive"),    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.didEnterBackground(_:)),  name: NSNotification.Name(rawValue: "applicationDidEnterBackground"),  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willEnterForeground(_:)), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.didBecomeActive(_:)),     name: NSNotification.Name(rawValue: "applicationDidBecomeActive"),     object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControlViewController.willTerminate(_:)),       name: NSNotification.Name(rawValue: "applicationWillTerminate"),       object: nil)
        
        self.view.backgroundColor = UIColor.lightGray
        
        let statusBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        //
        //
        //
        //self.loadSaveData()
        
        // Bar Button に Editのボタンをつける
        let myBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(ControlViewController.onClickMyBarButton(_:)))
        self.navigationItem.setRightBarButton(myBarButton, animated: true)
        
        // 電圧表示部
        self.voltageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/6.0*4.0, height: self.view.frame.height*0.1))
        self.voltageLabel.textColor = UIColor.white
        self.voltageLabel.textAlignment = NSTextAlignment.center
        self.voltageLabel.text = "Pow: -.--[V]"
        self.voltageLabel.layer.position = CGPoint(x: self.view.frame.width/2, y: voltageLabel.frame.height/2+statusBarHeight)
        self.view.addSubview(self.voltageLabel);

        // Port Out
        for i in 0..<4 {
            self.portOut[i] = UIButton(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width/9, height: (self.view.frame.height-statusBarHeight)/10))
            self.portOut[i].backgroundColor = UIColor.gray
            self.portOut[i].layer.masksToBounds = true
            self.portOut[i].setTitle("PO\(i+1)", for: UIControlState())
            self.portOut[i].setTitleColor(UIColor.white, for: UIControlState())
            self.portOut[i].layer.cornerRadius = self.portOut[i].frame.height/2
            self.portOut[i].layer.position = CGPoint(
                x: self.view.frame.width/12*CGFloat(i*2+3),
                y: self.view.frame.height - (self.portOut[i].frame.height/2 + CGFloat(5.0))
            )
            self.portOut[i].tag = i
            self.portOut[i].addTarget(self, action: #selector(ControlViewController.onClickPortOutButton(_:)), for: UIControlEvents.touchUpInside)
            self.portOut[i].isHidden = true
            self.view.addSubview(portOut[i]);
        }

        let rotate90deg: CGFloat = CGFloat(-90.0 * M_PI / 180.0)
        
        // Motor PWM Control
        for i in 0..<2 {
            self.motorPWM[i] = UISlider(frame: CGRect(x: 0, y: 0, width: (self.view.frame.height-statusBarHeight)*0.8, height: self.view.bounds.width/10))
            self.motorPWM[i].transform = CGAffineTransform(rotationAngle: rotate90deg)
            self.motorPWM[i].layer.position = CGPoint(
                 x: self.view.frame.width/12*CGFloat(i*10+1),
                y: (self.view.frame.height-statusBarHeight)/2+statusBarHeight
            )
            self.motorPWM[i].backgroundColor = UIColor.clear
            self.motorPWM[i].layer.cornerRadius = self.motorPWM[i].frame.width/2
            self.motorPWM[i].layer.shadowOpacity = 0.5
            self.motorPWM[i].layer.masksToBounds = true
            self.motorPWM[i].minimumValue = 0x00
            self.motorPWM[i].maximumValue = 0xff
            self.motorPWM[i].value = 0x80
            self.motorPWM[i].maximumTrackTintColor = UIColor.red
            self.motorPWM[i].minimumTrackTintColor = UIColor.red
            self.motorPWM[i].tag = i
            self.motorPWM[i].addTarget(self, action: #selector(ControlViewController.onChangeValueMotorPWMSlider(_:)), for: UIControlEvents.valueChanged)
            self.motorPWM[i].addTarget(self, action: #selector(ControlViewController.onTouchUpInsideMotorPWMSlider(_:)), for: UIControlEvents.touchUpInside)
            self.motorPWM[i].isHidden = true
            self.view.addSubview(self.motorPWM[i])
            
            self.motorLabel[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            self.motorLabel[i].text = "Mot\(i+1)"
            self.motorLabel[i].textColor = UIColor.darkGray
            self.motorLabel[i].textAlignment = NSTextAlignment.center
            self.motorLabel[i].layer.position = CGPoint(
                x: self.motorPWM[i].layer.position.x,
                y: self.motorPWM[i].layer.position.y + self.motorPWM[i].frame.height/2 + self.motorLabel[i].frame.height/2
            )
            self.motorLabel[i].isHidden = true
            self.view.addSubview(self.motorLabel[i])
        }

        // Servo Position
        for i in 0..<4 {
            self.servoControl[i] = UISlider(frame: CGRect(x: 0, y: 0, width: (self.view.frame.height-statusBarHeight)*0.6, height: self.view.bounds.width/10))
            self.servoControl[i].transform = CGAffineTransform(rotationAngle: rotate90deg)
            self.servoControl[i].layer.position = CGPoint(x: self.view.frame.width/12*CGFloat(i*2+3), y: (self.view.frame.height-statusBarHeight)*0.45+statusBarHeight)
            self.servoControl[i].backgroundColor = UIColor.clear
            self.servoControl[i].layer.cornerRadius = self.servoControl[i].frame.width/2
            self.servoControl[i].layer.shadowOpacity = 0.5
            self.servoControl[i].layer.masksToBounds = true
            self.servoControl[i].minimumValue = 0x00
            self.servoControl[i].maximumValue = 0xff
            self.servoControl[i].value = 0x80
            self.servoControl[i].maximumTrackTintColor = UIColor.blue
            self.servoControl[i].minimumTrackTintColor = UIColor.blue
            self.servoControl[i].tag = i
            self.servoControl[i].addTarget(self, action: #selector(ControlViewController.onChangeValueServoControlSlider(_:)), for: UIControlEvents.valueChanged)
            self.servoControl[i].isHidden = true
            self.view.addSubview(self.servoControl[i])
            
            self.servoLabel[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            self.servoLabel[i].text = "Srv\(i+1)"
            self.servoLabel[i].textColor = UIColor.darkGray
            self.servoLabel[i].textAlignment = NSTextAlignment.center
            self.servoLabel[i].layer.position = CGPoint(
                x: self.servoControl[i].layer.position.x,
                y: self.servoControl[i].layer.position.y + self.servoControl[i].frame.height/2 + self.servoLabel[i].frame.height/2
            )
            self.servoLabel[i].isHidden = true
            self.view.addSubview(self.servoLabel[i])
        }
    }
    
    //
    //
    //
    func willResignActive(_ notification: Notification) {
        print("#2 ViewController:willResignActive() invoked.");
    }
    
    //
    //
    //
    func didEnterBackground(_ notification: Notification) {
        print("#2 ViewController:didEnterBackground() invoked.");
        //
        self.backtoScanViewController()
    }
    
    //
    //
    //
    func willEnterForeground(_ notification: Notification) {
        print("#2 ViewController:willEnterForeground() invoked.");
    }
    
    //
    //
    //
    func didBecomeActive(_ notification: Notification) {
        print("#2 ViewController:didBecomeActive() invoked.");
        
    }
    
    //
    //
    //
    func willTerminate(_ notification: Notification) {
        print("#2 ViewController:willTerminate() invoked.")
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
    
    
    // didDiscoverServices
    func peripheral(
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
    func peripheral(
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
        while (self.comControl != false) {
            print(">>>")
        }
        self.myTargetPeriperal.readValue(for: self.getBatteryVoltageCharacteristic)
        self.comControl = true
        usleep(wait_time)
        self.comControl = false

        // タイマで回す
        self.myTimer2 = Timer.scheduledTimer(timeInterval: timer_interval, target: self, selector: #selector(ControlViewController.onTimer2Update(_:)), userInfo: nil, repeats: true)
    }
    
    
    //
    // Port Out Control
    //
    func updatePortOut() {
        print("#2 ControlViewController:updatePortOut() invoked.")
        
        var value : CUnsignedChar = 0x00
        if self.portOut[0].backgroundColor == UIColor.red {
            value += 0x01
        }
        if self.portOut[1].backgroundColor == UIColor.red {
            value += 0x02
        }
        if self.portOut[2].backgroundColor == UIColor.red {
            value += 0x04
        }
        if self.portOut[3].backgroundColor == UIColor.red {
            value += 0x08
        }
        
        let data : Data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        print("\(self.setPortOutCharacteristic) \(data)")
        
        if self.setPortOutCharacteristic != nil {
            while (self.comControl != false) {
                print(">>>")
            }
            self.myTargetPeriperal.writeValue(
                data,
                for: self.setPortOutCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            self.comControl = true
            usleep(wait_time)
            self.comControl = false
        } else {
            print("setPortOutCharacteristic = nil!!")
        }
    }
    
    
    //
    // PWM Control
    //
    func updatePWM(_ index: Int) {
        print("#2 ControlViewController:updatePWM(\(index)) invoked.")

        var pwmValue : [CUnsignedChar] = [0x00, 0x80]
        pwmValue[0] = CUnsignedChar(index)
        if self.motorFlip[index] == false {
            pwmValue[1] = CUnsignedChar(self.motorPWM[index].value)
        } else {
            pwmValue[1] = CUnsignedChar(0xff - self.motorPWM[index].value)
        }
        
        if (pwmValue[1] < 0x90) && (0x70 < pwmValue[1]) {
            pwmValue[1] = 0x80
        }
        
        let pwmData : Data = Data(buffer: UnsafeBufferPointer(start: &pwmValue, count: 2))
        print("\(self.setMotorPWMCharacteristic) \(pwmData)")
        
        if self.setMotorPWMCharacteristic != nil {
            while (self.comControl != false) {
                print(">>>")
            }
            self.myTargetPeriperal.writeValue(
                pwmData,
                for: self.setMotorPWMCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            self.comControl = true
            usleep(wait_time)
            self.comControl = false
        } else {
            print("setMotorPWMCharacteristic = nil!!")
        }
    }

    
    //
    // Servo Control
    //
    func updateServo(_ index: Int) {
        print("#2 ControlViewController:updateServo(\(index)) invoked.")
        
        if (index == 0) {
            updateServo(0, indexValue: 0)
            
            if (self.servoSync[1] == true) {
                updateServo(1, indexValue: 0)
            }
            if (self.servoSync[2] == true) {
                updateServo(2, indexValue: 0)
            }
            if (self.servoSync[3] == true) {
                updateServo(3, indexValue: 0)
            }
        } else {
            if (self.servoSync[index] == true) {
                updateServo(index, indexValue: 0)
            } else {
                updateServo(index, indexValue: index)
            }
        }
    }
    
    func updateServo(_ indexOut: Int, indexValue: Int) {
        print("#2 ControlViewController:updateServo(\(indexOut), \(indexValue)) invoked.")
        
        var tmp : Int = 0
        if self.servoFlip[indexOut] == false {
            tmp = Int(self.servoControl[indexValue].value + self.servoTrim[indexOut])
        } else {
            tmp = Int((0xff - self.servoControl[indexValue].value) + self.servoTrim[indexOut])
        }
        if tmp < 0 {
            tmp = 0
        } else if tmp > 0xFF {
            tmp = 0xff
        }
        var servoValue : [CUnsignedChar] = [0x00, 0x80]
        servoValue[0] = CUnsignedChar(indexOut)
        servoValue[1] = CUnsignedChar(tmp)
        
//        let servoData : Data = Data(bytes: UnsafePointer<UInt8>(&servoValue), count: 2)
        let servoData : Data = Data(buffer: UnsafeBufferPointer(start: &servoValue, count: 2))
        print("\(self.setServoPositionCharacteristic) \(servoData)")
        
        if self.setServoPositionCharacteristic != nil {
            while (self.comControl != false) {
                print(">>>")
            }
            self.myTargetPeriperal.writeValue(
                servoData,
                for: self.setServoPositionCharacteristic,
                type: CBCharacteristicWriteType.withoutResponse
            )
            self.comControl = true
            usleep(wait_time)
            self.comControl = false
        } else {
            print("setServoPositionCharacteristic = nil!!")
        }
    }
    
    
    //
    // Bar Button Event
    // move to Edit View
    func onClickMyBarButton(_ sender: UIBarButtonItem){
        print("#2 ControlViewController:onClickMyBarButton() invoked.")
        //mySettingViewController.devNameField.text = self.deviceName
        mySettingViewController.updateView()
        self.navigationController?.pushViewController(self.mySettingViewController, animated: true)
    }

    //
    // Port Out Button toggle
    //
    func onClickPortOutButton(_ sender: UIButton){
        print("#2 ControlViewController:onClickPortOutButton() invoked.")
        
        if self.portOut[sender.tag].backgroundColor == UIColor.gray {
            self.portOut[sender.tag].backgroundColor = UIColor.red
            //self.portOut[sender.tag].setTitle("Off", forState: UIControlState.Normal)
        } else {
            self.portOut[sender.tag].backgroundColor = UIColor.gray
            //self.portOut[sender.tag].setTitle("On", forState: UIControlState.Normal)
        }
        
        updatePortOut()
    }

    //
    // PWM Control Slider
    //
    func onChangeValueMotorPWMSlider(_ sender: UISlider) {
        print("#2 ControlViewController:onChangeValueMotorPWMSlider(\(sender.tag)) invoked.")

        updatePWM(sender.tag)
    }
    
    //
    // PWM Control Slider
    // back to Center in cas eof touch up
    func onTouchUpInsideMotorPWMSlider(_ sender: UISlider) {
        print("#2 ControlViewController:onTouchUpInsideMotorPWMSlider(\(sender.tag)) invoked.")

        self.motorPWM[sender.tag].value = 0x80
        updatePWM(sender.tag)
    }
    
    // Servo Control
    func onChangeValueServoControlSlider(_ sender: UISlider) {
        print("#2 ControlViewController:onChangeValueServoControlSlider(\(sender.tag)) invoked.")

        updateServo(sender.tag)
    }
    
    // Timer処理
    // ADCの値を更新のために問い合わせる
    func onTimer2Update(_ timer: Timer) {
        //println("#2 ControlViewController:onTimer2Update() invoked.")

        myCounter += 1;
        
        while (self.comControl != false) {
            print(">>>")
        }
        self.myTargetPeriperal.readValue(for: self.getBatteryVoltageCharacteristic)
        self.comControl = true
        usleep(wait_time)
        self.comControl = false
    }
    
    
    //
    // ペリフェラルからの値の通知
    //
    func peripheral(
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
                self.portOut[i].backgroundColor = UIColor.gray
            }
            if (data[1]&0x10) != 0x00 {
                self.portValid[0] = true
                if self.portEnable[0] == true {
                    self.portOut[0].isHidden = false
                }
            } else {
                self.portValid[0] = false
            }
            if (data[1]&0x20) != 0x00 {
                self.portValid[1] = true
                if self.portEnable[1] == true {
                    self.portOut[1].isHidden = false
                }
            } else {
                self.portValid[1] = false
            }
            if (data[1]&0x40) != 0x00 {
                self.portValid[2] = true
                if self.portEnable[2] == true {
                    self.portOut[2].isHidden = false
                }
            } else {
                self.portValid[2] = false
            }
            if (data[1]&0x80) != 0x00 {
                self.portValid[3] = true
                if self.portEnable[3] == true {
                    self.portOut[3].isHidden = false
                }
            } else {
                self.portValid[3] = false
            }
            self.updatePortOut()
            
            // PWMの初期化
            for i in 0..<2 {
                self.motorPWM[i].value = 0x80
                self.updatePWM(i)
            }
            if (data[0]&0x01) != 0x00 {
                self.motorValid[0] = true
                if self.motorEnable[0] == true {
                    self.motorPWM[0].isHidden = false
                    self.motorLabel[0].isHidden = false
                }
            } else {
                self.motorValid[0] = false
            }
            if (data[0]&0x02) != 0x00 {
                self.motorValid[1] = true
                if self.motorEnable[1] == true {
                    self.motorPWM[1].isHidden = false
                    self.motorLabel[1].isHidden = false
                }
            } else {
                self.motorValid[1] = false
            }
            
            // Servoの初期化
            for i in 0..<4 {
                self.servoControl[i].value = 0x80
                self.updateServo(i, indexValue: i)
            }
            
            if (data[1]&0x01) != 0x00 {
                self.servoValid[0] = true
                if self.servoEnable[0] == true {
                    self.servoControl[0].isHidden = false
                    self.servoLabel[0].isHidden = false
                    //if (self.servoSync[0] == true) {
                    //    self.servoControl[0].enabled = false
                    //}
                }
            } else {
                self.servoValid[0] = false
            }
            if (data[1]&0x02) != 0x00 {
                self.servoValid[1] = true
                if self.servoEnable[1] == true {
                    self.servoControl[1].isHidden = false
                    self.servoLabel[1].isHidden = false
                    if (self.servoSync[1] == true) {
                        self.servoControl[1].isEnabled = false
                    }
                }
            } else {
                self.servoValid[1] = false
            }
            if (data[1]&0x04) != 0x00 {
                self.servoValid[2] = true
                if self.servoEnable[2] == true {
                    self.servoControl[2].isHidden = false
                    self.servoLabel[2].isHidden = false
                    if (self.servoSync[2] == true) {
                        self.servoControl[2].isEnabled = false
                    }
                }
            } else {
                self.servoValid[2] = false
            }
            if (data[1]&0x08) != 0x00 {
                self.servoValid[3] = true
                if self.servoEnable[3] == true {
                    self.servoControl[3].isHidden = false
                    self.servoLabel[3].isHidden = false
                    if (self.servoSync[3] == true) {
                        self.servoControl[3].isEnabled = false
                    }
                }
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
    func peripheral(
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
        
        //
        //
        //
        self.savedData()
        
        if (self.myTimer2 != nil ) {
            //println(">>>SecondViewController:cleanup_condition(1) invoked")
            self.myTimer2.invalidate()
        }
        //println(">>>SecondViewController:cleanup_condition(2) invoked")
        usleep(CUnsignedInt(timer_interval*1000000*1.5))
        
        //println(">>>SecondViewController:cleanup_condition(3) invoked")
        voltageLabel.text = "Pow: -.--[V]"
        
        for i in 0..<4 {
            self.portOut[i].backgroundColor = UIColor.gray
            //self.portOut[i].setTitle("On", forState: UIControlState.Normal)
            self.portOut[i].isHidden = true
        }
        self.updatePortOut()
        
        for i in 0..<2 {
            self.motorPWM[i].value = 0x80
            self.motorPWM[i].isHidden = true
            self.motorLabel[i].isHidden = true
            self.updatePWM(i)
       }
        
        for i in 0..<4 {
            self.servoControl[i].value = 0x80
            self.servoControl[i].isHidden = true
            self.servoLabel[i].isHidden = true
            self.updateServo(i, indexValue: i)
        }
        
        //println(">>>SecondViewController:cleanup_condition(10) invoked")
        if (self.myCentralManager != nil) {
            //println(">>>SecondViewController:cleanup_condition(11) invoked")
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

        //println(">>>SecondViewController:cleanup_condition(15) invoked")
    }
    
    //
    //
    //
    func backtoScanViewController() {
        print("#2 ControlViewController:backtoViewController() invoked.")
        // Viewの移動する.
        //self.navigationController?.popToViewController(self.myScanViewController, animated: true)
        self.navigationController?.pushViewController(self.myScanViewController, animated: true)
    }

    
    
    //
    //
    //
    //override func didMoveToParentViewController(parent: UIViewController?) {
    override func willMove(toParentViewController parent: UIViewController?) {
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

        for i in 0..<4 {
            let portE: AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Port\(i)Enable") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Port\(i)Enable : \(portE)")
            
            if portE != nil {
                self.portEnable[i] = portE as! Bool
            } else {
                self.portEnable[i] = true
            }
        }
        
        for i in 0..<2 {
            let motorE : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Motor\(i)Enable") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Motor\(i)Enable : \(motorE)")
            
            if motorE != nil {
                self.motorEnable[i] = motorE as! Bool
            } else {
                self.motorEnable[i] = true
            }
        }
        
        for i in 0..<4 {
            let servoE : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Enable") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Servo\(i)Enable : \(servoE)")
            
            if servoE != nil {
                self.servoEnable[i] = servoE as! Bool
            } else {
                self.servoEnable[i] = true
            }
        }

        for i in 0..<2 {
            let motorF : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Motor\(i)Flip") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Motor\(i)Flip : \(motorF)")
            
            if motorF != nil {
                self.motorFlip[i] = motorF as! Bool
            } else {
                self.motorFlip[i] = false
            }
        }
        
        for i in 0..<4 {
            let servoF : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Flip") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Servo\(i)Flip : \(servoF)")
            
            if servoF != nil {
                self.servoFlip[i] = servoF as! Bool
            } else {
                self.servoFlip[i] = false
            }
        }
        
        for i in 0..<4 {
            let servoS : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Sync") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Servo\(i)Sync : \(servoS)")
            
            if servoS != nil {
                self.servoSync[i] = servoS as! Bool
            } else {
                self.servoSync[i] = false
            }
        }
        
        for i in 0..<4 {
            let servoT : AnyObject! = ud.object(forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Trim") as AnyObject!
            print("\(self.myTargetPeriperal.name)_Servo\(i)Trim : \(servoT)")
            
            if servoT != nil {
                self.servoTrim[i] = servoT as! Float
            } else {
                self.servoTrim[i] = 0
            }
        }
    }
    
    func savedData() {
        print("#2 ControlViewController:savedData() invoked.")
        
        print("<<<<<<<<<< Save Data for \(myTargetPeriperal.name) >>>>>>>>>>")
        let ud: UserDefaults = UserDefaults.standard

        print("\(self.myTargetPeriperal.name)_DeviceName : \(self.deviceName)")
        ud.set(self.deviceName, forKey: "\(self.myTargetPeriperal.name)_DeviceName")
        
        for i in 0..<4 {
            print("\(self.myTargetPeriperal.name)_Port\(i)Enable : \(self.portEnable[i])")
            ud.set(self.portEnable[i], forKey: "\(self.myTargetPeriperal.name)_Port\(i)Enable")
        }
        for i in 0..<2 {
            print("\(self.myTargetPeriperal.name)_Motor\(i)Enable : \(self.motorEnable[i])")
            ud.set(self.motorEnable[i], forKey: "\(self.myTargetPeriperal.name)_Motor\(i)Enable")
        }
        for i in 0..<4 {
            print("\(self.myTargetPeriperal.name)_Servo\(i)Enable : \(self.servoEnable[i])")
            ud.set(self.servoEnable[i], forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Enable")
        }

        for i in 0..<2 {
            print("\(self.myTargetPeriperal.name)_Motor\(i)Flip : \(self.motorFlip[i])")
            ud.set(self.motorFlip[i], forKey: "\(self.myTargetPeriperal.name)_Motor\(i)Flip")
        }
        for i in 0..<4 {
            print("\(self.myTargetPeriperal.name)_Servo\(i)Flip : \(self.servoFlip[i])")
            ud.set(self.servoFlip[i], forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Flip")
        }

        for i in 0..<4 {
            print("\(self.myTargetPeriperal.name)_Servo\(i)Sync : \(self.servoSync[i])")
            ud.set(self.servoSync[i], forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Sync")
        }
        
        for i in 0..<4 {
            print("\(self.myTargetPeriperal.name)_Servo\(i)Trim : \(self.servoTrim[i])")
            ud.set(self.servoTrim[i], forKey: "\(self.myTargetPeriperal.name)_Servo\(i)Trim")
        }
    }
    
}

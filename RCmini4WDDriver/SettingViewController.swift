//
//  SettingViewController.swift
//  BLEController

//
//  Created by TakashiYamamoto on 2015/07/06.
//  Copyright (c) 2015年 TakashiYamamoto. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITextFieldDelegate {

    var myScanViewController: ScanViewController!
    var myControlViewController: ControlViewController!

    var StrSW: UISwitch!
    
    var motorFlipSw: UISwitch!
    var servoFlipSw: UISwitch!
    
    var servoSwingSlider: UISlider!
    var servoTrimSlider: UISlider!
    var subservoTrimSlider: UISlider!
    
    var devNameField: UITextField = UITextField()
    
    var devNameLabel: UILabel!

    var StrLabel : UILabel!
    var motorFlipLabel : UILabel!
    var servoFlipLabel : UILabel!
    var servoSwingLabel : UILabel!
    var servoTrimLabel : UILabel!
    var subservoTrimLabel : UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("#3 SettingViewController:viewDidLoad() invoked.");
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.willResignActive(_:)),    name: NSNotification.Name(rawValue: "applicationWillResignActive"),    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.didEnterBackground(_:)),  name: NSNotification.Name(rawValue: "applicationDidEnterBackground"),  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.willEnterForeground(_:)), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.didBecomeActive(_:)),     name: NSNotification.Name(rawValue: "applicationDidBecomeActive"),     object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.willTerminate(_:)),       name: NSNotification.Name(rawValue: "applicationWillTerminate"),       object: nil)
        
        //
        self.title = "Edit"
        
        //self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor = UIColor(red: 123/255, green: 10/255, blue: 10/255, alpha: 1)
        
        let statusBarHeight = self.navigationController!.navigationBar.frame.size.height
        
        //
        self.devNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.devNameLabel.text = "Name:"
        self.devNameLabel.textColor = UIColor.white
        self.devNameLabel.textAlignment = NSTextAlignment.right
        self.devNameLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 0.5
        )
        self.view.addSubview(self.devNameLabel)
        
        //
        self.devNameField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 20)
        self.devNameField.text = "tmp"
        self.devNameField.delegate = self
        self.devNameField.borderStyle = UITextBorderStyle.roundedRect
        self.devNameField.keyboardType = UIKeyboardType.asciiCapable
        self.devNameField.returnKeyType = UIReturnKeyType.go
        self.devNameField.layer.position = CGPoint(
            x: self.devNameLabel.layer.position.x + self.devNameLabel.frame.width + self.devNameField.frame.width/2,
            y: self.devNameLabel.layer.position.y
        )
        self.view.addSubview(self.devNameField)
        
        //
        self.StrLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.StrLabel.text = "MotionStr:"
        self.StrLabel.textColor = UIColor.white
        self.StrLabel.textAlignment = NSTextAlignment.right
        self.StrLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 1.5
        )
        //self.StrLabel.isHidden = true
        self.view.addSubview(self.StrLabel)
        
        //
        self.StrSW = UISwitch()
        self.StrSW.layer.position = CGPoint(
            x: self.StrLabel.layer.position.x + self.StrLabel.frame.width + self.StrSW.frame.width/2,
            y: self.StrLabel.layer.position.y
        )
        self.StrSW.addTarget(self, action: #selector(SettingViewController.onSwitchStr(_:)), for: UIControlEvents.valueChanged)
        //self.StrSW.isHidden = true
        self.view.addSubview(StrSW);
        
        //
        self.motorFlipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.motorFlipLabel.text = "MotorFlip:"
        self.motorFlipLabel.textColor = UIColor.white
        self.motorFlipLabel.textAlignment = NSTextAlignment.right
        self.motorFlipLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 2.5
        )
        self.motorFlipLabel.isHidden = true
        self.view.addSubview(self.motorFlipLabel)
        
        //
        self.motorFlipSw = UISwitch()
        self.motorFlipSw.layer.position = CGPoint(
            x: self.motorFlipLabel.layer.position.x + self.motorFlipLabel.frame.width + self.motorFlipSw.frame.width/2,
            y: self.motorFlipLabel.layer.position.y
        )
        self.motorFlipSw.addTarget(self, action: #selector(SettingViewController.onSwitchMotorFlip(_:)), for: UIControlEvents.valueChanged)
        self.motorFlipSw.isHidden = true
        self.view.addSubview(motorFlipSw);
    
        //
        self.servoFlipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.servoFlipLabel.text = "ServoFlip:"
        self.servoFlipLabel.textColor = UIColor.white
        self.servoFlipLabel.textAlignment = NSTextAlignment.right
        self.servoFlipLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 3.5
        )
        self.servoFlipLabel.isHidden = true
        self.view.addSubview(self.servoFlipLabel)
        
        //
        self.servoFlipSw = UISwitch()
        self.servoFlipSw.layer.position = CGPoint(
            x: self.servoFlipLabel.layer.position.x + self.servoFlipLabel.frame.width + self.servoFlipSw.frame.width/2,
            y: self.servoFlipLabel.layer.position.y
        )
        self.servoFlipSw.addTarget(self, action: #selector(SettingViewController.onSwitchServoFlip(_:)), for: UIControlEvents.valueChanged)
        self.servoFlipSw.isHidden = true
        self.view.addSubview(servoFlipSw);
        
        //
        self.servoSwingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.servoSwingLabel.text = "ServoSwing:"
        self.servoSwingLabel.textColor = UIColor.white
        self.servoSwingLabel.textAlignment = NSTextAlignment.right
        self.servoSwingLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 4.5
        )
        self.servoSwingLabel.isHidden = true
        self.view.addSubview(self.servoSwingLabel)
        
        //
        self.servoSwingSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 50))
        self.servoSwingSlider.layer.position = CGPoint(
            x: self.servoSwingLabel.layer.position.x + self.servoSwingLabel.frame.width + self.servoSwingSlider.frame.width/2,
            y: self.servoSwingLabel.layer.position.y
        )
        self.servoSwingSlider.backgroundColor = UIColor.clear
        //self.servoSwingSlider.layer.cornerRadius = self.servoSwingSlider.frame.width/2
        self.servoSwingSlider.layer.shadowOpacity = 0.5
        self.servoSwingSlider.layer.masksToBounds = true
        self.servoSwingSlider.minimumValue = 0.5
        self.servoSwingSlider.maximumValue = 2.0
        self.servoSwingSlider.value = 1.0
        self.servoSwingSlider.maximumTrackTintColor = UIColor.white
        self.servoSwingSlider.minimumTrackTintColor = UIColor.white
        self.servoSwingSlider.addTarget(self, action: #selector(SettingViewController.onChangeValueServoSwingSlider(_:)), for: UIControlEvents.valueChanged)
        self.servoSwingSlider.isHidden = true
        self.view.addSubview(self.servoSwingSlider)

        //
        self.servoTrimLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.servoTrimLabel.text = "ServoTrim:"
        self.servoTrimLabel.textColor = UIColor.white
        self.servoTrimLabel.textAlignment = NSTextAlignment.right
        self.servoTrimLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 5.5
        )
        self.servoTrimLabel.isHidden = true
        self.view.addSubview(self.servoTrimLabel)
        
        //
        self.servoTrimSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 50))
        self.servoTrimSlider.layer.position = CGPoint(
            x: self.servoTrimLabel.layer.position.x + self.servoTrimLabel.frame.width + self.servoTrimSlider.frame.width/2,
            y: self.servoTrimLabel.layer.position.y
        )
        self.servoTrimSlider.backgroundColor = UIColor.clear
        //self.servoTrimSlider.layer.cornerRadius = self.servoTrimSlider.frame.width/2
        self.servoTrimSlider.layer.shadowOpacity = 0.5
        self.servoTrimSlider.layer.masksToBounds = true
        self.servoTrimSlider.minimumValue = -30
        self.servoTrimSlider.maximumValue = 30
        self.servoTrimSlider.value = 0
        self.servoTrimSlider.maximumTrackTintColor = UIColor.white
        self.servoTrimSlider.minimumTrackTintColor = UIColor.white
        self.servoTrimSlider.addTarget(self, action: #selector(SettingViewController.onChangeValueServoTrimSlider(_:)), for: UIControlEvents.valueChanged)
        self.servoTrimSlider.isHidden = true
        self.view.addSubview(self.servoTrimSlider)
        
        //
        self.subservoTrimLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        self.subservoTrimLabel.text = "Sub-ServoTrim:"
        self.subservoTrimLabel.textColor = UIColor.white
        self.subservoTrimLabel.textAlignment = NSTextAlignment.right
        self.subservoTrimLabel.layer.position = CGPoint(
            x: self.view.frame.width/10,
            y: statusBarHeight + (self.view.frame.height - statusBarHeight)/7 * 6.5
        )
        self.subservoTrimLabel.isHidden = true
        self.view.addSubview(self.subservoTrimLabel)
        
        //
        self.subservoTrimSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 50))
        self.subservoTrimSlider.layer.position = CGPoint(
            x: self.subservoTrimLabel.layer.position.x + self.subservoTrimLabel.frame.width + self.subservoTrimSlider.frame.width/2,
            y: self.subservoTrimLabel.layer.position.y
        )
        self.subservoTrimSlider.backgroundColor = UIColor.clear
        //self.subservoTrimSlider.layer.cornerRadius = self.subservoTrimSlider.frame.width/2
        self.subservoTrimSlider.layer.shadowOpacity = 0.5
        self.subservoTrimSlider.layer.masksToBounds = true
        self.subservoTrimSlider.minimumValue = -30
        self.subservoTrimSlider.maximumValue = 30
        self.subservoTrimSlider.value = 0
        self.subservoTrimSlider.maximumTrackTintColor = UIColor.white
        self.subservoTrimSlider.minimumTrackTintColor = UIColor.white
        self.subservoTrimSlider.addTarget(self, action: #selector(SettingViewController.onChangeValueSubservoTrimSlider(_:)), for: UIControlEvents.valueChanged)
        self.subservoTrimSlider.isHidden = true
        self.view.addSubview(self.subservoTrimSlider)
        
        //
        self.updateView()
    }
    
    //
    //
    //
    func willResignActive(_ notification: Notification) {
        print("#3 SettingViewController:willResignActive() invoked.");
    }
    
    //
    //
    //
    func didEnterBackground(_ notification: Notification) {
        print("#3 SettingViewController:didEnterBackground() invoked.");
        //
        self.backtoViewController()
    }
    
    //
    //
    //
    func willEnterForeground(_ notification: Notification) {
        print("#3 SettingViewController:willEnterForeground() invoked.");
    }
    
    //
    //
    //
    func didBecomeActive(_ notification: Notification) {
        print("#3 SettingViewController:didBecomeActive() invoked.");
    }
    
    //
    //
    //
    func willTerminate(_ notification: Notification) {
        print("#3 SettingViewController:willTerminate() invoked.")
        //
    }
    
    
    //
    //
    //
    func updateView() {
        print("#3 SettingViewController:updateView() invoked.")
        //
        //
        //
        self.StrSW.isOn = self.myControlViewController.strSW
        
        if self.myControlViewController.motorValid[1] == true {
            self.motorFlipLabel.isHidden = false
            self.motorFlipSw.isHidden = false
        } else {
            self.motorFlipLabel.isHidden = true
            self.motorFlipSw.isHidden = true
        }
        self.motorFlipSw.isOn = self.myControlViewController.motorFlip
        
        if self.myControlViewController.servoValid[0] == true {
            self.servoFlipLabel.isHidden = false
            self.servoFlipSw.isHidden = false
            self.servoSwingSlider.isHidden = false
            self.servoSwingLabel.isHidden = false
            self.servoTrimSlider.isHidden = false
            self.servoTrimLabel.isHidden = false
        } else {
            self.servoFlipLabel.isHidden = true
            self.servoFlipSw.isHidden = true
            self.servoSwingSlider.isHidden = true
            self.servoTrimLabel.isHidden = true
            self.servoTrimSlider.isHidden = true
            self.servoTrimLabel.isHidden = true
        }
        self.servoFlipSw.isOn = self.myControlViewController.servoFlip
        self.servoSwingSlider.value = self.myControlViewController.servoSwing
        self.servoTrimSlider.value = self.myControlViewController.servoTrim
 
        if     (self.myControlViewController.servoValid[0] == true)
            && (self.myControlViewController.servoValid[1] == true)
            && (self.myControlViewController.servoValid[2] == true)
        {
            self.subservoTrimSlider.isHidden = false
            self.subservoTrimLabel.isHidden = false
        } else {
            self.subservoTrimSlider.isHidden = true
            self.subservoTrimLabel.isHidden = true
        }
        self.subservoTrimSlider.value = self.myControlViewController.subservoTrim

        print(" set device name [\(myControlViewController.deviceName)]")
        print(" current device name [\(self.devNameField.text)]")
        self.devNameField.text = myControlViewController.deviceName
    }
    
    
    // スイッチイベント.
    func onSwitchStr(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchStr() invoked.")
        
        if self.StrSW.isOn == false {
            self.myControlViewController.strSW = false
            
            self.myControlViewController.pitchAngle = 0
            self.myControlViewController.valueStr = 0
            //self.labelST.text = "\(self.valueStr)"
            self.myControlViewController.labelHD.frame.origin.x = self.myControlViewController.labelHDXPos
            self.myControlViewController.labelHD.layer.borderColor = UIColor.white.cgColor
        } else {
            self.myControlViewController.strSW = true
            self.myControlViewController.labelHD.layer.borderColor = UIColor.lightGray.cgColor
        }
        self.myControlViewController.updateServo()
    }
    
    func onSwitchMotorFlip(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchMotorFlip() invoked.")
        
        if self.motorFlipSw.isOn == false {
            self.myControlViewController.motorFlip = false
        } else {
            self.myControlViewController.motorFlip = true
        }
        self.myControlViewController.updatePWM()
    }
    
    func onSwitchServoFlip(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchServoFlip() invoked.")
        
        if self.servoFlipSw.isOn == false {
            self.myControlViewController.servoFlip = false
        } else {
            self.myControlViewController.servoFlip = true
        }
        self.myControlViewController.updateServo()
    }
    
    //
    func onChangeValueServoSwingSlider(_ sender: UISlider) {
        print("#3 SettingViewController:onChangeValueServoSwingSlider(\(self.servoSwingSlider.value)) invoked.")
        
        self.myControlViewController.servoSwing = self.servoSwingSlider.value
        self.myControlViewController.updateServo()
    }
    
    //
    func onChangeValueServoTrimSlider(_ sender: UISlider) {
        print("#3 SettingViewController:onChangeValueServoTrimSlider(\(self.servoTrimSlider.value)) invoked.")
        
        self.myControlViewController.servoTrim = self.servoTrimSlider.value
        self.myControlViewController.updateServo()
    }
    
    //
    func onChangeValueSubservoTrimSlider(_ sender: UISlider) {
        print("#3 SettingViewController:onChangeValueSubservoTrimSlider(\(self.subservoTrimSlider.value)) invoked.")
        
        self.myControlViewController.subservoTrim = self.subservoTrimSlider.value
        self.myControlViewController.updateServo()
    }
    
    //
    // Device Name Text Filed Update
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("#3 SettingViewController:textFieldShouldReturn(\(self.devNameField.text)) invoked.")
        
        self.devNameField.resignFirstResponder()
        
        //
        // 入力された名前を反映する
        //
        print("Set name [\(self.devNameField.text)]")
        myControlViewController.deviceName = self.devNameField.text!
        myControlViewController.title = "[" + myControlViewController.deviceName + "]"     // タイトルを更新
        
        return true
    }
    
    
    //
    //
    //
    func cleanup_condition() {
        print("#3 SettingViewController:cleanup_condition() invoked.")
        self.myControlViewController.savedData()
    }
    
    //
    //
    //
    func backtoViewController() {
        print("#3 SettingViewController:backtoViewController() invoked.")
        // Viewの移動する.
        //self.navigationController?.popToViewController(self.myScanViewController, animated: true)
        
        print(">>>navigationController.pushViewController(\(self.myScanViewController))")
        //self.navigationController?.pushViewController(self.myScanViewController, animated: true)
        //_ = self.navigationController?.popToRootViewController(animated: true)
        //_ = self.navigationController?.popToRootViewController(animated: true)
        
        //self.myControlViewController.savedData()
        //self.myControlViewController.cleanup_condition()
        //exit(0)
    }

    
    
    //
    //
    //
    override func willMove(toParentViewController parent: UIViewController?) {
        print("#3 SettingViewController:willMoveToParentViewController(\(parent)) invoked.")
        
        if parent == nil {
            cleanup_condition()
        }
    }
    
    
    func setScanViewController(_ vctrl: ScanViewController) {
        print("#3 SeettingViewController:setScanViewController() invoked.")
        
        self.myScanViewController = vctrl
    }
    
    func setControlViewController(_ vctrl: ControlViewController) {
        print("#3 SettingViewController:setControlViewController() invoked.")
        
        self.myControlViewController = vctrl
    }
    
}

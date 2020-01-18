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

    var motorEnableSw = [UISwitch](repeating: UISwitch(), count: 2)
    var portOutEnableSw  = [UISwitch](repeating: UISwitch(), count: 4)
    var servoEnableSw  = [UISwitch](repeating: UISwitch(), count: 4)
    var servoSyncSw  = [UISwitch](repeating: UISwitch(), count: 4)
    
    var motorFlipSw = [UISwitch](repeating: UISwitch(), count: 2)
    var servoFlipSw  = [UISwitch](repeating: UISwitch(), count: 4)
    
    var servoTrimSlider = [UISlider](repeating: UISlider(), count: 4)
    
    var devNameField: UITextField = UITextField()
    
    var motorLabel = [UILabel](repeating: UILabel(), count: 2)
    var portLabel  = [UILabel](repeating: UILabel(), count: 4)
    var servoLabel = [UILabel](repeating: UILabel(), count: 4)
    var devNameLabel: UILabel!
    
    var enableLabel : UILabel!
    var flipLabel : UILabel!
    var enable2Label : UILabel!
    var flip2Label : UILabel!
    var trimLabel : UILabel!
    var syncLabel : UILabel!
    
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
        
        self.view.backgroundColor = UIColor.lightGray
        
        let statusBarHeight = self.navigationController!.navigationBar.frame.size.height
        let rotate90deg: CGFloat = CGFloat(-90.0 * M_PI / 180.0)
        
        
        self.devNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.devNameLabel.text = "Name:"
        self.devNameLabel.textColor = UIColor.darkGray
        self.devNameLabel.textAlignment = NSTextAlignment.center
        self.devNameLabel.layer.position = CGPoint(
            x: self.view.frame.width/18,
            y: statusBarHeight + self.devNameLabel.frame.height/2 * 1.5
        )
        self.view.addSubview(self.devNameLabel)

        self.devNameField.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/18*6, height: 20)
        self.devNameField.text = "tmp"
        self.devNameField.delegate = self
        self.devNameField.borderStyle = UITextBorderStyle.roundedRect
        self.devNameField.keyboardType = UIKeyboardType.asciiCapable
        self.devNameField.returnKeyType = UIReturnKeyType.go
        self.devNameField.layer.position = CGPoint(
            x: self.devNameLabel.layer.position.x + self.devNameLabel.frame.width + self.devNameField.frame.width/2,
            y: self.devNameLabel.layer.position.y
            //y: self.devNameLabel.layer.position.y + self.devNameField.frame.height/2 * 1.5
        )
        self.view.addSubview(self.devNameField)
        
        for i in 0..<4 {
            self.portLabel[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            self.portLabel[i].text = "PO\(i+1)"
            self.portLabel[i].textColor = UIColor.darkGray
            self.portLabel[i].textAlignment = NSTextAlignment.center
            self.portLabel[i].layer.position = CGPoint(
                x: self.view.frame.width/18 * CGFloat(i*2+11),
                //y: statusBarHeight + self.portLabel[i].frame.height/2 * 1.5
                y: self.devNameLabel.layer.position.y + self.devNameLabel.frame.height/2 + self.portLabel[i].frame.height/2 * 1.5
            )
            self.portLabel[i].isHidden = true
            self.view.addSubview(self.portLabel[i])
            
            self.portOutEnableSw[i] = UISwitch()
            //self.portOutEnableSw[i].on = true
            self.portOutEnableSw[i].layer.position = CGPoint(
                x: self.portLabel[i].layer.position.x,
                y: self.portLabel[i].layer.position.y + self.portLabel[i].frame.height/2 + self.portOutEnableSw[i].frame.height/2 * 1.5
            )
            self.portOutEnableSw[i].tag = i
            self.portOutEnableSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchPortOutEnable(_:)), for: UIControlEvents.valueChanged)
            self.portOutEnableSw[i].isHidden = true
            self.view.addSubview(portOutEnableSw[i]);
        }
        
        for i in 0..<2 {
            self.motorLabel[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            self.motorLabel[i].text = "Mot\(i+1)"
            self.motorLabel[i].textColor = UIColor.darkGray
            self.motorLabel[i].textAlignment = NSTextAlignment.center
            self.motorLabel[i].layer.position = CGPoint(
                x: self.view.frame.width/18 * CGFloat(i*2 + 15),
                y: self.portLabel[i].frame.height/2 * 1.5 + (self.view.frame.height-statusBarHeight)/2
            )
            self.motorLabel[i].isHidden = true
            self.view.addSubview(self.motorLabel[i])
            
            self.motorEnableSw[i] = UISwitch()
            //self.motorEnableSw[i].on = true
            self.motorEnableSw[i].layer.position = CGPoint(
                x: self.motorLabel[i].layer.position.x,
                y: self.motorLabel[i].layer.position.y + self.motorLabel[i].frame.height/2 + self.motorEnableSw[i].frame.height/2 * 1.5
            )
            self.motorEnableSw[i].tag = i
            self.motorEnableSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchMotorEnable(_:)), for: UIControlEvents.valueChanged)
            self.motorEnableSw[i].isHidden = true
            self.view.addSubview(motorEnableSw[i]);
            
            self.motorFlipSw[i] = UISwitch()
            self.motorFlipSw[i].layer.position = CGPoint(
                x: self.motorLabel[i].layer.position.x,
                y: self.motorEnableSw[i].layer.position.y + self.motorEnableSw[i].frame.height/2 + self.motorFlipSw[i].frame.height/2 * 1.5
            )
            self.motorFlipSw[i].tag = i
            self.motorFlipSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchMotorFlip(_:)), for: UIControlEvents.valueChanged)
            self.motorFlipSw[i].isHidden = true
            self.view.addSubview(motorFlipSw[i]);
        }
        
        for i in 0..<4 {
            self.servoLabel[i] = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
            self.servoLabel[i].text = "Srv\(i+1)"
            self.servoLabel[i].textColor = UIColor.darkGray
            self.servoLabel[i].textAlignment = NSTextAlignment.center
            self.servoLabel[i].layer.position = CGPoint(
                x: self.view.frame.width/18 * CGFloat(i*2+3),
                //y: statusBarHeight + self.portLabel[i].frame.height/2 * 1.5
                y: self.devNameLabel.layer.position.y + self.devNameLabel.frame.height/2 + self.servoLabel[i].frame.height/2 * 1.5
            )
            self.servoLabel[i].isHidden = true
            self.view.addSubview(self.servoLabel[i])
            
            self.servoEnableSw[i] = UISwitch()
            //self.servoEnableSw[i].on = true
            self.servoEnableSw[i].layer.position = CGPoint(
                x: self.servoLabel[i].layer.position.x,
                y: self.servoLabel[i].layer.position.y + self.portLabel[i].frame.height/2 + self.servoEnableSw[i].frame.height/2 * 1.5
            )
            self.servoEnableSw[i].tag = i
            self.servoEnableSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchServoEnable(_:)), for: UIControlEvents.valueChanged)
            self.servoEnableSw[i].isHidden = true
            self.view.addSubview(servoEnableSw[i]);
            
            self.servoFlipSw[i] = UISwitch()
            self.servoFlipSw[i].layer.position = CGPoint(
                x: self.servoLabel[i].layer.position.x,
                y: self.servoEnableSw[i].layer.position.y + self.servoEnableSw[i].frame.height/2 + self.servoFlipSw[i].frame.height/2 * 1.5
            )
            self.servoFlipSw[i].tag = i
            self.servoFlipSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchServoFlip(_:)), for: UIControlEvents.valueChanged)
            self.servoFlipSw[i].isHidden = true
            self.view.addSubview(servoFlipSw[i]);

            self.servoSyncSw[i] = UISwitch()
            self.servoSyncSw[i].layer.position = CGPoint(
                x: self.servoLabel[i].layer.position.x,
                y: self.servoFlipSw[i].layer.position.y + self.servoFlipSw[i].frame.height/2 + self.servoSyncSw[i].frame.height/2 * 1.5
            )
            self.servoSyncSw[i].tag = i
            self.servoSyncSw[i].addTarget(self, action: #selector(SettingViewController.onSwitchServoSync(_:)), for: UIControlEvents.valueChanged)
            self.servoSyncSw[i].isHidden = true
            self.view.addSubview(servoSyncSw[i]);

            self.servoTrimSlider[i] = UISlider(frame: CGRect(
                x: 0, y: 0,
                width: (self.view.frame.height - (self.servoSyncSw[i].layer.position.y + self.servoSyncSw[i].frame.height/2))*0.9,
                height: self.view.bounds.width/10)
            )
            self.servoTrimSlider[i].transform = CGAffineTransform(rotationAngle: rotate90deg)
            self.servoTrimSlider[i].layer.position = CGPoint(
                x: self.servoLabel[i].layer.position.x,
                y:(self.view.frame.height - (self.servoSyncSw[i].layer.position.y + self.servoSyncSw[i].frame.height/2)) / 2
                + (self.servoSyncSw[i].layer.position.y + self.servoSyncSw[i].frame.height/2)
            )
            self.servoTrimSlider[i].backgroundColor = UIColor.clear
            self.servoTrimSlider[i].layer.cornerRadius = self.servoTrimSlider[i].frame.width/2
            self.servoTrimSlider[i].layer.shadowOpacity = 0.5
            self.servoTrimSlider[i].layer.masksToBounds = true
            self.servoTrimSlider[i].minimumValue = -20
            self.servoTrimSlider[i].maximumValue = 20
            self.servoTrimSlider[i].value = 0
            self.servoTrimSlider[i].maximumTrackTintColor = UIColor.blue
            self.servoTrimSlider[i].minimumTrackTintColor = UIColor.blue
            self.servoTrimSlider[i].tag = i
            self.servoTrimSlider[i].addTarget(self, action: #selector(SettingViewController.onChangeValueServoTrimSlider(_:)), for: UIControlEvents.valueChanged)
            self.servoTrimSlider[i].isHidden = true
            self.view.addSubview(self.servoTrimSlider[i])
        }
        
        self.enableLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.enableLabel.text = "Show:"
        self.enableLabel.textColor = UIColor.darkGray
        self.enableLabel.textAlignment = NSTextAlignment.center
        self.enableLabel.layer.position = CGPoint(
            x: self.view.frame.width/18,
            y: self.servoEnableSw[0].layer.position.y
        )
        self.view.addSubview(self.enableLabel)
        
        self.flipLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.flipLabel.text = "Flip:"
        self.flipLabel.textColor = UIColor.darkGray
        self.flipLabel.textAlignment = NSTextAlignment.center
        self.flipLabel.layer.position = CGPoint(
            x: self.view.frame.width/18,
            y: self.servoFlipSw[0].layer.position.y
        )
        self.view.addSubview(self.flipLabel)
        
        self.syncLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.syncLabel.text = "Sync:"
        self.syncLabel.textColor = UIColor.darkGray
        self.syncLabel.textAlignment = NSTextAlignment.center
        self.syncLabel.layer.position = CGPoint(
            x: self.view.frame.width/18,
            y: self.servoSyncSw[0].layer.position.y
        )
        self.view.addSubview(self.syncLabel)
        
        self.enable2Label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.enable2Label.text = "Show:"
        self.enable2Label.textColor = UIColor.darkGray
        self.enable2Label.textAlignment = NSTextAlignment.center
        self.enable2Label.layer.position = CGPoint(
            x: self.view.frame.width/18*13,
            y: self.motorEnableSw[0].layer.position.y
        )
        self.view.addSubview(self.enable2Label)
        
        self.flip2Label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.flip2Label.text = "Flip:"
        self.flip2Label.textColor = UIColor.darkGray
        self.flip2Label.textAlignment = NSTextAlignment.center
        self.flip2Label.layer.position = CGPoint(
            x: self.view.frame.width/18*13,
            y: self.motorFlipSw[0].layer.position.y
        )
        self.view.addSubview(self.flip2Label)
        
        self.trimLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.trimLabel.text = "Trim:"
        self.trimLabel.textColor = UIColor.darkGray
        self.trimLabel.textAlignment = NSTextAlignment.center
        self.trimLabel.layer.position = CGPoint(
            x: self.view.frame.width/18,
            y: self.servoTrimSlider[0].layer.position.y
        )
        self.view.addSubview(self.trimLabel)

        
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
        for i in 0..<4 {
            if self.myControlViewController.portValid[i] == true {
                self.portOutEnableSw[i].isHidden = false
                self.portLabel[i].isHidden = false
            } else {
                self.portOutEnableSw[i].isHidden = true
                self.portLabel[i].isHidden = true
            }
            self.portOutEnableSw[i].isOn = self.myControlViewController.portEnable[i]
            //self.onSwitchPortOutEnable(self.portOutEnableSw[i])
        }
        
        for i in 0..<2 {
            if self.myControlViewController.motorValid[i] == true {
                self.motorEnableSw[i].isHidden = false
                self.motorFlipSw[i].isHidden = false
                self.motorLabel[i].isHidden = false
            } else {
                self.motorEnableSw[i].isHidden = true
                self.motorFlipSw[i].isHidden = true
                self.motorLabel[i].isHidden = true
            }
            self.motorEnableSw[i].isOn = self.myControlViewController.motorEnable[i]
            //self.onSwitchMotorEnable(self.motorEnableSw[i])
            self.motorFlipSw[i].isOn = self.myControlViewController.motorFlip[i]
            //self.onSwitchMotorFlip(self.motorFlipSw[i])
        }
        
        for i in 0..<4 {
            if self.myControlViewController.servoValid[i] == true {
                self.servoEnableSw[i].isHidden = false
                self.servoFlipSw[i].isHidden = false
                if (i != 0) {
                    self.servoSyncSw[i].isHidden = false
                }
                self.servoTrimSlider[i].isHidden = false
                self.servoLabel[i].isHidden = false
            } else {
                self.servoEnableSw[i].isHidden = true
                self.servoFlipSw[i].isHidden = true
                self.servoSyncSw[i].isHidden = true
                self.servoTrimSlider[i].isHidden = true
                self.servoLabel[i].isHidden = true
            }
            self.servoEnableSw[i].isOn = self.myControlViewController.servoEnable[i]
            //self.onSwitchServoEnable(self.servoEnableSw[i])
            self.servoFlipSw[i].isOn = self.myControlViewController.servoFlip[i]
            //self.onSwitchServoFlip(self.servoFlipSw[i])
            self.servoSyncSw[i].isOn = self.myControlViewController.servoSync[i]
            //self.onSwitchServoSync(self.servoSyncSw[i])
            self.servoTrimSlider[i].value = self.myControlViewController.servoTrim[i]
            //self.onChangeValueServoTrimSlider(self.servoTrimSlider[i])
        }
        print(" set device name [\(myControlViewController.deviceName)]")
        print(" current device name [\(self.devNameField.text)]")
        self.devNameField.text = myControlViewController.deviceName
        
    }
    
    
    
    // スイッチイベント.
    func onSwitchPortOutEnable(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchPortOutEnable(\(sender.tag)) invoked.")
        
        if self.myControlViewController.portValid[sender.tag] == true {
            if self.portOutEnableSw[sender.tag].isOn == false {
                self.myControlViewController.portEnable[sender.tag] = false
                self.myControlViewController.portOut[sender.tag].isHidden = true
            } else {
                self.myControlViewController.portEnable[sender.tag] = true
                self.myControlViewController.portOut[sender.tag].isHidden = false
            }
        }
    }
    
    func onSwitchMotorEnable(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchMotorEnable(\(sender.tag)) invoked.")
        
        if self.myControlViewController.motorValid[sender.tag] == true {
            if self.motorEnableSw[sender.tag].isOn == false {
                //self.motorFlipSw[sender.tag].hidden = true
                //self.motorFlipSw[sender.tag].enabled = false
                self.myControlViewController.motorEnable[sender.tag] = false
                self.myControlViewController.motorPWM[sender.tag].isHidden = true
                self.myControlViewController.motorLabel[sender.tag].isHidden = true
            } else {
                //self.motorFlipSw[sender.tag].hidden = false
                //self.motorFlipSw[sender.tag].enabled = true
                self.myControlViewController.motorEnable[sender.tag] = true
                self.myControlViewController.motorPWM[sender.tag].isHidden = false
                self.myControlViewController.motorLabel[sender.tag].isHidden = false
            }
        }
    }
    
    func onSwitchServoEnable(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchServoEnable(\(sender.tag)) invoked.")
        
        if self.myControlViewController.servoValid[sender.tag] == true {
            if self.servoEnableSw[sender.tag].isOn == false {
                //self.servoFlipSw[sender.tag].hidden = true
                //self.servoTrimSlider[sender.tag].hidden = true
                //self.servoFlipSw[sender.tag].enabled = false
                //self.servoSyncSw[sender.tag].enabled = false
                //self.servoTrimSlider[sender.tag].enabled = false
                self.myControlViewController.servoEnable[sender.tag] = false
                self.myControlViewController.servoControl[sender.tag].isHidden = true
                self.myControlViewController.servoLabel[sender.tag].isHidden = true
            } else {
                //self.servoFlipSw[sender.tag].hidden = true
                //self.servoTrimSlider[sender.tag].hidden = true
                //self.servoFlipSw[sender.tag].enabled = true
                //self.servoSyncSw[sender.tag].enabled = true
                //self.servoTrimSlider[sender.tag].enabled = true
                self.myControlViewController.servoEnable[sender.tag] = true
                self.myControlViewController.servoControl[sender.tag].isHidden = false
                self.myControlViewController.servoLabel[sender.tag].isHidden = false
            }
        }
    }
    
    func onSwitchMotorFlip(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchMotorFlip(\(sender.tag)) invoked.")
        
        if self.motorFlipSw[sender.tag].isOn == false {
            self.myControlViewController.motorFlip[sender.tag] = false
        } else {
            self.myControlViewController.motorFlip[sender.tag] = true
        }
        self.myControlViewController.updatePWM(sender.tag)
    }
    
    func onSwitchServoFlip(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchServoFlip(\(sender.tag)) invoked.")
        
        if self.servoFlipSw[sender.tag].isOn == false {
            self.myControlViewController.servoFlip[sender.tag] = false
        } else {
            self.myControlViewController.servoFlip[sender.tag] = true
        }
        self.myControlViewController.updateServo(sender.tag)
    }
    
    
    func onSwitchServoSync(_ sender: UISwitch){
        print("#3 SettingViewController:onSwitchServoSync(\(sender.tag)) invoked.")
        
        if self.servoSyncSw[sender.tag].isOn == false {
            self.myControlViewController.servoSync[sender.tag] = false
            self.myControlViewController.servoControl[sender.tag].isEnabled = true
        } else {
            self.myControlViewController.servoSync[sender.tag] = true
            self.myControlViewController.servoControl[sender.tag].isEnabled = false
        }
        self.myControlViewController.updateServo(sender.tag)
    }
    
    //
    func onChangeValueServoTrimSlider(_ sender: UISlider) {
        print("#3 SettingViewController:onChangeValueServoTrimSlider(\(sender.tag), \(self.servoTrimSlider[sender.tag].value)) invoked.")
        
        self.myControlViewController.servoTrim[sender.tag] = self.servoTrimSlider[sender.tag].value
        self.myControlViewController.updateServo(sender.tag)
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
        
    }
    
    //
    //
    //
    func backtoViewController() {
        print("#3 SettingViewController:backtoViewController() invoked.")
        // Viewの移動する.
        //self.navigationController?.popToViewController(self.myScanViewController, animated: true)
        self.navigationController?.pushViewController(self.myScanViewController, animated: true)
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

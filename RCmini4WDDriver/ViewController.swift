//
//  ViewController.swift
//  BLEController
//
//  Created by TakashiYamamoto on 2017/01/08.
//  Copyright (c) 2017年 VagabondWorks. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate {
    
    var myControlViewController: ControlViewController!
    
    var myTableView: UITableView!
    
    var myUuids: NSMutableArray = NSMutableArray()
    var myNames: NSMutableArray = NSMutableArray()
    var myGNames: NSMutableArray = NSMutableArray()
    var myPeripheral: NSMutableArray = NSMutableArray()
    
    var myCentralManager: CBCentralManager!
    var myTargetPeripheral: CBPeripheral!
    
    let myButton: UIButton = UIButton()
    
    
    var myTimeCount : Int32 = 0       //時間計測用の変数
    var myTimer : Timer!          // Timer
    
    var myActiveIndicator : UIActivityIndicatorView!    // Indicator
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("#1 ScanViewController:viewDidLoad() invoked.");
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.willResignActive(_:)),    name: NSNotification.Name(rawValue: "applicationWillResignActive"),    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.didEnterBackground(_:)),  name: NSNotification.Name(rawValue: "applicationDidEnterBackground"),  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.willEnterForeground(_:)), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.didBecomeActive(_:)),     name: NSNotification.Name(rawValue: "applicationDidBecomeActive"),     object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.willTerminate(_:)),       name: NSNotification.Name(rawValue: "applicationWillTerminate"),       object: nil)
        
        //
        self.title = "Scan Your Car!"
        
        // TableViewの生成( status barの高さ分ずらして表示 )
        myTableView = UITableView(frame: CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.size.height,
            width: self.view.frame.width,
            height: self.view.frame.height - UIApplication.shared.statusBarFrame.size.height
        ))
        
        myTableView.backgroundColor = UIColor(red: 123/255, green: 10/255, blue: 10/255, alpha: 1)
        // Cellの登録.
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定.
        myTableView.dataSource = self
        
        // Delegateを設定.
        myTableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
        
        // スキャン開始ボタン
        myButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
        myButton.backgroundColor = UIColor.gray;
        myButton.layer.masksToBounds = true
        myButton.setTitle("Start Scan", for: UIControlState())
        myButton.setTitleColor(UIColor.white, for: UIControlState())
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height-50)
        myButton.tag = 1
        myButton.addTarget(self, action: #selector(ScanViewController.onClickMyButton(_:)), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButton);
        
        // Indicatorをこさえる
        myActiveIndicator = UIActivityIndicatorView()
        myActiveIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        myActiveIndicator.center = self.view.center
        myActiveIndicator.hidesWhenStopped = true
        myActiveIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(myActiveIndicator)
    }
    
    //
    //
    //
    func willResignActive(_ notification: Notification) {
        print("#1 ScanViewController:willResignActive() invoked.");
    }
    
    //
    //
    //
    func didEnterBackground(_ notification: Notification) {
        print("#1 ScanViewController:didEnterBackground() invoked.");
        //
        self.cleanup()
    }
    
    //
    //
    //
    func willEnterForeground(_ notification: Notification) {
        print("#1 ScanViewController:willEnterForeground() invoked.");
    }
    
    //
    //
    //
    func didBecomeActive(_ notification: Notification) {
        print("#1 ScanViewController:didBecomeActive() invoked.");
    }
    
    //
    //
    //
    func willTerminate(_ notification: Notification) {
        print("#1 ScanViewController:willTerminate() invoked.")
        //
    }
    
    
    //NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func timerUpdate(_ timer : Timer){
        //println("#1 ScanViewController:timerUpdate(\(myTimeCount)) invoked.");
        
        if myTimeCount <= 0 {
            stopDeviceScan()
        } else {
            myTimeCount -= 1
            
            switch myTimeCount%3 {
            case 0:
                myButton.setTitle("   Scanning...", for: UIControlState())
            case 1:
                myButton.setTitle("   Scanning.. ", for: UIControlState())
            case 2:
                myButton.setTitle("   Scanning.  ", for: UIControlState())
            default:
                myButton.setTitle("   Scanning   ", for: UIControlState())
            }
        }
        
    }
    
    // Scan開始
    func startDeviceScan() {
        print("#1 ScanViewController:startDeviceScan() invoked.");
        
        myButton.isEnabled = false
        myButton.backgroundColor = UIColor.red;
        
        // 0.1secごとに割り込みで１００回、１０秒
        myTimeCount = 100
        myTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ScanViewController.timerUpdate(_:)), userInfo: nil, repeats: true)
        
        myCentralManager.scanForPeripherals(withServices: nil, options: nil)
        
        if !myActiveIndicator.isAnimating {
            myActiveIndicator.startAnimating()
        }
    }
    
    // Scan停止
    func stopDeviceScan() {
        print("#1 ScanViewController:stopDeviceScan() invoked.");
        
        if myTimer != nil {
            myTimer.invalidate()
        }
        myTimeCount = 0
        
        if myActiveIndicator.isAnimating {
            myActiveIndicator.stopAnimating()
        }
        
        myCentralManager.stopScan()
        
        myButton.backgroundColor = UIColor.gray;
        myButton.setTitle("Start Scan", for: UIControlState())
        
        myButton.isEnabled = true
    }
    
    // Cleanup
    func cleanup() {
        print("#1 ScanViewController:cleanup() invoked.");
        
        if (myTimeCount != 0) {
            stopDeviceScan()
        }
        
        self.myNames.removeAllObjects()
        self.myGNames.removeAllObjects()
        self.myUuids.removeAllObjects()
        self.myPeripheral.removeAllObjects()
        
        self.myTableView.reloadData()
    }
    
    
    //ボタンイベント.
    func onClickMyButton(_ sender: UIButton){
        print("#1 ScanViewController:onClickMyButton() invoked.");
        
        // 配列をリセット.
        myNames = NSMutableArray()
        myGNames = NSMutableArray()
        myUuids = NSMutableArray()
        myPeripheral = NSMutableArray()
        myTableView.reloadData()
        
        // CoreBluetoothを初期化および始動.
        let option:NSDictionary = [CBCentralManagerOptionShowPowerAlertKey: true]
        //myCentralManager = CBCentralManager(delegate: self, queue: nil, options: option as [NSObject : AnyObject])    // before XCode6
        myCentralManager = CBCentralManager(delegate: self, queue: nil, options: option as? [String : AnyObject])       // from XCode7
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("#1 ScanViewController:centralManagerDidUpdateState() invoked.");
        
        print("CBCentralManager.state = \(central.state)");
        switch (central.state) {
        case .poweredOff:
            print("Bluetooth Power Off.")
        case .poweredOn:
            print("Bluetooth Power On.")
            // BLEデバイスの検出を開始.
            startDeviceScan()
        case .resetting:
            print("Resting.")
        case .unauthorized:
            print("Unauthorized.")
        case .unknown:
            print("Unknown.")
        case .unsupported:
            print("Unsupported.")
        }
    }
    
    // BLEデバイスが検出された際に呼び出される.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("#1 ScanViewController:centralManager(didDiscoverPeripheral) invoked.");
        
        print("pheripheral.name: \(peripheral.name)")
        print("advertisementData:\(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.UUIDString: \(peripheral.identifier.uuidString)")
        
        let name: NSString? = advertisementData["kCBAdvDataLocalName"] as? NSString
//      let connectable: Int? = advertisementData["kCBAdvDataIsConnectable"] as? Int
        let serviceuuid: NSMutableArray? = advertisementData["kCBAdvDataServiceUUIDs"] as? NSMutableArray
        var givvenName: NSString!
        
        var validdevice: Bool = false
        
        
        if name != nil {
            if serviceuuid != nil {
                let numofservice: Int = (serviceuuid?.count)!
                
                for i in (0 ..< numofservice) {
                    
                    let uuidstring: String = String(describing: serviceuuid?[i])
                    print("\(i) : \(uuidstring)")
                
                    if uuidstring == "Optional(389CAAF0-843F-4D3B-959D-C954CCE14655)" {
                        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                        validdevice = true
                    }
                }
            }

            if name!.hasPrefix("bCore_Virtual") {
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                validdevice = true
            }
        }

        
/*        if (name == nil) {
            name = "no name";
            
            print("No Name pheripheral found! ")
        } else {
            print("\(connectable) , \(name) ")
            
            
            //if ((connectable == 1) && (name!.hasPrefix("bCore_") == true)) {
            //
            //
            // ここを治す！！！！
            //
            //
            if (name!.hasPrefix("bCore_") == true) {
*/
        if validdevice {
                let ud: UserDefaults = UserDefaults.standard
                
                let devName: AnyObject! = ud.object(forKey: "\(peripheral.name)_DeviceName") as AnyObject!
                print("\(peripheral.name)_DeviceName : \(devName)")
                
                if devName != nil {
                    givvenName = devName as! NSString
                } else {
                    givvenName = name
                }
                
                // Table Viewに追加
                myNames.add(name!)
                myGNames.add(givvenName!)
                myPeripheral.add(peripheral)
                myUuids.add(peripheral.identifier.uuidString)
                
                myTableView.reloadData()
            }
//        }
    }
    
    //
    override func didReceiveMemoryWarning() {
        print("#1 ScanViewController:didReceiveMemoryWarning() invoked.");
        
        super.didReceiveMemoryWarning()
    }
    
    // Cellが選択された際に呼び出される.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("#1 ScanViewController:tableView(didSelectRowAtIndexPath) invoked.");
        
        print("Num: \(indexPath.row)")
        print("Uuid: \(myUuids[indexPath.row])")
        print("Name: \(myNames[indexPath.row])")
        print("GName: \(myGNames[indexPath.row])")
        
        self.myControlViewController.deviceName = myGNames[indexPath.row] as! String
        self.myTargetPeripheral = myPeripheral[indexPath.row] as! CBPeripheral
        
        // ペリフェラルに接続する
        myCentralManager.connect(self.myTargetPeripheral, options: nil)
    }
    
    // Cellの総数を返す.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("#1 ScanViewController:tableView(numberOfRowsInSection) invoked.");
        
        return myUuids.count
    }
    
    // Cellに値を設定する.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("#1 ScanViewController:tableView(cellForRowAtIndexPath) invoked.");
        
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier:"MyCell" )
        
        // Cellに値を設定.
        cell.textLabel!.sizeToFit()
        cell.textLabel!.textColor = UIColor.red
        cell.textLabel!.text = "\(myGNames[indexPath.row])"
        cell.textLabel!.font = UIFont.systemFont(ofSize: 20)
        
        // Cellに値を設定(下).
        cell.detailTextLabel!.text = "\(myNames[indexPath.row])"
        cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 12)
        
        return cell
    }
    
    // Peripheralに接続
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("#1 ScanViewController:centralManager(didConnectPeripheral) invoked.");
        
        print("connect")
        stopDeviceScan()
        
        self.myControlViewController.setPeripheral(peripheral)
        self.myControlViewController.setCentralManager(central)
        self.myControlViewController.searchService()
        
        self.navigationController?.pushViewController(self.myControlViewController, animated: true)
        
        // 戻ってきたときにリストが表示されないように配列をリセット.
        cleanup()
    }
    
    // Peripheralに接続失敗した際
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("#1 ScanViewController:centralManager(didFailToConnectPeripheral) invoked.");
        
        print("Fail to Connnect")
        
        let myAlert : UIAlertController = UIAlertController(
            title: "Error!",
            message: "Fail to Connect.",
            preferredStyle: .alert
        )
        let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
            print("Action OK!")
        }
        
        myAlert.addAction(myOkAction)
        present(myAlert, animated: true, completion: nil)
    }
    
    //
    //
    //
    func setControlViewController(_ svctrl: ControlViewController) {
        print("#1 ScanViewController:setSecondViewController() invoked.");
        self.myControlViewController = svctrl
    }
    
}

//
//  InitiaizeViewController.swift
//  OnStep Controller
//
//  Created by candy on 09/08/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class InitializeViewController: UIViewController {
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    var coordinatesToPass: [String] = [String]()

    @IBOutlet var segmentControl: TTSegmentedControl!
    var alignTypeInit: Int = Int()
    
    var utcString: String =  String()
    var utcStr: String = String()

    @IBOutlet weak var setDateTimeBtn: UIButton!
    @IBOutlet weak var starAlignmentBtn: UIButton!
    @IBOutlet weak var atHomeBtn: UIButton!
    @IBOutlet weak var returnHomeBtn: UIButton!
    @IBOutlet weak var parkBtn: UIButton!
    @IBOutlet weak var unParkBtn: UIButton!
    @IBOutlet weak var setParkBtn: UIButton!
    
    @IBOutlet weak var dimmerBtn: UIButton!
    @IBOutlet weak var brighterBtn: UIButton!
    
    @objc func backBtn() {
        print("tapped")
        self.navigationController?.popToRootViewController(animated: true)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        let bckBtn = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(backBtn))
        bckBtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.navigationItem.rightBarButtonItem = bckBtn
        
        navigationItem.title = "INITIALIZE/PARK"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        setupUserInterface()
        triggerConnection(cmd:":GG#", setTag: 1)
    }

    // Start Alignment
    @IBAction func startAlignAct(_ sender: UIButton) {
        // Start first star alignment.
        print("start first")
        self.readerText = ""
        
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2) // Get Latitude (for current site) // Get Longitude (for current site) // Get UTC Offset(for current site)
        
       // triggerConnection(cmd: ":A1#", setTag: 0)
       // self.performSegue(withIdentifier: "toStartAlignTableView", sender: self)
        
    }
    func doubleToInteger(data:Double)-> Int {
        let doubleToString = "\(data)"
        let stringToInteger = (doubleToString as NSString).integerValue
        return stringToInteger
    }
    
    // Mark: Set Date Time
    @IBAction func setDateTimeAct(_ sender: UIButton) {
        // Todo: Returns nil if not connected

        if let character = utcString.character(at: 0) {
            if character == "-" {
                utcStr =  "+\(utcString.dropFirst())"
            } else if character == "+" {
                utcStr =  "-\(utcString.dropFirst())"
            }
            utcStr = String(utcStr.dropLast().replacingOccurrences(of: ":", with: "."))
//            print(String(format: "%02d:%02d", utcStr.components(separatedBy: ":")[opt: 0]!, utcStr.components(separatedBy: ":")[opt: 1]!))
        }

        let hour = doubleToInteger(data: (Double(utcStr)!)) // with server
        print("hour", hour)
     //   let hour = doubleToInteger(data: (Double(+05.30)))

        let hourInSec = String(hour * 3600)
        
        let minExt = Double(utcStr)!.truncatingRemainder(dividingBy: 1)

        // Precision fix
        
        let formatterNum = NumberFormatter()
        formatterNum.numberStyle = NumberFormatter.Style.decimal
        formatterNum.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatterNum.maximumFractionDigits = 2
        
        let minutesInSec = formatterNum.string(from: NSNumber(value: minExt))!//.replacingOccurrences(of: "-", with: "")
        
        
        let min:Int = Int(((Double(minutesInSec)!/60)*100)*3600)  // Int(((minutesInSec) / 60)*100)*3600)!
        print("minutesInSec", minutesInSec, "min", min, "Int(hourInSec)! + min)", Int(hourInSec)! + min)

        
        TimeZone.ReferenceType.default = TimeZone(secondsFromGMT: Int(hourInSec)! + min)! // 2018-10-09 10:16
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.default
        formatter.dateFormat = "MM/dd/yy HH:mm:ss"
        let strDate = formatter.string(from: Date()).components(separatedBy: " ") // TODO: crash with offline
        print("strDate", strDate)
        print(NSDate() as Date)
        
        // 2018-10-09 03:00:24 +0000
        
        triggerConnection(cmd: ":SC\(strDate[opt: 0]!)#:SL\(strDate[opt: 1]!)#:GC#:GL#", setTag: 1)
         print(":SC\(strDate[opt: 0]!)#:SL\(strDate[opt: 1]!)#:GC#:GL#")
    }
    
    /// Formats the input date to Date in specific timezone

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    func setupUserInterface() {
        
        segmentControl.itemTitles = ["1 Star", "2 Star", "3 Star"]
        segmentControl.allowChangeThumbWidth = false
        segmentControl.selectedTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.selectedTextColor = UIColor.black
        segmentControl.defaultTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.defaultTextColor = UIColor.white
        segmentControl.useGradient = false
        segmentControl.useShadow = false
        segmentControl.containerBackgroundColor = .clear
        segmentControl.thumbColor = (UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0))
        
        segmentControl.selectItemAt(index: 0, animated: true)
        alignTypeInit = 1
        segmentControl.didSelectItemWith = { index, title in
            print(index + 1)
            self.alignTypeInit = index + 1
        }
        
        addBtnProperties(button: setDateTimeBtn)
        
        addBtnProperties(button: starAlignmentBtn)
        starAlignmentBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        addBtnProperties(button: atHomeBtn)
        addBtnProperties(button: returnHomeBtn)
        addBtnProperties(button: parkBtn)
        addBtnProperties(button: unParkBtn)
        addBtnProperties(button: setParkBtn)
        
        addBtnProperties(button: dimmerBtn)
        addBtnProperties(button: brighterBtn)
    }
    
    // Mark: Select a Start
    
    // At Home/Reset
    @IBAction func atHomeAct(_ sender: UIButton) {
        // :hC#
        triggerConnection(cmd: ":hC#", setTag: 0)
    }
    
    // Return Home
    @IBAction func returnHomeAct(_ sender: UIButton) {
        // :hF#
        triggerConnection(cmd: ":hF#", setTag: 0)
    }
    
    // Park
    @IBAction func parkAct(_ sender: UIButton) {
        // :hP#
        triggerConnection(cmd: ":hP#", setTag: 0)
    }
    
    // Un-Park
    @IBAction func unParkAct(_ sender: UIButton) {
        // :hR#
        triggerConnection(cmd: ":hR#", setTag: 0)
    }
    
    // Set-Park
    @IBAction func setParkAct(_ sender: UIButton) {
        // :hQ#
        triggerConnection(cmd: ":hQ#", setTag: 0)
    }
    
    // Mark: Reticule
    
    // Dimmer
    @IBAction func dimmerAct(_ sender: UIButton) {
        // :B-#
       triggerConnection(cmd: ":B-#", setTag: 0)
    }
    
    //Brighter
    @IBAction func BrighterAct(_ sender: UIButton) {
        // :B+#
        triggerConnection(cmd: ":B+#", setTag: 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? SelectStarTableViewController {
            print("Init:", alignTypeInit)
            destination.alignType = alignTypeInit
            destination.vcTitle = "FIRST STAR"
            destination.coordinates = coordinatesToPass
          //  destination.delegate = self
            
        }
    }
    
    func triggerConnection(cmd: String, setTag: Int) {
        
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            var addr = "192.168.0.1"
            var port: UInt16 = 9999
            
            // Populate data
            if addressPort.value(forKey: "addressPort") as? String == nil {
                
                addressPort.set("192.168.0.1:9999", forKey: "addressPort")
                addressPort.synchronize()  // Initialize
                
            } else {
                let addrPort = (addressPort.value(forKey: "addressPort") as? String)?.components(separatedBy: ":")
                
                addr = addrPort![opt: 0]!
                port = UInt16(addrPort![opt: 1]!)!
                print("thi")
            }

            try clientSocket.connect(toHost: addr, onPort: port, withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
    }
}

extension InitializeViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let gettext = String(data: data, encoding: .utf8)
        switch tag {
        case 0:
            print("Tag 0:", gettext!)
            readerText += "\(gettext!)"
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")
                print(index)
        case 1:
            print("Tag 1:", gettext!)
            utcString = gettext!
        case 2:
            print("Tag 2:", gettext!)
            readerText += "\(gettext!)"
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: ".").components(separatedBy: ",")
         //   print(index)

            if index.isEmpty == false && index.count == 2 {
                triggerConnection(cmd: ":A1#", setTag: 0) // start align
                coordinatesToPass = index
                self.performSegue(withIdentifier: "toStartAlignTableView", sender: self)
            }

        default:
            print("def")
        }
        clientSocket.readData(withTimeout: -1, tag: tag)
        // clientSocket.disconnect()
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        let address = "Server IP：" + "\(host)"
        print("didConnectToHost:", address)
        
        switch sock.isConnected {
        case true:
            print("Connected")
        case false:
            print("Disconnected")
        default:
            print("Default")
        }
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected Called: ", err?.localizedDescription as Any)
    }
    
}


extension String {
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[opt: indexPosition]
    }
}

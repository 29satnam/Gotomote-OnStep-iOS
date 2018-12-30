//
//  ViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 7/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CoreLocation
import MathUtil
import SwiftyJSON
import CocoaAsyncSocket
import NotificationBanner
import Crashlytics

class LandingViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopViewDelegate {
    var socketConnector: SocketDataManager!
    
    var initJSONData: JSON = JSON()
    var tableViewTitle: String = String()
    
    @IBOutlet weak var initParkBtn: UIButton!
    @IBOutlet weak var pecBtn: UIButton!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var enterCoBtn: UIButton!
    
    @IBOutlet weak var messierBtn: UIButton!
    @IBOutlet weak var ngcicBtn: UIButton!
    @IBOutlet weak var herschelBtn: UIButton!
    
    @IBOutlet var moreOptionsBtn: UIBarButtonItem!
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    var coordinatesToPass: [String] = [String]()
    
    var utcString: String =  String()
    var utcStr: String = String()
    
    // GOTOMR
    var defaultRateToPass: String = String()
    var currentRateToPass: String = String()
    var stepsPerSecToPass: String = String()
    
    //BacklashView
    var backRaTFToPass: String = String()
    var backDecTFToPass: String = String()
    
    //SetOverHead
    var horLimitToPass: String = String()
    var overHeadLimitToPass: String = String()

    override func viewDidLoad() {
     //   self.triggerConnection(cmd: ":GVD#:GVN#:GVP#:GVT#", setTag: 3) // set
      /*  Tag 3: Aug 11 2018#
        Tag 3: 1.8m#
        Tag 3: On-Step#
        Tag 3: 20:03:03# */
     //   ngcicBtn.setTitle("Bright Stars", for: UIControl.State.normal)
        setupUserInteface()
    }
    
/*    @objc func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
    */



    
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
            }
            
            try clientSocket.connect(toHost: addr, onPort: port, withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
    }

    func setupUserInteface() {
        
        //  :GVD# Get Telescope Firmware Date
        //         Returns: mmm dd yyyy#
        //  :GVN# Get Telescope Firmware Number
        //         Returns: d.dc#
        //  :GVP# Get Telescope Product Name
        //         Returns: <string>#
        //  :GVT# Get Telescope Firmware Time
        //         returns: HH:MM:SS#
        

    //    self.triggerConnection(cmd: ":SMSITE00#") // set
    //    self.triggerConnection(cmd: ":GM#") // get
        
    //    self.triggerConnection(cmd: ":W0#:GM#:Gt#:Gg#:GG#") // Select site 0 (0-3)

        

        addBtnProperties(button: initParkBtn)
        addBtnProperties(button: pecBtn)
        addBtnProperties(button: guideBtn)
        addBtnProperties(button: enterCoBtn)
        
        addBtnProperties(button: messierBtn)
        addBtnProperties(button: ngcicBtn)
        addBtnProperties(button: herschelBtn)
        
        self.view.backgroundColor = .black
        
        navigationItem.title = "GOTOMOTE"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
    }
    
    @IBAction func toGuideCenterScreen(_ sender: UIButton) {
        self.performSegue(withIdentifier: "guideCenterScreen", sender: self)
    }
    
    @IBAction func toInitializeScreen(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":GG#", setTag: 1) // Get UTC Offset
    }
    
    @IBAction func toMessierTableView(_ sender: UIButton) { // Messier
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 8)
        initJSONData = grabJSONData(resource: "Messier2")
        tableViewTitle = "MESSIER OBJECTS"
    }
    
    @IBAction func toCladwellTableView(_ sender: UIButton) { // Cladwell
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 8)
        initJSONData = grabJSONData(resource: "cladwell")
        tableViewTitle = "CLADWELL OBJECTS"
    }
    
    @IBAction func toBrightStarTableView(_ sender: UIButton) { // Stars
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 8)
        initJSONData = grabJSONData(resource: "Bright Stars")
        tableViewTitle = "BRIGHT STARS"
    }
    
    @IBAction func toPecScreen(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":GU#", setTag: 4)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func press(_ sender: Any) {
        print("tapped")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // PrepareForSegue with Socket Data Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "initialize" {
            // trigger delegate socket values
            if let destination = segue.destination as? InitializeViewController {
               // destination.delegate = self
                destination.utcString = utcString
                print("utcString", utcString)
                destination.navigationItem.hidesBackButton = true
            }
        } else if segue.identifier == "objectListingTableViewTwo" {
            // Pass MESSIER OBJECTS data to objectListingTableViewTwo
            if let destination = segue.destination as? SelectObjectTableViewControllerTwo {
                destination.vcTitle = tableViewTitle
                destination.jsonObj = initJSONData
                destination.coordinates = coordinatesToPass
                
            }
        } else if segue.identifier == "obsSite" {
            // Site selection
            if let destination = segue.destination as? OBSSiteViewController {
              //  destination.delegate = self
                destination.title = "SITE SELECTION"
            }
        } else if segue.identifier == "toPECScreen" {
            // PEC Screen
            if let destination = segue.destination as? PECViewController {
                //  destination.delegate = self
                destination.scopeStatus = readerText
            }
        } else if let destination = segue.destination as? GotoMRViewController {
          //  readerText = ""
            destination.defaultRate = defaultRateToPass
            destination.stepsPerSec = stepsPerSecToPass
            destination.currentRate = currentRateToPass
        } else if let destination = segue.destination as? BacklashViewController {
            destination.backDec = backDecTFToPass
            destination.backRa = backRaTFToPass
        } else if let destination = segue.destination as? SetOverHeadViewController {
            destination.horizonLimit = horLimitToPass
            destination.overHeadLimit = overHeadLimitToPass
        }
        //toPECScreen
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // Mark: PopViewDelegate
    func passIdentifier(_ identifier: String) {
        if identifier == "gotomax" {
            readerText = ""
            defaultRateToPass = ""
            currentRateToPass = ""
            stepsPerSecToPass = ""
             self.triggerConnection(cmd: ":GX93#:VS#:GX92#", setTag: 5)   // DefaultMaxRate // stepsPerSec // StepsPerSecond
        } else if identifier == "backlash" {
            readerText = ""
            backDecTFToPass = ""
            backRaTFToPass = ""
            self.triggerConnection(cmd: ":%BR#:%BD#", setTag: 6) // backRA // backDEC
        } else if identifier == "limits" {
            readerText = ""
            horLimitToPass = ""
            overHeadLimitToPass = ""
            self.triggerConnection(cmd: ":GhsDD#:GoDD#", setTag: 7) // hor limit and hor limit
        } else { // backlash
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    @IBAction func showTableBarButton(_ sender: UIBarButtonItem) {
        
        let viewController = UIStoryboard(name: "Main",
                                          bundle: nil).instantiateViewController(withIdentifier: "MoreOptionsTableViewController") as! MoreOptionsTableViewController
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.popover
        viewController.popoverPresentationController?.delegate = self
        viewController.popoverPresentationController?.backgroundColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        viewController.popoverPresentationController?.barButtonItem = moreOptionsBtn
        viewController.popoverPresentationController?.permittedArrowDirections = .any
        viewController.preferredContentSize = CGSize(width: 225, height: 340)
        
        // Present the popoverViewController's view on screen
        
        // Segue Delegate
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension Date {
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

extension LandingViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        switch tag {
        case 0:
          //  print("Tag 0:", getText!)
            readerText += "\(getText!)"
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")
          //  print(index)
        case 1:
          //  print("Tag 1:", getText!)
            utcString = getText!
            let banner = StatusBarNotificationBanner(title: "Fetched UTC Offset \(utcString.dropLast())", style: .success)
            banner.bannerHeight = banner.bannerHeight + 5
            banner.show()
            self.performSegue(withIdentifier: "initialize", sender: self)
        case 2:
          //  print("Tag 2:", getText!) // to messier, bright nebula...
            readerText += getText! // To Messier, Bright Nebula...
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: ".").components(separatedBy: ",")
            print("inde", index.count)
            if index.count == 3 {
                coordinatesToPass = index
                let banner = StatusBarNotificationBanner(title: "Fecthed Lat:\(index[opt: 0] ?? "??"), Long:\(index[opt: 1] ?? "??"), UTC \(index[opt: 2] ?? "??")", style: .success)
                banner.bannerHeight = banner.bannerHeight + 5
                banner.show()
                print(index) // ["+30.52", "+075.47", "+05:30"]
                self.performSegue(withIdentifier: "objectListingTableView", sender: self)
            }
        case 3:
            print("Tag 3:", getText!) // unused
        case 4:
         //   print("Tag 4:", getText!)
            let status = readerText.components(separatedBy: "#") // += "\(getText!)" // Push :GU# reply to PEC Screen
          //  print("lol", status.count)
          //  if status.count == 1 {
                readerText = getText!
                self.performSegue(withIdentifier: "toPECScreen", sender: self)
         //   }
        case 5:
            print("Tag 1:", getText!)
            readerText += "\(getText!)"
            
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")
            
            print("ind", index)
            if index.count == 3 {
                defaultRateToPass = index[opt: 0] ?? "0"
                stepsPerSecToPass = index[opt: 1] ?? "0"
                currentRateToPass = index[opt: 2] ?? "0"
                self.performSegue(withIdentifier: "gotomax", sender: self)
            }
        case 6:
            readerText += "\(getText!)"
            
            let index = readerText.dropLast().components(separatedBy: "#")
            print(index.count, readerText) // // RA // DEC
            if index.count == 2 {
                backRaTFToPass = index[opt: 0] ?? ""
                backDecTFToPass = index[opt: 1] ?? ""
                self.performSegue(withIdentifier: "backlash", sender: self)
            }
        case 7:
            readerText += "\(getText!)"
            
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: "").components(separatedBy: ",")
            print(index, readerText) // ["-10*", "80*"]
            if index.count == 2 {
                horLimitToPass = index[opt: 0] ?? ""
                overHeadLimitToPass = index[opt: 1] ?? ""
                self.performSegue(withIdentifier: "limits", sender: self)
            }
        case 8:
            readerText += getText!
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: ".").components(separatedBy: ",")
            print("inde", index.count)
            if index.count == 3 {
                coordinatesToPass = index
                let banner = StatusBarNotificationBanner(title: "Fecthed Lat:\(index[opt: 0] ?? "??"), Long:\(index[opt: 1] ?? "??"), UTC \(index[opt: 2] ?? "??")", style: .success)
                banner.bannerHeight = banner.bannerHeight + 5
                banner.show()
                print(index)
                self.performSegue(withIdentifier: "objectListingTableViewTwo", sender: self)
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
        
        if err != nil && String(err!.localizedDescription) == "Socket closed by remote peer" { // Server Closed Connection
            print("Disconnected called:", err!.localizedDescription)
        } else if err != nil && String(err!.localizedDescription) == "Read operation timed out" { // Server Returned nothing upon request
            print("Disconnected called:", err!.localizedDescription)
            let banner = StatusBarNotificationBanner(title: "Command processed and returned nothing.", style: .success)
            banner.bannerHeight = banner.bannerHeight + 5
            banner.show()
        } else if err != nil && String(err!.localizedDescription) == "Connection refused" { // wrong port or ip
            print("Disconnected called:", err!.localizedDescription)
            let banner = StatusBarNotificationBanner(title: "Unable to make connection, please check address & port.", style: .success)
            banner.bannerHeight = banner.bannerHeight + 5
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            let banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.bannerHeight = banner.bannerHeight + 5
            banner.show()
        }
    }
}

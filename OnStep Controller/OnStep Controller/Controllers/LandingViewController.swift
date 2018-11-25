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
    @IBOutlet weak var brightStarsBtn: UIButton!
    
    @IBOutlet var moreOptionsBtn: UIBarButtonItem!
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    var coordinatesToPass: [String] = [String]()
    
    var utcString: String =  String()
    var utcStr: String = String()
    
    override func viewDidLoad() {
        setupUserInteface()
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
            }
            
            try clientSocket.connect(toHost: addr, onPort: port, withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
    }

    func setupUserInteface() {
        
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
        addBtnProperties(button: brightStarsBtn)
        
        self.view.backgroundColor = .black
        
        navigationItem.title = "ONSTEP CONTROLLER"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
    }
    
    
    @IBAction func toGuideCenterScreen(_ sender: UIButton) {
        self.performSegue(withIdentifier: "guideCenterScreen", sender: self)
    }
    
    @IBAction func toInitializeScreen(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":GG#", setTag: 1) // Get UTC Offset
    }
    
    @IBAction func toMessierTableView(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2)
        initJSONData = grabJSONData(resource: "Messier")
        tableViewTitle = "MESSIER OBJECTS"
    }
    
    @IBAction func toGalaxyTableView(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2)
        initJSONData = grabJSONData(resource: "GALXY Galaxy")
        tableViewTitle = "GALAXIES"
    }
    
    @IBAction func toBrightNebulaTableView(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2)
        initJSONData = grabJSONData(resource: "BRTNB Bright Nebula")
        tableViewTitle = "BRIGHT NEBULA"
    }
    
    @IBAction func toQuasarTableView(_ sender: UIButton) {
        self.readerText = ""
        triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2)
        initJSONData = grabJSONData(resource: "QUASR Quasar")
        tableViewTitle = "Quasar"
        //self.performSegue(withIdentifier: "objectListingTableView", sender: self)
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
        } else if segue.identifier == "objectListingTableView" {
            // Pass MESSIER OBJECTS data to SelectStarTableViewController
            if let destination = segue.destination as? SelectObjectTableViewController {
                destination.title = tableViewTitle
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
        }
        
        //toPECScreen
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // Mark: PopViewDelegate
    func passIdentifier(_ identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    @IBAction func showTableBarButton(_ sender: UIBarButtonItem) {
        
        let viewController = UIStoryboard(name: "Main",
                                          bundle: nil).instantiateViewController(withIdentifier: "MoreOptionsTableViewController") as! MoreOptionsTableViewController
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.popover
        viewController.popoverPresentationController?.delegate = self
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

/*
 Set date - :SCMM/DD/YY#
 Set time (Local) - :SLHH:MM:SS#
 
 Align, one-star*4 - :A1#
 Align, two-star*4 - :A2#                  These are saved when Set park is called         Set park position - :hQ#
 Align, three-star*4 - :A3#
 Align, accept*4 - :A+#
 */

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
            banner.show()
            self.performSegue(withIdentifier: "initialize", sender: self)
        case 2:
          //  print("Tag 2:", getText!)
            readerText += getText!
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: ".").components(separatedBy: ",")
            print("inde", index.count)
            if index.count == 3 {
                coordinatesToPass = index
                let banner = StatusBarNotificationBanner(title: "Fecthed Lat:\(index[opt: 0] ?? "??"), Long:\(index[opt: 1] ?? "??"), UTC \(index[opt: 2] ?? "??")", style: .success)
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
        
        if err != nil && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription)
            let banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
            banner.remove()
        }
    }
}

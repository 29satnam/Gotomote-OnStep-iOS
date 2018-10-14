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


protocol TriggerConnectionDelegate {
    func triggerConnection(cmd: String)
}


class LandingViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopViewDelegate, TriggerConnectionDelegate {

    @IBAction func pec(_ sender: UIButton) {
     //   triggerConnection(cmd: ":Sd-23:12:12#")
        triggerConnection(cmd: ":Sa-23:12:12#")
      //  triggerConnection(cmd: ":Gd#")
        //  triggerConnection(cmd: ":Sr12:05:45#")
    }
    
    
    @IBAction func guide(_ sender: Any) {
        triggerConnection(cmd: ":#")
    }
    
    
    var socketConnector: SocketDataManager!
    
    var initJSONData: JSON = JSON()
    var tableViewTitle: String = String()
    
    @IBOutlet weak var initParkBtn: UIButton!
    @IBOutlet weak var pecBtn: UIButton!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var enterCoBtn: UIButton!
    
    @IBOutlet weak var solarSystemBtn: UIButton!
    @IBOutlet weak var messierBtn: UIButton!
    @IBOutlet weak var ngcicBtn: UIButton!
    @IBOutlet weak var herschelBtn: UIButton!
    @IBOutlet weak var brightStarsBtn: UIButton!
    @IBOutlet weak var userCatalogBtn: UIButton!
    
    @IBOutlet var moreOptionsBtn: UIBarButtonItem!
    
    var clientSocket: GCDAsyncSocket!

    
    override func viewDidLoad() {
        
        setupUserInteface()
        

    }
    
    func triggerConnection(cmd: String) {

        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try clientSocket.connect(toHost: "192.168.0.1", onPort: UInt16(9999), withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: -1, tag: 0)
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
        
        addBtnProperties(button: solarSystemBtn)
        addBtnProperties(button: messierBtn)
        addBtnProperties(button: ngcicBtn)
        addBtnProperties(button: herschelBtn)
        addBtnProperties(button: brightStarsBtn)
        addBtnProperties(button: userCatalogBtn)
        
        self.view.backgroundColor = .black
        
        navigationItem.title = "ONSTEP CONTROLLER"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
    }
    

    
    @IBAction func toMessierTableView(_ sender: UIButton) {
        
        initJSONData = grabJSONData(resource: "Messier")
        tableViewTitle = "MESSIER OBJECTS"
        self.performSegue(withIdentifier: "objectListingTableView", sender: self)
    }
    
    @IBAction func toGalaxyTableView(_ sender: UIButton) {
        initJSONData = grabJSONData(resource: "GALXY Galaxy")
        tableViewTitle = "GALAXIES"
        self.performSegue(withIdentifier: "objectListingTableView", sender: self)
    }
    
    @IBAction func toBrightNebulaTableView(_ sender: UIButton) {
        initJSONData = grabJSONData(resource: "BRTNB Bright Nebula")
        tableViewTitle = "BRIGHT NEBULA"
        self.performSegue(withIdentifier: "objectListingTableView", sender: self)
    }
    
    @IBAction func toQuasarTableView(_ sender: UIButton) {
        initJSONData = grabJSONData(resource: "QUASR Quasar")
        tableViewTitle = "Quasar"
        self.performSegue(withIdentifier: "objectListingTableView", sender: self)
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
        if segue.identifier == "tracking" {
            // trigger delegate socket values
            if let destination = segue.destination as? TrackingViewController {
              //  destination.delegate = self
            }
        } else if segue.identifier == "initialize" {
            // trigger delegate socket values
            if let destination = segue.destination as? InitializeViewController {
               // destination.delegate = self
                destination.navigationItem.hidesBackButton = true
            }
        } else if segue.identifier == "objectListingTableView" {
            // Pass MESSIER OBJECTS data to SelectStarTableViewController
            if let destination = segue.destination as? SelectObjectTableViewController {
                destination.title = tableViewTitle
                destination.jsonObj = initJSONData
            }
        } else if segue.identifier == "obsSite" {
            // Site selection
            if let destination = segue.destination as? OBSSiteViewController {
              //  destination.delegate = self
                destination.title = "SITE SELECTION"
            }
        }
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
        viewController.preferredContentSize = CGSize(width: 225, height: 357)
        
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

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected Called: ", err?.localizedDescription as Any)
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
        
        clientSocket.readData(withTimeout: -1, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let text = String(data: data, encoding: .utf8)
        print("didRead:", text!)
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
}

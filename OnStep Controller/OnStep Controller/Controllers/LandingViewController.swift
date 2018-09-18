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

protocol TriggerConnectionDelegate {
    func triggerConnection(cmd: String)
}

class LandingViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopViewDelegate, TriggerConnectionDelegate {

    var socketConnector: SocketDataManager!
    
    func triggerConnection(cmd: String) {
        socketConnector.connectWith(socket: DataSocket(ip: "192.168.0.1", port: "9999"))
        send(message: cmd)
    }
    
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
    
    override func viewDidLoad() {
        
      //  print(objects.count)
        
      
        
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
        
        // Do any additional setup after loading the view.
        socketConnector = SocketDataManager(with: self)

        resetUIWithConnection(status: false)
        
        //----------------------------------
        /*
        let soc = DataSocket(ip: "192.168.0.1", port: "9999")

        socketConnector.connectWith(socket: soc)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        send(message: ":SC\(Date().string(with: "MM/dd/yy"))#") //Set date
        send(message: ":SL\(dateFormatter.string(from: NSDate() as Date))#") //Set time (Local)
        
        send(message: ":A1#") //Set date
        */
        
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
                destination.delegate = self
            }
        } else if segue.identifier == "initialize" {
            // trigger delegate socket values
            if let destination = segue.destination as? InitializeViewController {
                destination.delegate = self
                destination.navigationItem.hidesBackButton = true
            }
        } else if segue.identifier == "objectListingTableView" {
            // Pass MESSIER OBJECTS data to SelectObjectTableViewController
            if let destination = segue.destination as? SelectObjectTableViewController {
                destination.title = tableViewTitle
                destination.jsonObj = initJSONData
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

extension LandingViewController: PresenterProtocol {
    
    func update(message: String) {
        print("Reply - ", message)
    }
    
    
    func send(message: String){
        socketConnector.send(message: message)
    }
    
    func resetUIWithConnection(status: Bool){
        if (status){
            updateStatusViewWith(status: "Connected")
        }else{
            updateStatusViewWith(status: "Disconnected")
        }
    }
    
    func updateStatusViewWith(status: String) {
        print("Status:", status)
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

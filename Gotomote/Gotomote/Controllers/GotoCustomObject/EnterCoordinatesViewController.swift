//
//  EnterCoordinatesViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/16/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CoreLocation
import MathUtil
import SwiftyJSON
import CocoaAsyncSocket
import NotificationBannerSwift

class EnterCoordinatesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var raHH: CustomTextField!
    @IBOutlet var raMM: CustomTextField!
    @IBOutlet var raSS: CustomTextField!

    @IBOutlet var decDD: CustomTextField!
    @IBOutlet var decMM: CustomTextField!
    @IBOutlet var decSS: CustomTextField!
    
    @IBOutlet var acceptBtn: UIButton!
    var utcString: String =  String()

    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    var coordinatesToPass: [String] = [String]() // Get Latitude (for current site) // Get Longitude (for current site) // Get UTC Offset(for current site)
    
    var declination: String = String()
    var rightAscension: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        raHH.delegate = self
        raMM.delegate = self
        raSS.delegate = self
        decDD.delegate = self
        decMM.delegate = self
        decSS.delegate = self
        
        addBtnProperties(button: acceptBtn)
        
        addTFProperties(tf: raHH, placeholder: "HH") // 0
        addTFProperties(tf: raMM, placeholder: "MM") // 1
        addTFProperties(tf: raSS, placeholder: "[SS]") // 2
        addTFProperties(tf: decDD, placeholder: "[-]DD") // 3
        addTFProperties(tf: decMM, placeholder: "MM") // 4
        addTFProperties(tf: decSS, placeholder: "[SS]") // 5
        
        navigationItem.title = "ENTER COORDINATES"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    // PrepareForSegue with Socket Data Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "gotoCustomObjectSyncSegue" {

            if let destination = segue.destination as? GotoCustomObjectViewController {
             //   destination.title = tableViewTitle
             //   destination.jsonObj = initJSONData
                
                destination.passedCoordinates = coordinatesToPass
                destination.passedRA = rightAscension
                destination.passedDec = declination
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var check: Bool = Bool()
        var maxLength = 2
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 || textField.tag == 1 || textField.tag == 2 || textField.tag == 4 || textField.tag == 5 {
            
            if newString.length <= maxLength {
                // return true
                if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                    check = true
                } else {
                    check = false
                }
            }
            
        } else if textField.tag == 3 {
            maxLength = 3
            if newString.length <= maxLength {
                // return true
                if CharacterSet(charactersIn: "-0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                    check = true
                } else {
                    check = false
                }
            }
        }
        
        return check
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        
        if !raHH.text!.isEmpty && !raMM.text!.isEmpty && !decDD.text!.isEmpty && !decMM.text!.isEmpty {
            if (raSS.text?.isEmpty)! {
                raSS.text = "00"
            }
            
            if (decSS.text?.isEmpty)! {
                decSS.text = "00"
            }
        }
        
        if !raHH.text!.isEmpty && !raMM.text!.isEmpty && !raSS.text!.isEmpty && !decDD.text!.isEmpty && !decMM.text!.isEmpty && !decSS.text!.isEmpty {
            
            if !(00...23).contains(Int(raHH.text!)!) || !(00...59).contains(Int(raMM.text!)!) || !(00...59).contains(Int(raSS.text!)!) || !(-90...90).contains(Int(decDD.text!)!) || !(00...59).contains(Int(decMM.text!)!) || !(00...59).contains(Int(decSS.text!)!) {
                print("show error - Not in range")
                let banner = FloatingNotificationBanner(title: "Value(s) is out of range.", style: .danger)
                banner.show()
            } else {
                if !(0...235959).contains(Int(raHH.text! + raMM.text! + raSS.text!)!) || !(-900000...900000).contains(Int(decDD.text! + decMM.text! + decSS.text!)!) {
                    print("Value(s) is out of range.")
                } else {
                    print("do stuff")
                  //  print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS))
                    
                    self.declination = String(format: "%+02d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!) // init
                    self.rightAscension = String(format: "%02d:%02d:%02d", Int(raHH.text!)!, Int(raMM.text!)!, Int(raSS.text!)!)
                    
                    // add positive sign
                    var y = (Int(raHH.text! + raMM.text! + raSS.text!)!)
                    if (y < 0) {
                     //   y! = 0 - y! // negative
                        declination = String(format: "%-03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    } else if (y == 0) {
                        declination = String(format: "%+03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    } else {
                        declination = String(format: "%+03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    }
                    
                  //  print("declination", declination, "rightAscension", rightAscension)
                    readerText = ""
                    triggerConnection(cmd: ":Gt#:Gg#:GG#", setTag: 2) // Get Latitude (for current site) // Get Longitude (for current site) // Get UTC Offset(for current site)
                }
            }
        } else {
            let banner = FloatingNotificationBanner(title: "Textfields can't be empty.", style: .danger)
            banner.show()
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
            }
            
            try clientSocket.connect(toHost: addr, onPort: port, withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
    }
    
}

extension EnterCoordinatesViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        switch tag {
        case 0:
            print("Tag 0:", getText!) // Unused
        case 1:
            print("Tag 1:", getText!)  // Unused
        case 2:
            print("Tag 2:", getText!)
            readerText += "\(getText!)"
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().replacingOccurrences(of: "*", with: ".").components(separatedBy: ",")
            //   print(index)
            if index.isEmpty == false && index.count == 2 {
                coordinatesToPass = index
                let banner = FloatingNotificationBanner(title: "RA and Dec values are accepted.", style: .success)
                banner.show()
                self.performSegue(withIdentifier: "gotoCustomObjectSyncSegue", sender: self)
              //  print("coordinatesToPass:", coordinatesToPass, "rightAscension:", rightAscension, "declination:", declination)
              //  coordinatesToPass: ["+01.55", "+179.52"] rightAscension: 01:01:00 declination: -01:01:00
           }
        case 3:
            print("Tag 3:", getText!)  // Unused
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
            let banner = FloatingNotificationBanner(title: "Command processed.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) == "Connection refused" { // wrong port or ip
            print("Disconnected called:", err!.localizedDescription)
            let banner = FloatingNotificationBanner(title: "Unable to make connection, please check address & port.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            let banner = FloatingNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
}

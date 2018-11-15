//
//  PECViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/14/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class PECViewController: UIViewController {

    @IBOutlet var playBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    @IBOutlet var clearBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var statusLbl: UILabel!
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = "PEC SETTINGS"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        addBtnProperties(button: playBtn)
        addBtnProperties(button: stopBtn)
        addBtnProperties(button: clearBtn)
        addBtnProperties(button: recordBtn)
        addBtnProperties(button: saveBtn)
        
        readerText = ""
        triggerConnection(cmd: ":GU#", setTag: 0)
        
        
        
//  :GU#   Get telescope Status
        
     //   GE - 0
        
    }
    
    //   $Q - PEC Control
    //  :$QZ+  Enable RA PEC compensation
    //         Returns: nothing
    //  :$QZ-  Disable RA PEC Compensation
    //         Returns: nothing
    //  :$QZZ  Clear the PEC data buffer
    //         Return: Nothing
    //  :$QZ/  Ready Record PEC
    //         Returns: nothing
    //  :$QZ!  Write PEC data to EEPROM
    //         Returns: nothing
    //  :$QZ?  Get PEC status
    //         Returns: S#
    //  // Status is one of "IpPrR" (I)gnore, get ready to (p)lay, (P)laying, get ready to (r)ecord, (R)ecording.  Or an optional (.) to indicate an index detect.
    
    @IBAction func playAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ+", setTag: 1)
    }
    
    @IBAction func stopAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ-", setTag: 1)
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZZ", setTag: 1)
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ/", setTag: 1)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ!", setTag: 1)
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

extension PECViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText)
        switch tag {
        case 0:
            readerText += "\(getText!)"
            
            let index = readerText
            print(index, readerText) // // RA // DEC
            
            DispatchQueue.main.async {
            //    self.backRaTF.text = index[opt: 0] ?? ""
           //     self.backDecTF.text = index[opt: 1] ?? ""
            }
            
        case 1:
            print("Tag 1:", getText!)
            
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

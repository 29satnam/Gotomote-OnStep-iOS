//
//  SetOverHeadViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/1/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBanner

class SetOverHeadViewController: UIViewController {
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()

    var horizonLimit: String = String()
    var overHeadLimit: String = String()
    
    @IBOutlet var horizonLimitBtn: CustomTextField!
    @IBOutlet var overHeadLimitBtn: CustomTextField!
    
    @IBOutlet var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: overHeadLimitBtn, placeholder: "85")
        addTFProperties(tf: horizonLimitBtn, placeholder: "30 ")
        
        navigationItem.title = "SET OVERHEAD LIMITS"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        // Do any additional setup after loading the view.
        
        horizonLimitBtn.text = horizonLimit
        overHeadLimitBtn.text = overHeadLimit
        
       // self.triggerConnection(cmd: ":GhsDD#:GoDD#", setTag: 0)
        // Get horizon limit // Get overhead limit // ["-10*", "80*"]
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

    
    @IBAction func uploadAction(_ sender: UIButton) {
        if !overHeadLimitBtn.text!.isEmpty && !horizonLimitBtn.text!.isEmpty {
            
            if !(60...90).contains(Int(overHeadLimitBtn.text!)!) || !(-30...30).contains(Int(horizonLimitBtn.text!)!) {
                print("not success")
            } else {
                print("success")
                
                // add symbol and format horizon limit
                let x = (Int(horizonLimitBtn.text!)!)
                var y: String = String()
                
                if x > 0 {
                    y = String(format: "+%02d", x) // positive
                    print("pos", Int(String(format: "+%02d", x))!)
                } else if x == 0 {
                    y = String(format: "+%02d", x) // zero
                    print("zero", Int(String(format: "+%02d", x))!)
                } else {
                    y = String(format: "%03d", x) // neg
                    print("neg", String(format: "%03d", x))
                }
                
                self.triggerConnection(cmd: ":Sh\(y)#:So\(overHeadLimitBtn.text!)#", setTag: 1)
                // Set horizon limit -/+ 30 // Set overhead limit 60 to 90
            }
        } else {
            print("Backlash RA or Backlash Dec can't be empty.")
        }
    }

}

extension SetOverHeadViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText)
        switch tag {
        case 0:
            readerText += "\(getText!)" // Unused
            
        case 1:
            print("Tag 1:", getText!) // 0, 1 for both -> check success
            
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

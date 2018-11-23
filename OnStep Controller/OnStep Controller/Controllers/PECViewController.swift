//
//  PECViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/14/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBanner

class PECViewController: UIViewController {

    @IBOutlet var playBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    @IBOutlet var clearBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var statusLbl: UILabel!
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    var scopeStatus: String = String() // Retrieved from landing page
    
    var pecStatus: String = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    //    triggerConnection(cmd: ":$QZ?", setTag: 0)

        navigationItem.title = "PEC SETTINGS"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        addBtnProperties(button: playBtn)
        addBtnProperties(button: stopBtn)
        addBtnProperties(button: clearBtn)
        addBtnProperties(button: recordBtn)
        addBtnProperties(button: saveBtn)
        
        print("pec:", scopeStatus)
        
        if scopeStatus.contains("E") == true || scopeStatus.contains("K") == true || scopeStatus.contains("k") == true { // Other mounts
            
            DispatchQueue.main.async { // GEM, FORK, FORK(ALT) mounts
                self.readerText = ""
                self.triggerConnection(cmd: ":$QZ?", setTag: 0) // Get Pec status
                self.statusLbl.text = "Available"
                let timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(PECViewController.update), userInfo: nil, repeats: true)
            }

        } else { // (A)Alt-Az mount or other statuses like 0..
            buttonTextAlpha(alpha: 0.25, activate: false)
            DispatchQueue.main.async {
                self.statusLbl.text = "Not Available"
                print("Not Available")
                // disable buttons
                let banner = StatusBarNotificationBanner(title: "Unsupported mount or err occured. :GU#=\(self.scopeStatus)", style: .danger)
                banner.show()
                
            }
            
        }
    }
    
    @objc func update() {
        print("Updating!!")
        triggerConnection(cmd: ":$QZ?", setTag: 0)
    }
    
    
    func buttonTextAlpha(alpha: CGFloat, activate: Bool) {
        DispatchQueue.main.async {
            self.playBtn.alpha = alpha
            self.stopBtn.alpha = alpha
            self.clearBtn.alpha = alpha
            self.recordBtn.alpha = alpha
            self.saveBtn.alpha = alpha
            
            self.playBtn.isUserInteractionEnabled = activate
            self.stopBtn.isUserInteractionEnabled = activate
            self.clearBtn.isUserInteractionEnabled = activate
            self.recordBtn.isUserInteractionEnabled = activate
            self.saveBtn.isUserInteractionEnabled = activate
        }
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
        triggerConnection(cmd: ":$QZ+", setTag: 0)
        print("Enable RA PEC compensation")
    }
    
    @IBAction func stopAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ-", setTag: 1)
        print("Disable RA PEC Compensation")
    }
    
    @IBAction func clearAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZZ", setTag: 1)
        print("Clear the PEC data buffer")
    }
    
    @IBAction func recordAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ/", setTag: 1)
        print("Ready Record PEC")
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        triggerConnection(cmd: ":$QZ!", setTag: 1)
        print("Write PEC data to EEPROM")
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
        switch tag {
            
        case 0: // TODO make this repeative and dynamic -- if pec is available
            readerText += "\(getText!)" // Reply for :$QZ? -- Get PEC Status
            if readerText.contains("I") == true {
                print("PEC Idle")
                DispatchQueue.main.async {
                    self.statusLbl.text = "PEC Idle"
                }
            } else if readerText.contains("p") == true {
                print("PEC Play waiting Idx")
                DispatchQueue.main.async {
                    self.statusLbl.text = "PEC Play waiting Idx"
                }
            } else if readerText.contains("P") == true {
                print("PEC Playing")
                DispatchQueue.main.async {
                    self.statusLbl.text = "PEC Playing"
                }
            } else if readerText.contains("r") == true {
                print("PEC Rec waiting Idx")
                DispatchQueue.main.async {
                    self.statusLbl.text = "PEC Rec waiting Idx"
                }
            } else if readerText.contains("R") == true {
                print("PEC Recording")
                DispatchQueue.main.async {
                    self.statusLbl.text = "PEC Recording"
                }
            } else {
                print("Unknown reply")
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
        
        if err != nil && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription)
            let banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
    
}

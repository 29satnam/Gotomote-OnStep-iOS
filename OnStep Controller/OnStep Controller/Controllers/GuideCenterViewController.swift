//
//  GuideCenterViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/6/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class GuideCenterViewController: UIViewController {

    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    
    @IBOutlet var revNSBtn: UIButton!
    @IBOutlet var revEWBtn: UIButton!
    @IBOutlet var syncBtn: UIButton!
    
    @IBOutlet var northBtn: UIButton!
    @IBOutlet var southBtn: UIButton!
    @IBOutlet var westBtn: UIButton!
    @IBOutlet var eastBtn: UIButton!
    
    @IBOutlet var speedSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func setupUserInterface() {

        addBtnProperties(button: revNSBtn)
        addBtnProperties(button: revEWBtn)
        
        addBtnProperties(button: northBtn)
        northBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: southBtn)
        southBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: westBtn)
        westBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: eastBtn)
        eastBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        speedSlider.tintColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        navigationItem.title = "GUIDE/CENTER"

    }
    
    
    // Mark: Slider - Increase Speed
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        switch Int(sender.value) {
        case 0:
            triggerConnection(cmd: ":R0#")
        case 1:
            triggerConnection(cmd: ":R1#")
        case 2:
            triggerConnection(cmd: ":R2#")
        case 3:
            triggerConnection(cmd: ":R3#")
        case 4:
            triggerConnection(cmd: ":R4#")
        case 5:
            triggerConnection(cmd: ":R5#")
        case 6:
            triggerConnection(cmd: ":R6#")
        case 7:
            triggerConnection(cmd: ":R7#")
        case 8:
            triggerConnection(cmd: ":R8#")
        case 9:
            triggerConnection(cmd: ":R9#")
        default:
            print("sero")
        }
        
    }
    
    func triggerConnection(cmd: String) {
        
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
            clientSocket.write(data!, withTimeout: -1, tag: 0)
        } catch {
        }
        
    }
    
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#")
        print("moveToNorth")
    }
    
    @objc func stopToNorth() {
        triggerConnection(cmd: ":Qn#")
        print("stopToNorth")
    }
    
    // South
    @objc func moveToSouth() {
        triggerConnection(cmd: ":Ms#")
        print("moveToSouth")
    }
    
    @objc func stopToSouth() {
        triggerConnection(cmd: ":Qs#")
        print("stopToSouth")
    }
    
    // West
    @objc func moveToWest(_ sender: UIButton) {
        triggerConnection(cmd: ":Mw#")
        print("moveToWest")
    }
    
    @objc func stopToWest() {
        triggerConnection(cmd: ":Qw#")
        print("stopToWest")
    }
    
    // East
    @objc func moveToEast() {
        triggerConnection(cmd: ":Me#")
        print("moveToEast")
    }
    
    @objc func stopToEast() {
        triggerConnection(cmd: ":Qe#")
        print("stopToEast")
    }
    
    // Stop
    @IBAction func stopScope(_ sender: Any) {
        triggerConnection(cmd: ":Q#")
        //   print("stopScope")
        //    :T+#
        //    triggerConnection(cmd: ":R9#")
        
    }
    
    
    // Mark: Reverse North-South buttons
    @IBAction func reverseNS(_ sender: UIButton) {
        self.northBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.southBtn.removeTarget(nil, action: nil, for: .allEvents)
        DispatchQueue.main.async {
            
            if self.northBtn.currentTitle == "North" {
                
                self.northBtn.setTitle("South", for: .normal)
                self.southBtn.setTitle("North", for: .normal)
                
                //south targets north
                self.southBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
                
                //north targets south
                self.northBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
                
            } else {
                self.northBtn.setTitle("North", for: .normal)
                self.southBtn.setTitle("South", for: .normal)
                
                //north targets north
                self.northBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
                
                //south targets south
                self.southBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
                
            }
        }
        
    }
    
    // Mark: Reverse East-West buttons
    @IBAction func reverseEW(_ sender: UIButton) {
        self.westBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.eastBtn.removeTarget(nil, action: nil, for: .allEvents)
        DispatchQueue.main.async {
            
            if self.westBtn.currentTitle == "West" {
                
                self.westBtn.setTitle("East", for: .normal)
                self.eastBtn.setTitle("West", for: .normal)
                
                //east targets west
                self.eastBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
                
                //west targets east
                self.westBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
                
            } else {
                self.westBtn.setTitle("West", for: .normal)
                self.eastBtn.setTitle("East", for: .normal)
                
                //west targets west
                self.westBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
                
                //east targets east
                self.eastBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
                
            }
        }
        
    }
    
    // Mark: Lock Buttons
    @IBAction func lockButtons(_ sender: UIButton) {
        
        if revEWBtn.isUserInteractionEnabled == true {
            buttonTextAlpha(alpha: 0.25, activate: false)
        } else {
            buttonTextAlpha(alpha: 1.0, activate: true)
        }
        
    }
    
    func buttonTextAlpha(alpha: CGFloat, activate: Bool) {
        DispatchQueue.main.async {
            self.revEWBtn.alpha = alpha
            self.revNSBtn.alpha = alpha
            self.syncBtn.alpha = alpha
            self.speedSlider.alpha = alpha

            self.revNSBtn.isUserInteractionEnabled = activate
            self.revEWBtn.isUserInteractionEnabled = activate
            self.syncBtn.isUserInteractionEnabled = activate
            self.speedSlider.isUserInteractionEnabled = activate
            
        }
    }
    
    
}

extension GuideCenterViewController: GCDAsyncSocketDelegate {
    
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

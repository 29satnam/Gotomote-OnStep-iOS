//
//  GuideCenterViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/6/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBanner

class GuideCenterViewController: UIViewController {

    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    
    var readerText: String = String()
    
    @IBOutlet var revNSBtn: UIButton!
    @IBOutlet var revEWBtn: UIButton!
    @IBOutlet var syncBtn: UIButton!
    
    @IBOutlet var northBtn: UIButton!
    @IBOutlet var southBtn: UIButton!
    @IBOutlet var westBtn: UIButton!
    @IBOutlet var eastBtn: UIButton!
    
    @IBOutlet var speedSlider: UISlider!
    
    @IBOutlet var NEBtn: UIButton!
    @IBOutlet var NWBtn: UIButton!
    @IBOutlet var SEBtn: UIButton!
    @IBOutlet var SWBtn: UIButton!
    
    @IBOutlet var speedLbl: UILabel!
    var flippedSN: Bool = Bool()
    var flippedEW: Bool = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        flippedSN = false
        flippedEW = false
        setupUserInterface()
        
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = 9
        speedSlider.isContinuous = true
        
        triggerConnection(cmd: ":A?#", setTag: 0)

    }
    
    func setupUserInterface() {

        addBtnProperties(button: revNSBtn)
        addBtnProperties(button: revEWBtn)
        
        addBtnProperties(button: syncBtn)
        
        addBtnProperties(button: SEBtn)
        SEBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        addBtnProperties(button: SWBtn)
        SWBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        addBtnProperties(button: NEBtn)
        NEBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)

        addBtnProperties(button: NWBtn)
        NWBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)

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
        
        self.northBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
        self.northBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
        
        self.southBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
        self.southBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
        
        self.eastBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
        self.eastBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
        
        self.westBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
        self.westBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
        
        
        self.NEBtn.addTarget(self, action: #selector(self.moveToNE), for: UIControl.Event.touchDown)
        self.NEBtn.addTarget(self, action: #selector(self.stopToNE), for: UIControl.Event.touchUpInside)
        
        self.SEBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
        self.SEBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)
        
        self.NWBtn.addTarget(self, action: #selector(self.moveToNW), for: UIControl.Event.touchDown)
        self.NWBtn.addTarget(self, action: #selector(self.stopToNW), for: UIControl.Event.touchUpInside)
        
        self.SWBtn.addTarget(self, action: #selector(self.moveToSW), for: UIControl.Event.touchDown)
        self.SWBtn.addTarget(self, action: #selector(self.stopToSW), for: UIControl.Event.touchUpInside)

    }
    
    
    @IBAction func syncAction(_ sender: UIButton) {
        triggerConnection(cmd: ":CM#", setTag: 0)
    }
    
    // Mark: Slider - Increase Speed
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        switch Int(sender.value) {
        case 0:
            triggerConnection(cmd: ":R0#", setTag: 0)
        case 1:
            triggerConnection(cmd: ":R1#", setTag: 0)
        case 2:
            triggerConnection(cmd: ":R2#", setTag: 0)
        case 3:
            triggerConnection(cmd: ":R3#", setTag: 0)
        case 4:
            triggerConnection(cmd: ":R4#", setTag: 0)
        case 5:
            triggerConnection(cmd: ":R5#", setTag: 0)
        case 6:
            triggerConnection(cmd: ":R6#", setTag: 0)
        case 7:
            triggerConnection(cmd: ":R7#", setTag: 0)
        case 8:
            triggerConnection(cmd: ":R8#", setTag: 0)
        case 9:
            triggerConnection(cmd: ":R9#", setTag: 0)
        default:
            print("sero")
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

    // NE
    @objc func moveToNE() {
        triggerConnection(cmd: ":Mn#:Me#", setTag: 0)
        print("moveToNE")
    }

    @objc func stopToNE() {
        triggerConnection(cmd: ":Qn#:Qe#", setTag: 0)
        print("stopToNE")
    }
    
    // NW
    @objc func moveToNW() {
        triggerConnection(cmd: ":Mn#:Mw#", setTag: 0)
        print("moveToNW")
    }
    
    @objc func stopToNW() {
        triggerConnection(cmd: ":Qn#:Qw#", setTag: 0)
        print("stopToNW")
    }
    
    // SE
    @objc func moveToSE() {
        triggerConnection(cmd: ":Ms#:Me#", setTag: 0)
        print("moveToSE")
    }
    
    @objc func stopToSE() {
        triggerConnection(cmd: ":Qs#:Qe#", setTag: 0)
        print("stopToSE")
    }

    // SW
    @objc func moveToSW() {
        triggerConnection(cmd: ":Ms#:Mw#", setTag: 0)
        print("moveToSW")
    }
    
    @objc func stopToSW() {
        triggerConnection(cmd: ":Qs#:Qw#", setTag: 0)
        print("stopToSW")
    }
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#", setTag: 0)
        print("moveToNorth")
    }
    
    @objc func stopToNorth() {
        triggerConnection(cmd: ":Qn#", setTag: 0)
        print("stopToNorth")
    }
    
    // South
    @objc func moveToSouth() {
        triggerConnection(cmd: ":Ms#", setTag: 0)
        print("moveToSouth")
    }
    
    @objc func stopToSouth() {
        triggerConnection(cmd: ":Qs#", setTag: 0)
        print("stopToSouth")
    }
    
    // West
    @objc func moveToWest() {
        triggerConnection(cmd: ":Mw#", setTag: 0)
        print("moveToWest")
    }
    
    @objc func stopToWest() {
        triggerConnection(cmd: ":Qw#", setTag: 0)
        print("stopToWest")
    }
    
    // East
    @objc func moveToEast() {
        triggerConnection(cmd: ":Me#", setTag: 0)
        print("moveToEast")
    }
    
    @objc func stopToEast() {
        triggerConnection(cmd: ":Qe#", setTag: 0)
        print("stopToEast")
    }
    
    // Stop
    @IBAction func stopScope(_ sender: Any) {
        triggerConnection(cmd: ":Q#", setTag: 0)
    }
    
    
    func flip() {
        
        self.northBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.southBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.eastBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.westBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.NEBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.SEBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.NWBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.SWBtn.removeTarget(nil, action: nil, for: .allEvents)
        
        if flippedSN == false && flippedEW == false {
            DispatchQueue.main.async {
                print("flippedSN == false && flippedEW == false 0")
                self.northBtn.setTitle("North", for: .normal)
                self.southBtn.setTitle("South", for: .normal)
                self.eastBtn.setTitle("East", for: .normal)
                self.westBtn.setTitle("West", for: .normal)
                
                self.NEBtn.setTitle("NE", for: .normal)
                self.SEBtn.setTitle("SE", for: .normal)
                self.NWBtn.setTitle("NW", for: .normal)
                self.SWBtn.setTitle("SW", for: .normal)

                
                self.northBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)

                self.southBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)

                self.eastBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)

                self.westBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)

                
                self.NEBtn.addTarget(self, action: #selector(self.moveToNE), for: UIControl.Event.touchDown)
                self.NEBtn.addTarget(self, action: #selector(self.stopToNE), for: UIControl.Event.touchUpInside)

                self.SEBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
                self.SEBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)

                self.NWBtn.addTarget(self, action: #selector(self.moveToNW), for: UIControl.Event.touchDown)
                self.NWBtn.addTarget(self, action: #selector(self.stopToNW), for: UIControl.Event.touchUpInside)

                self.SWBtn.addTarget(self, action: #selector(self.moveToSW), for: UIControl.Event.touchDown)
                self.SWBtn.addTarget(self, action: #selector(self.stopToSW), for: UIControl.Event.touchUpInside)


            }
        } else if flippedSN == true && flippedEW == false {
            DispatchQueue.main.async {
                print("flippedSN == true && flippedEW == false 1")
                self.northBtn.setTitle("South", for: .normal)
                self.southBtn.setTitle("North", for: .normal)
                self.eastBtn.setTitle("East", for: .normal)
                self.westBtn.setTitle("West", for: .normal)
                
                self.NEBtn.setTitle("SE", for: .normal)
                self.SEBtn.setTitle("NE", for: .normal)
                self.NWBtn.setTitle("SW", for: .normal)
                self.SWBtn.setTitle("NW", for: .normal)
                
                self.northBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
                
                self.southBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
                
                self.eastBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
                
                self.westBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
                
                
                self.NEBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
                self.NEBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)
                
                self.SEBtn.addTarget(self, action: #selector(self.moveToNE), for: UIControl.Event.touchDown)
                self.SEBtn.addTarget(self, action: #selector(self.stopToNE), for: UIControl.Event.touchUpInside)
                
                self.NWBtn.addTarget(self, action: #selector(self.moveToSW), for: UIControl.Event.touchDown)
                self.NWBtn.addTarget(self, action: #selector(self.stopToSW), for: UIControl.Event.touchUpInside)
                
                self.SWBtn.addTarget(self, action: #selector(self.moveToNW), for: UIControl.Event.touchDown)
                self.SWBtn.addTarget(self, action: #selector(self.stopToNW), for: UIControl.Event.touchUpInside)
            }

        } else if flippedSN == false && flippedEW == true {
            DispatchQueue.main.async {
                print("flippedSN == false && flippedEW == true) 2")
                self.northBtn.setTitle("North", for: .normal)
                self.southBtn.setTitle("South", for: .normal)
                self.eastBtn.setTitle("West", for: .normal)
                self.westBtn.setTitle("East", for: .normal)
                
                self.NEBtn.setTitle("NW", for: .normal)
                self.SEBtn.setTitle("SW", for: .normal)
                self.NWBtn.setTitle("NE", for: .normal)
                self.SWBtn.setTitle("SE", for: .normal)
                
                self.northBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
                
                self.southBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
                
                self.eastBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
                
                self.westBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
                
                
                self.NEBtn.addTarget(self, action: #selector(self.moveToNW), for: UIControl.Event.touchDown)
                self.NEBtn.addTarget(self, action: #selector(self.stopToNW), for: UIControl.Event.touchUpInside)
                
                self.SEBtn.addTarget(self, action: #selector(self.moveToSW), for: UIControl.Event.touchDown)
                self.SEBtn.addTarget(self, action: #selector(self.stopToSW), for: UIControl.Event.touchUpInside)
                
                self.NWBtn.addTarget(self, action: #selector(self.moveToNE), for: UIControl.Event.touchDown)
                self.NWBtn.addTarget(self, action: #selector(self.stopToNE), for: UIControl.Event.touchUpInside)
                
                self.SWBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
                self.SWBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)
            }
        } else if flippedSN == true && flippedEW == true {
            DispatchQueue.main.async {
                print("flippedSN == true && flippedEW == true 3")
                self.northBtn.setTitle("South", for: .normal)
                self.southBtn.setTitle("North", for: .normal)
                self.eastBtn.setTitle("West", for: .normal)
                self.westBtn.setTitle("East", for: .normal)
                
                self.NEBtn.setTitle("SW", for: .normal)
                self.SEBtn.setTitle("NW", for: .normal)
                self.NWBtn.setTitle("SE", for: .normal)
                self.SWBtn.setTitle("NE", for: .normal)
                
                self.northBtn.addTarget(self, action: #selector(self.moveToSouth), for: UIControl.Event.touchDown)
                self.northBtn.addTarget(self, action: #selector(self.stopToSouth), for: UIControl.Event.touchUpInside)
                
                self.southBtn.addTarget(self, action: #selector(self.moveToNorth), for: UIControl.Event.touchDown)
                self.southBtn.addTarget(self, action: #selector(self.stopToNorth), for: UIControl.Event.touchUpInside)
                
                self.eastBtn.addTarget(self, action: #selector(self.moveToWest), for: UIControl.Event.touchDown)
                self.eastBtn.addTarget(self, action: #selector(self.stopToWest), for: UIControl.Event.touchUpInside)
                
                self.westBtn.addTarget(self, action: #selector(self.moveToEast), for: UIControl.Event.touchDown)
                self.westBtn.addTarget(self, action: #selector(self.stopToEast), for: UIControl.Event.touchUpInside)
                
                
                self.NEBtn.addTarget(self, action: #selector(self.moveToSW), for: UIControl.Event.touchDown)
                self.NEBtn.addTarget(self, action: #selector(self.stopToSW), for: UIControl.Event.touchUpInside)
                
                self.SEBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
                self.SEBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)
                
                self.NWBtn.addTarget(self, action: #selector(self.moveToSE), for: UIControl.Event.touchDown)
                self.NWBtn.addTarget(self, action: #selector(self.stopToSE), for: UIControl.Event.touchUpInside)
                
                self.SWBtn.addTarget(self, action: #selector(self.moveToNE), for: UIControl.Event.touchDown)
                self.SWBtn.addTarget(self, action: #selector(self.stopToNE), for: UIControl.Event.touchUpInside)
            }
        }
    }
    
    // Mark: Reverse North-South buttons
    @IBAction func reverseNS(_ sender: UIButton) {
        if flippedSN == false {
            flippedSN = true
            flip()
            self.revNSBtn.setTitle("Re-flip North-South", for: .normal)
        } else if flippedSN == true {
            flippedSN = false
            flip()
            self.revNSBtn.setTitle("Flip North-South", for: .normal)
        }
        
    }

    @IBAction func reverseEW(_ sender: UIButton) {
        
        self.northBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.southBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.eastBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.westBtn.removeTarget(nil, action: nil, for: .allEvents)
        
        self.NEBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.SEBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.NWBtn.removeTarget(nil, action: nil, for: .allEvents)
        self.SWBtn.removeTarget(nil, action: nil, for: .allEvents)
        
        if flippedEW == false {
            flippedEW = true
            flip()
            self.revEWBtn.setTitle("Re-flip East-West", for: .normal)

        } else if flippedEW == true {
            flippedEW = false
            flip()
            self.revEWBtn.setTitle("Flip East-West", for: .normal)

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
            self.speedLbl.alpha = alpha
            
            
            self.NEBtn.alpha = alpha
            self.NWBtn.alpha = alpha
            self.SEBtn.alpha = alpha
            self.SWBtn.alpha = alpha

            self.revNSBtn.isUserInteractionEnabled = activate
            self.revEWBtn.isUserInteractionEnabled = activate
            self.syncBtn.isUserInteractionEnabled = activate
            self.speedSlider.isUserInteractionEnabled = activate
            
            self.NEBtn.isUserInteractionEnabled = activate
            self.NWBtn.isUserInteractionEnabled = activate
            self.SEBtn.isUserInteractionEnabled = activate
            self.SWBtn.isUserInteractionEnabled = activate
        }
    }
    
    
}

extension GuideCenterViewController: GCDAsyncSocketDelegate {
    
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
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText)
        switch tag {
        case 0:
            print("Tag 0:", getText!) // Returns nothing
        case 1:
            print("")
        default:
            print("def")
        }
        clientSocket.readData(withTimeout: -1, tag: tag)
        // clientSocket.disconnect()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        if err != nil && String(err!.localizedDescription) == "Socket closed by remote peer" { // Server Closed Connection
            print("Disconnected called:", err!.localizedDescription)
        } else if err != nil && String(err!.localizedDescription) == "Read operation timed out" { // Server Returned nothing upon request
            print("Disconnected called:", err!.localizedDescription)
            let banner = StatusBarNotificationBanner(title: "Command processed and returned nothing.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            let banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
}

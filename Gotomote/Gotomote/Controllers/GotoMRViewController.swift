//
//  GotoMRViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/21/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBannerSwift

class GotoMRViewController: UIViewController {
    var banner = FloatingNotificationBanner(title: "", style: .success)

    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    var defaultRate: String = String()
    var currentRate: String = String()
    var stepsPerSec: String = String()

    @IBOutlet var rateLabel: UILabel!
    
    @IBOutlet var fastestBtn: UIButton!
    @IBOutlet var fasterBtn: UIButton!
    @IBOutlet var defaultBtn: UIButton!
    @IBOutlet var slowerBtn: UIButton!
    @IBOutlet var slowestBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        addBtnProperties(button: fastestBtn)
        addBtnProperties(button: fasterBtn)
        addBtnProperties(button: defaultBtn)
        addBtnProperties(button: slowerBtn)
        addBtnProperties(button: slowestBtn)

        navigationItem.title = "GOTO MAX RATE"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        readerText = ""
       // self.triggerConnection(cmd: ":GX93#:VS#:GX92#", setTag: 1)   // DefaultMaxRate // stepsPerSec // StepsPerSecond
        rateLabel.text = String(format: "%.02f", ((1.0/(Double(defaultRate)!*1.0/1000000.0))/(Double(stepsPerSec)!))/240.0) + " deg/sec"
        
        print("thisss", defaultRate, currentRate, stepsPerSec)
    }
    
    // Mark: Change goto rate
    @IBAction func fastestAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!/2.0)#", setTag: 3)
    }
    
    @IBAction func fasterAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!/1.5)#", setTag: 4)
    }
    // TODO: Crash if not connected when button pressed
    @IBAction func defaultAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*1.0)#", setTag: 5)
    }
    
    @IBAction func slowerAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*1.5)#", setTag: 6)
    }
    
    @IBAction func slowestAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*2.0)#", setTag: 7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension GotoMRViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText!)
        switch tag {
        case 0:
            print("Tag 0:", getText!) // Unused
        case 1:
            print("Tag 1:", getText!) // Unused
        case 2:
            print("Tag 2:", getText!)
          //  currentRate = String(getText!.dropLast())
        case 3:
            print("Tag 3:", getText!) // Fastest
            if getText! == "1" {
                rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!/2.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"
                banner = FloatingNotificationBanner(title: "Max rate is 2x faster.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Fastest command failed.", style: .warning)
                banner.show()
            }
        case 4:
            print("Tag 4:", getText!) // Faster
            if getText! == "1" {
                rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!/1.5/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"
                banner = FloatingNotificationBanner(title: "Max rate is 1.5x faster.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Faster command failed.", style: .warning)
                banner.show()
            }
        case 5:
            print("Tag 5:", getText!) // Default
            if getText! == "1" {
                rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*1.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"
                banner = FloatingNotificationBanner(title: "Max rate is at default.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Default command failed.", style: .warning)
                banner.show()
            }
        case 6:
            print("Tag 6:", getText!) // Slower
            if getText! == "1" {
                rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*1.5/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"
                banner = FloatingNotificationBanner(title: "Max rate is 1.5x slower.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Slower command failed.", style: .warning)
                banner.show()
            }
        case 7:
            print("Tag 7:", getText!) // Slowest
            if getText! == "1" {
                rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*2.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"
                banner = FloatingNotificationBanner(title: "Max rate is 2x slower.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Slowest command failed.", style: .warning)
                banner.show()
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
            let banner = FloatingNotificationBanner(title: "Command processed.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) == "Connection refused" { // wrong port or ip
            print("Disconnected called:", err!.localizedDescription)
            banner = FloatingNotificationBanner(title: "Unable to make connection, please check address & port.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            banner = FloatingNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
}

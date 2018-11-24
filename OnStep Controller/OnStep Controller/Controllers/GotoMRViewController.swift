//
//  GotoMRViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/21/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBanner

class GotoMRViewController: UIViewController {

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
        self.triggerConnection(cmd: ":GX93#:VS#:GX92#", setTag: 1)   // DefaultMaxRate // stepsPerSec // StepsPerSecond
    }
    
    // Mark: Change goto rate
    @IBAction func fastestAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!/2.0)#", setTag: 0)
        rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!/2.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"


    }
    
    @IBAction func fasterAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!/1.5)#", setTag: 0)
        rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!/1.5/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"


    }
    // TODO: Crash if not connected when button pressed
    @IBAction func defaultAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*1.0)#", setTag: 0)
        rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*1.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"

    }
    
    @IBAction func slowerAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*1.5)#", setTag: 0)
        rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*1.5/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"


    }
    
    @IBAction func slowestAction(_ sender: UIButton) {
        readerText = ""
        self.triggerConnection(cmd: ":SX92,\(Double(defaultRate)!*2.0)#", setTag: 0)
        rateLabel.text = String(format: "%.02f", (((1.0/(Double(defaultRate)!*2.0/1000000.0))/(Double(stepsPerSec)!))/240.0)) + " deg/sec"


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
            readerText += "\(getText!)"
            
            let index = readerText.components(separatedBy: ",")
            print(index)
            
        case 1:
            print("Tag 1:", getText!)
            readerText += "\(getText!)"
            
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")

            print("ind", index)
            defaultRate = index[opt: 0] ?? "0"
            stepsPerSec = index[opt: 1] ?? "0"
            currentRate = index[opt: 2] ?? "0"
            rateLabel.text = String(format: "%.02f", ((1.0/(Double(index[opt: 2] ?? "0")!*1.0/1000000.0))/(Double(index[opt: 1] ?? "0")!))/240.0) + " deg/sec"

        case 2:
            print("Tag 2:", getText!)
          //  currentRate = String(getText!.dropLast())
                        
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

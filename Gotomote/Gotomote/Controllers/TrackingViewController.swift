//
//  TrackingViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/20/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBannerSwift

class TrackingViewController: UIViewController {
    var banner = FloatingNotificationBanner(title: "", style: .success)

    @IBOutlet var trSiderBtn: UIButton!
    @IBOutlet var trLunarBtn: UIButton!
    @IBOutlet var trSolarBtn: UIButton!
    
    @IBOutlet var coFullBtn: UIButton!
    @IBOutlet var coReftBrn: UIButton!
    @IBOutlet var coDualAxBtn: UIButton!
    @IBOutlet var coSnglAxBtn: UIButton!
    @IBOutlet var coOffBtn: UIButton!
    
    @IBOutlet var raSlowerBtn: UIButton!
    @IBOutlet var raFasterBtn: UIButton!
    @IBOutlet var raResetBtn: UIButton!
    
    @IBOutlet var TrCoStopBtn: UIButton!
    @IBOutlet var TrCoStartBtn: UIButton!

    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addBtnProperties(button: trSiderBtn)
        addBtnProperties(button: trLunarBtn)
        addBtnProperties(button: trSolarBtn)
        addBtnProperties(button: coFullBtn)
        addBtnProperties(button: coReftBrn)
        addBtnProperties(button: coDualAxBtn)
        addBtnProperties(button: coSnglAxBtn)
        addBtnProperties(button: coOffBtn)
        addBtnProperties(button: raSlowerBtn)
        addBtnProperties(button: raFasterBtn)
        addBtnProperties(button: raResetBtn)

        addBtnProperties(button: TrCoStopBtn)
        addBtnProperties(button: TrCoStartBtn)
        
        navigationItem.title = "TRACKING"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        

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
    
    //Mark - Tracking Rate
    
    // - Sidereal Rate
    @IBAction func sSiderealAct(_ sender: UIButton) {
        self.triggerConnection(cmd: ":TQ#", setTag: 0)
    }
    
    // - Lunar Rate
    @IBAction func sLunarAct(_ sender: UIButton) {
        // :TL#
        self.triggerConnection(cmd: ":TL#", setTag: 0)
    }
    
    // - Solar Rate
    @IBAction func sSolarrateAct(_ sender: UIButton) {
        // :TS#
        self.triggerConnection(cmd: ":TS#", setTag: 0)
    }
    
    //Mark - Compensated Tracking:
    
    // - Full
    @IBAction func cFullAct(_ sender: UIButton) {
        // OnTrack enable
        self.triggerConnection(cmd: ":To#", setTag: 1)
    }
    
    // - Refraction
    @IBAction func cReftAct(_ sender: UIButton) {
        // Track refraction enable // turn refraction compensation on, defaults to base sidereal tracking rate
        self.triggerConnection(cmd: ":Tr#", setTag: 2)
    }
    
    // - Off
    @IBAction func cOffAct(_ sender: UIButton) {
        // Track refraction disable
        self.triggerConnection(cmd: ":Tn#", setTag: 5)
    }
    
    // - Dual
    @IBAction func cDualAct(_ sender: UIButton) {
        // Track dual axis // turn on dual axis tracking
        self.triggerConnection(cmd: ":T2#", setTag: 3) // -------------
    }

    // - Single
    @IBAction func cSingleAct(_ sender: UIButton) {
        // Track single axis (disable Dec tracking on Eq mounts)
        self.triggerConnection(cmd: ":T1#", setTag: 4) // --------------
    }
    
    //Mark - Adjust Rate by 0.1Hz:
    
    // - Slower
    @IBAction func aSlowerAct(_ sender: UIButton) {
        // Track rate decrease 0.02Hz TODO - Run 5x
        self.triggerConnection(cmd: ":T-#:T-#:T-#:T-#:T-#", setTag: 0)
    }
    
    // - Faster
    @IBAction func aFasterAct(_ sender: UIButton) {
        // Track rate increase 0.02Hz TODO - Run 5x
        self.triggerConnection(cmd: ":T+#:T+#:T+#:T+#:T+#", setTag: 0)
    }
    
    // - Reset
    @IBAction func aRestAct(_ sender: UIButton) {
        // :TR# // Track refraction enable // Reset Base Rate to default
        self.triggerConnection(cmd: ":TR#", setTag: 0)
    }
    
    // - Tracking Control
    @IBAction func tStopAct(_ sender: UIButton) {
        // :Te# // Tracking disable
        self.triggerConnection(cmd: ":Td#", setTag: 6)
    }
    
    // - Start
    @IBAction func tStartAct(_ sender: UIButton) {
        // :Te# // Tracking enable
        self.triggerConnection(cmd: ":Te#", setTag: 7)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, senderspo: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TrackingViewController: GCDAsyncSocketDelegate {
    
    
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
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText!)
        switch tag {
        case 0:
            print("Tag 1:", getText!) // returns nothing
        case 1:
            print("Tag 1:", getText!) // cFullAct // OnTrack enable
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Full compensation on successful.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Full compensation on failed.", style: .danger)
                banner.show()
            }
        case 2:
            print("Tag 2:", getText!) // cReftAct // turn refraction compensation on, defaults to base sidereal tracking rate
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Turn refraction compensation on successful.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Turn refraction compensation on failed.", style: .danger)
                banner.show()
            }
        case 3:
            print("Tag 3:", getText!) // cDualAct // // turn on dual axis tracking
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Turn on dual axis tracking successful", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Turn on dual axis tracking failed", style: .danger)
                banner.show()
            }
        case 4:
            print("Tag 4:", getText!) // cSingleAct // Track single axis (disable Dec tracking on Eq mounts)
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Track single axis (disable Dec tracking on Eq mounts) successful.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Track single axis (disable Dec tracking on Eq mounts) failed.", style: .danger)
                banner.show()
            }
        case 5:
            print("Tag 5:", getText!) // cSingleAct // Track single axis (disable Dec tracking on Eq mounts)
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Track refraction disable successful.", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Track refraction disable failed.", style: .danger)
                banner.show()
            }
        case 6:
            print("Tag 6:", getText!) // tStopAct // Tracking disable
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Tracking disable successful", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Tracking disable failed.", style: .danger)
                banner.show()
            }
        case 7:
            print("Tag 7:", getText!) // tStartAct // Tracking enable
            if getText! == "1" {
                banner = FloatingNotificationBanner(title: "Tracking enable successful", style: .success)
                banner.show()
            } else {
                banner = FloatingNotificationBanner(title: "Tracking enable failed.", style: .danger)
                banner.show()
            }
        default:
            print("def")
        }
        clientSocket.readData(withTimeout: -1, tag: tag)
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

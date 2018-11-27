//
//  BacklashViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import NotificationBanner

class BacklashViewController: UIViewController, UITextFieldDelegate {

    var clientSocket: GCDAsyncSocket!
    var readerArray: [String] = [String]()
    
    @IBOutlet var uploadBtn: UIButton!
    
    //BacklashView
    var backRa: String = String()
    var backDec: String = String()
    
    @IBOutlet var backRaTF: CustomTextField!
    @IBOutlet var backDecTF: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backRaTF.text = backRa
        backDecTF.text = backDec

        
        backRaTF.delegate = self
        backDecTF.delegate = self
        
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: backRaTF, placeholder: " ")
        addTFProperties(tf: backDecTF, placeholder: " ")

        navigationItem.title = "BACKLASH"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
 //       self.triggerConnection(cmd: ":%BR#:%BD#", setTag: 0) // RA // DEC

        
        //   % - Return parameter
        //  :%BD# Get Dec Antibacklash
        //          Return: d#
        //  :%BR# Get RA Antibacklash
        //          Return: d#
        //          Get the Backlash values.  Units are arc-seconds
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        if !backRaTF.text!.isEmpty && !backDecTF.text!.isEmpty {
            print("do stuff")
            readerArray.removeAll()
            self.triggerConnection(cmd: ":$BR\(backRaTF.text!)#:$BD\(backDecTF.text!)#", setTag: 0)
        } else {
            print("show error")
            let banner = StatusBarNotificationBanner(title: "Textfields can't be empty.", style: .danger)
            banner.show()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var check: Bool = Bool()
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length <= maxLength {
           // return true
            if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                check = true
            } else {
                check = false
            }
        }
        return check
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BacklashViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
      //  print("got:", getText)
        switch tag {
        case 0:
            readerArray.append(getText!)
            if readerArray.count == 2 {
                if readerArray[opt: 0] == "1" {
                    let banner = StatusBarNotificationBanner(title: "RA (Azm) backlash amount set successful.", style: .success)
                    banner.show()
                } else {
                    let banner = StatusBarNotificationBanner(title: "RA (Azm) backlash amount set failed.", style: .danger)
                    banner.show()
                }
                
                if readerArray[opt: 1] == "1" {
                    let banner = StatusBarNotificationBanner(title: "Set Dec (Alt) backlash amount successful.", style: .success)
                    banner.show()
                } else {
                    let banner = StatusBarNotificationBanner(title: "Set Dec (Alt) backlash amount failed.", style: .danger)
                    banner.show()
                }
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
            let banner = StatusBarNotificationBanner(title: "Command processed and returned nothing.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            let banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
}

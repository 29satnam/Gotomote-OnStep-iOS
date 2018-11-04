//
//  BacklashViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class BacklashViewController: UIViewController, UITextFieldDelegate {

    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet var backRaTF: CustomTextField!
    @IBOutlet var backDecTF: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backRaTF.delegate = self
        backDecTF.delegate = self
        
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: backRaTF, placeholder: " ")
        addTFProperties(tf: backDecTF, placeholder: " ")

        navigationItem.title = "BACKLASH"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black

    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        if !backRaTF.text!.isEmpty || !backDecTF.text!.isEmpty {
            print("do stuff")
            self.triggerConnection(cmd: ":$BR\(backRaTF.text!)#:$BD\(backDecTF.text!)#", setTag: 0)

        } else {
            print("show error")
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
        print("got:", getText)
        switch tag {
        case 0:
            readerText += "\(getText!)"
            
            let index = readerText.components(separatedBy: ",")
            print(index, readerText)
            
            DispatchQueue.main.async {
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

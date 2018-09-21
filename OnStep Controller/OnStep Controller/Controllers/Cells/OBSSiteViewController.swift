//
//  OBSSiteViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/21/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class OBSSiteViewController: UIViewController {
    
    @IBOutlet var segmentControl: TTSegmentedControl!
    
    var clientSocket: GCDAsyncSocket!

    @IBOutlet var siteNaTF: CustomTextField!
    @IBOutlet var latTF: CustomTextField!
    @IBOutlet var longTF: CustomTextField!
    @IBOutlet var utcTF: CustomTextField!

    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet var useLocat: UIButton!
    
    var selectedIndex: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }

    func setupUserInterface() {
        
        navigationItem.title = "SITE SELECTION"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        addBtnProperties(button: uploadBtn)
        addBtnProperties(button: useLocat)
        
        addTFProperties(tf: siteNaTF, placeholder: "")
        addTFProperties(tf: latTF, placeholder: "")
        addTFProperties(tf: longTF, placeholder: "")
        addTFProperties(tf: utcTF, placeholder: "")
        
        segmentControl.itemTitles = ["Site 0","Site 1","Site 2", "Site 3"]
        
        segmentControl.allowChangeThumbWidth = false
        segmentControl.selectedTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.selectedTextColor = UIColor.black
        segmentControl.defaultTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.defaultTextColor = UIColor.white
        segmentControl.useGradient = false
        segmentControl.useShadow = false
        segmentControl.containerBackgroundColor = .clear
        segmentControl.thumbColor = (UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0))

        segmentControl.selectItemAt(index: 0, animated: true)
        selectedIndex = 0
        
        self.triggerConnection(cmd: ":W0#", setTag: 0) // Select site 0 (0-3)
        self.triggerConnection(cmd: ":GM#", setTag: 1) // Get site 0 name
        self.triggerConnection(cmd: ":Gt#", setTag: 2) // Get Latitude (for current site)
        self.triggerConnection(cmd: ":Gg#", setTag: 3) // Get Longitude (for current site)
        self.triggerConnection(cmd: ":GG#", setTag: 4) // Get UTC Offset(for current site)

        segmentControl.didSelectItemWith = { index, title in
            self.selectedIndex = index
            
            switch self.selectedIndex {
            case 0:
                print("0")
                self.triggerConnection(cmd: ":W0#", setTag: 0) // Select site 0 (0-3)
                self.triggerConnection(cmd: ":GM#", setTag: 1) // Get site 0 name
                self.triggerConnection(cmd: ":Gt#", setTag: 2) // Get Latitude (for current site) - stays same
                self.triggerConnection(cmd: ":Gg#", setTag: 3) // Get Longitude (for current site) - stays same
                self.triggerConnection(cmd: ":GG#", setTag: 4) // Get UTC Offset(for current site) - stays same
            case 1:
                print("1")
                self.triggerConnection(cmd: ":W1#", setTag: 0) // Select site 1 (0-3)
                self.triggerConnection(cmd: ":GN#", setTag: 5) // Get site 1 name
                self.triggerConnection(cmd: ":Gt#", setTag: 6) // Get Latitude (for current site) - stays same
                self.triggerConnection(cmd: ":Gg#", setTag: 7) // Get Longitude (for current site) - stays same
                self.triggerConnection(cmd: ":GG#", setTag: 8) // Get UTC Offset(for current site) - stays same
            case 2:
                print("2")
                self.triggerConnection(cmd: ":W2#", setTag: 0) // Select site 2 (0-3)
                self.triggerConnection(cmd: ":G0#", setTag: 9) // Get site 1 name
                self.triggerConnection(cmd: ":Gt#", setTag: 10) // Get Latitude (for current site) - stays same
                self.triggerConnection(cmd: ":Gg#", setTag: 11) // Get Longitude (for current site) - stays same
                self.triggerConnection(cmd: ":GG#", setTag: 12) // Get UTC Offset(for current site) - stays same
            case 3:
                print("3")
                self.triggerConnection(cmd: ":W3#", setTag: 0) // Select site 3 (0-3)
                self.triggerConnection(cmd: ":GP#", setTag: 13) // Get site 3 name
                self.triggerConnection(cmd: ":Gt#", setTag: 14) // Get Latitude (for current site) - stays same
                self.triggerConnection(cmd: ":Gg#", setTag: 15) // Get Longitude (for current site) - stays same
                self.triggerConnection(cmd: ":GG#", setTag: 16) // Get UTC Offset(for current site) - stays same
            default:
                print("do something default")
            }


        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension OBSSiteViewController: GCDAsyncSocketDelegate {
    
    
    func triggerConnection(cmd: String, setTag: Int) {
        
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try clientSocket.connect(toHost: "192.168.0.1", onPort: UInt16(9999), withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let gettext = String(data: data, encoding: .utf8)
        
        switch tag {
        case 0:
            print("Select site 0 (0-3)", gettext!) // common for all "Sites"
            
        case 1:
            siteNaTF.text = gettext!
            print("Get site 0 name", gettext!)
        case 2:
            latTF.text = gettext!
            print("Get Latitude (for current site)", gettext!)
        case 3:
            longTF.text = gettext!
            print("Get Longitude (for current site)", gettext!)
        case 4:
            utcTF.text = gettext!
            print("Get UTC Offset(for current site)", gettext!)
            
        case 5:
            siteNaTF.text = gettext!
            print("Get site 0 name", gettext!)
        case 6:
            latTF.text = gettext!
            print("Get Latitude (for current site)", gettext!)
        case 7:
            longTF.text = gettext!
            print("Get Longitude (for current site)", gettext!)
        case 8:
            utcTF.text = gettext!
            print("Get UTC Offset(for current site)", gettext!)
            
        case 9:
            siteNaTF.text = gettext!
            print("Get site 0 name", gettext!)
        case 10:
            latTF.text = gettext!
            print("Get Latitude (for current site)", gettext!)
        case 11:
            longTF.text = gettext!
            print("Get Longitude (for current site)", gettext!)
        case 12:
            utcTF.text = gettext!
            print("Get UTC Offset(for current site)", gettext!)
            
        case 13:
            siteNaTF.text = gettext!
            print("Get site 0 name", gettext!)
        case 14:
            latTF.text = gettext!
            print("Get Latitude (for current site)", gettext!)
        case 15:
            longTF.text = gettext!
            print("Get Longitude (for current site)", gettext!)
        case 16:
            utcTF.text = gettext!
            print("Get UTC Offset(for current site)", gettext!)
            
        default:
            print("def")
        }
        

    /*    if tag == 0 {
            print("Select site 0 (0-3)", gettext!)
           // siteNaTF.text = gettext!
        } else if tag == 1 {
            print("Get site 0 name", gettext!)
            siteNaTF.text = gettext!

        } else if tag == 2 {
            print("Get Latitude (for current site)", gettext!)
            latTF.text = gettext!

        } else if tag == 3 {
            print("Get Longitude (for current site)", gettext!)
            longTF.text = gettext!

        } else if tag == 4 {
            print("Get UTC Offset(for current site)", gettext!)
            utcTF.text = gettext!

        } else {
            print("else", gettext!)
        } */
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

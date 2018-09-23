//
//  OBSSiteViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/21/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import CoreLocation

class OBSSiteViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var segmentControl: TTSegmentedControl!
    
    var clientSocket: GCDAsyncSocket!
    
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    @IBOutlet var siteNaTF: CustomTextField!
    @IBOutlet var latTF: CustomTextField!
    @IBOutlet var longTF: CustomTextField!
    @IBOutlet var utcTF: CustomTextField!
    
    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet var useLocat: UIButton!
    
    var selectedIndex: Int = Int()
    var readerText: String = String()
    
    @IBAction func userCurrentLocation(_ sender: UIButton) {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.startUpdatingLocation()
                if locationManager.location != nil {
                    latTF.text = "\(locationManager.location!.coordinate.latitude.roundedDecimal(to: 2))"
                    longTF.text = "\(locationManager.location!.coordinate.longitude.roundedDecimal(to: 2))"
                }

            }
        } else {
            print("Location services are not enabled")
            showLocationDisabledPopUp()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
        }
        
    }
    
    
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            locationManager.stopUpdatingLocation()
        //    latTF.text = "\(locationManager.location!.coordinate.latitude.roundedDecimal(to: 2))"
        //    longTF.text = "\(locationManager.location!.coordinate.longitude.roundedDecimal(to: 2))"
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            showLocationDisabledPopUp()
        } else if status == CLAuthorizationStatus.restricted {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Service disabled",
                                                message: "In order to access your location app needs to have loction services enabled in settings.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }
    
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
        
        self.triggerConnection(cmd: ":W0#:GM#:Gt#:Gg#:GG#", setTag: 0) // Reader for Site 0
        
        segmentControl.didSelectItemWith = { index, title in
            self.selectedIndex = index
            
            switch self.selectedIndex {
            case 0:
                print("0")
                self.readerText = ""
                DispatchQueue.main.async {
                    self.siteNaTF.text = ""
                    self.latTF.text = ""
                    self.longTF.text = ""
                    self.utcTF.text = ""
                    
                  /*  if self.latTF.text!.isEmpty && self.latTF.text!.isEmpty != true {
                                            UserDefaults.standard.set(location:CLLocation(latitude: Double(self.latTF.text!)!, longitude: Double(self.latTF.text!)!), forKey:"myLocation")
                        print("lol:", UserDefaults.standard.location(forKey:"myLocation")!)

                    }*/
                    

                    
                    
                }
                self.triggerConnection(cmd: ":W0#:GM#:Gt#:Gg#:GG#", setTag: 0) // Reader for Site 0
                
            case 1:
                print("1")
                self.readerText = ""
                DispatchQueue.main.async {
                    self.siteNaTF.text = ""
                    self.latTF.text = ""
                    self.longTF.text = ""
                    self.utcTF.text = ""
                }
                
                self.triggerConnection(cmd: ":W1#:GN#:Gt#:Gg#:GG#", setTag: 0) // Reader for Site 1
                
                
            case 2:
                print("2")
                self.readerText = ""
                DispatchQueue.main.async {
                    self.siteNaTF.text = ""
                    self.latTF.text = ""
                    self.longTF.text = ""
                    self.utcTF.text = ""
                }
                
                self.triggerConnection(cmd: ":W2#:GO#:Gt#:Gg#:GG#", setTag: 0) // Reader for Site 2
                
            case 3:
                print("3")
                self.readerText = ""
                DispatchQueue.main.async {
                    self.siteNaTF.text = ""
                    self.latTF.text = ""
                    self.longTF.text = ""
                    self.utcTF.text = ""
                }
                
                self.triggerConnection(cmd: ":W3#:GP#:Gt#:Gg#:GG#", setTag: 0) // Reader for Site 3
                
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
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let gettext = String(data: data, encoding: .utf8)
        
        switch tag {
        case 0:
            readerText += "\(gettext!)"
            
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")
            
            DispatchQueue.main.async {
                self.siteNaTF.text = index[optional: 0]
                self.latTF.text = index[optional: 1]
                self.longTF.text = index[optional: 2]
                self.utcTF.text = index[optional: 3]
            }
            
            
            
        case 1:
            siteNaTF.text = gettext!
            print("Get site 0 name", gettext!)
            
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

extension Collection {
    
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
    
}


extension Double {
    /// Convert `Double` to `Decimal`, rounding it to `scale` decimal places.
    ///
    /// - Parameters:
    ///   - scale: How many decimal places to round to. Defaults to `0`.
    ///   - mode:  The preferred rounding mode. Defaults to `.plain`.
    /// - Returns: The rounded `Decimal` value.
    
    func roundedDecimal(to scale: Int = 0, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var decimalValue = Decimal(self)
        var result = Decimal()
        NSDecimalRound(&result, &decimalValue, scale, mode)
        return result
    }
}

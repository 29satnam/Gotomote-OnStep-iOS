//
//  GotoCustomObjectViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/20/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

// TODO Goto command rejects if not aligned

import UIKit
import SwiftyJSON
import CoreLocation
import SpaceTime
import MathUtil
import CocoaAsyncSocket
import NotificationBanner

class GotoCustomObjectViewController: UIViewController {
    
    var passedCoordinates: [String] = [String]() // Get Latitude (for current site) // Get Longitude (for current site) // Get UTC Offset(for current site)
    var passedRA: String = String()
    var passedDec: String = String()

    // coordinatesToPass: ["+01.55", "+179.52"] rightAscension: 01:01:00 declination: -01:01:00
    
    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    
    var filteredJSON: [JSON] = [JSON()]
    
    @IBOutlet var gotoBtn: UIButton!
    @IBOutlet var abortBtn: UIButton!
    
  //  @IBOutlet var leftArrowBtn: UIButton!
  //  @IBOutlet var rightArrowBtn: UIButton!
    @IBOutlet var revNSBtn: UIButton!
    @IBOutlet var revEWBtn: UIButton!
    @IBOutlet var syncBtn: UIButton!
    
    @IBOutlet var northBtn: UIButton!
    @IBOutlet var southBtn: UIButton!
    @IBOutlet var westBtn: UIButton!
    @IBOutlet var eastBtn: UIButton!
    
    @IBOutlet var speedSlider: UISlider!
    
    // Segue Data
    var alignTypePassed: Int = Int()
    var passedSlctdObjIndex: Int = Int()
    
    @IBOutlet var ra: UILabel!
    @IBOutlet var dec: UILabel!
    
    @IBOutlet var altitude: UILabel!
    @IBOutlet var azimuth: UILabel!
    
    @IBOutlet var aboveHorizon: UILabel!
    
    var readerArray: [String] = [String]()

    // retrieved
   // var slctdJSONObj: [JSON] = [JSON()]
    
    let formatter = NumberFormatter()
    
    // formed
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @objc func screenUpdate() {

        
        //Right Ascension in hours and minutes  ->     :SrHH:MM:SS# *
        //The declination is given in degrees and minutes. -> :SdsDD:MM:SS# *
        
        // https://groups.io/g/onstep/topic/ios_app_for_onstep/23675334?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,40,23675334
        
        var splitRA = passedRA.split(separator: ":")
        var splitDec = passedDec.split(separator: ":")
        
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(splitRA[0])!, minute: Double(splitRA[1])!, second: Double(splitRA[2])!), declination: DegreeAngle(degree: Double(splitDec[0])!, minute: Double(splitDec[1])!, second: Double(splitDec[2])!), distance: 1)
        
        let date = Date()
        
        let locTime = ObserverLocationTime(location: CLLocation(latitude: Double(passedCoordinates[0])!, longitude: Double(passedCoordinates[1])!), timestamp: JulianDay(date: date))
        
        let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
        
        self.altitude.text = "Altitude: " + "\(vegaAziAlt.altitude.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        self.azimuth.text = "Azimuth: " + "\(vegaAziAlt.azimuth.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        
        self.aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
    }

    //         print("thisss:", String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    
    @IBAction func gotoBtn(_ sender: UIButton) {
     //   let formatRA = passedRA.replacingOccurrences(of: ":", with: "")
     //   let formatDec = passedDec.replacingOccurrences(of: ":", with: "")
        readerArray.removeAll()
        triggerConnection(cmd: ":Sr\(passedRA)#:Sd\(passedDec)#:MS#", setTag: 1) //Set target RA // Set target Dec // GOTO
        print(":Sr\(passedRA)#:Sd\(passedDec)#:MS#")
        // this -> :Sr21:30:00#:Sd+12:10:00#:MS#
        //:Sr123000#:Sd+234500#:MS#

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("passedCoordinatesss:", passedCoordinates)

        speedSlider.minimumValue = 0
        speedSlider.maximumValue = 9
        speedSlider.isContinuous = true
        
        northBtn.addTarget(self, action: #selector(moveToNorth), for: UIControl.Event.touchDown)
        northBtn.addTarget(self, action: #selector(stopToNorth), for: UIControl.Event.touchUpInside)
        
        southBtn.addTarget(self, action: #selector(moveToSouth), for: UIControl.Event.touchDown)
        southBtn.addTarget(self, action: #selector(stopToSouth), for: UIControl.Event.touchUpInside)
        
        westBtn.addTarget(self, action: #selector(moveToWest), for: UIControl.Event.touchDown)
        westBtn.addTarget(self, action: #selector(stopToWest), for: UIControl.Event.touchUpInside)
        
        eastBtn.addTarget(self, action: #selector(moveToEast), for: UIControl.Event.touchDown)
        eastBtn.addTarget(self, action: #selector(stopToEast), for: UIControl.Event.touchUpInside)
        
        setupLabelData()
        setupUserInterface()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(screenUpdate))
        displayLink.add(to: .main, forMode: RunLoop.Mode.default)
    }
    
    func alertMessage(message:String,buttonText:String,completionHandler:(()->())?) {
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func setupUserInterface() {
        addBtnProperties(button: gotoBtn)
        addBtnProperties(button: abortBtn)
      //  addBtnProperties(button: leftArrowBtn)
      //  addBtnProperties(button: rightArrowBtn)
        addBtnProperties(button: revNSBtn)
        addBtnProperties(button: revEWBtn)
        addBtnProperties(button: syncBtn)
        
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
        
        navigationItem.title = "SYNC CUSTOM OBJECT"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
    }
    
    func setupLabelData() {
        
        // RA
        var splitRA = passedRA.split(separator: ":")
        ra.text = "RA = \(splitRA[0])h \(splitRA[1])m \(splitRA[2])s"
        
        formatter.numberStyle = .decimal
        
        // DEC
            var splitDec = passedDec.split(separator: ":")
            dec.text = "DEC = \(splitDec[0])° \(splitDec[1])' \(splitDec[2])\""
    }
    
    func doubleToInteger(data:Double)-> Int {
        let doubleToString = "\(data)"
        let stringToInteger = (doubleToString as NSString).integerValue
        
        return stringToInteger
    }
    
    // Align the Star
    @IBAction func syncAction(_ sender: UIButton) {
        triggerConnection(cmd: ":CM#", setTag: 2)
        //  :CM#   Synchonize the telescope with the current database object (as above)
        //    Returns: "N/A#" on success, "En#" on failure where n is the error code per the :MS# command
    }
    
    // Pass Int back to controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
    @objc func moveToWest(_ sender: UIButton) {
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
        
        if revNSBtn.isUserInteractionEnabled == true {
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
          //  self.leftArrowBtn.alpha = alpha
          //  self.rightArrowBtn.alpha = alpha
            self.speedSlider.alpha = alpha
            
          //  self.leftArrowBtn.isUserInteractionEnabled = activate
          //  self.rightArrowBtn.isUserInteractionEnabled = activate
            self.revNSBtn.isUserInteractionEnabled = activate
            self.revEWBtn.isUserInteractionEnabled = activate
            self.syncBtn.isUserInteractionEnabled = activate
            self.speedSlider.isUserInteractionEnabled = activate
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension GotoCustomObjectViewController: GCDAsyncSocketDelegate {
    
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
    //    print("got:", getText)
        switch tag {
        case 0:
            print("shitt") // returns nothing
        case 1:
            print("Tag 1:", getText!) // GOTO Pressed
            readerArray.append(getText!)
            print(readerArray.count, readerArray)
            if readerArray.count == 3 {
                
                print("Reader", readerArray[opt: 1]!) // Returns nothing
                switch getText! {
                case "0":
                    let banner = StatusBarNotificationBanner(title: "Goto is possible.", style: .success)
                    banner.show()
                case "1":
                    let banner = StatusBarNotificationBanner(title: "Error: Below the horizon limit", style: .warning)
                    banner.show()
                case "2":
                    let banner = StatusBarNotificationBanner(title: "Error: Above overhead limit", style: .warning)
                    banner.show()
                case "3":
                    let banner = StatusBarNotificationBanner(title: "Error: Controller in standby", style: .warning)
                    banner.show()
                case "4":
                    let banner = StatusBarNotificationBanner(title: "Error: Mount is parked", style: .warning)
                    banner.show()
                case "5":
                    let banner = StatusBarNotificationBanner(title: "Error: Goto in progress", style: .warning)
                    banner.show()
                case "6":
                    let banner = StatusBarNotificationBanner(title: "Error: Outside limits (MaxDec, MinDec, UnderPoleLimit, MeridianLimit)", style: .warning)
                    banner.show()
                case "7":
                    let banner = StatusBarNotificationBanner(title: "Error: Hardware fault", style: .warning)
                    banner.show()
                case "8":
                    let banner = StatusBarNotificationBanner(title: "Error: Already in motion", style: .warning)
                    banner.show()
                case "9":
                    let banner = StatusBarNotificationBanner(title: "Error: Unspecified error", style: .warning)
                    banner.show()
                case "N/A#":
                    let banner = StatusBarNotificationBanner(title: "Sync Success.", style: .success) // :MS# -- GOTO
                    banner.show()
                default:
                    print("Defaut")
                }
            }
        case 2:
            print("Tag 2:", getText!) // Sync
            switch getText! {
            case "E0#":
                let banner = StatusBarNotificationBanner(title: "Goto is possible", style: .success)
                banner.show()
            case "E1#":
                let banner = StatusBarNotificationBanner(title: "Error: Below the horizon limit", style: .warning)
                banner.show()
            case "E2#":
                let banner = StatusBarNotificationBanner(title: "Error: Above overhead limit", style: .warning)
                banner.show()
            case "E3#":
                let banner = StatusBarNotificationBanner(title: "Error: Controller in standby", style: .warning)
                banner.show()
            case "E4#":
                let banner = StatusBarNotificationBanner(title: "Error: Mount is parked", style: .warning)
                banner.show()
            case "E5#":
                let banner = StatusBarNotificationBanner(title: "Error: Goto in progress", style: .warning)
                banner.show()
            case "E6#":
                let banner = StatusBarNotificationBanner(title: "Error: Outside limits (MaxDec, MinDec, UnderPoleLimit, MeridianLimit)", style: .warning)
                banner.show()
            case "E7#":
                let banner = StatusBarNotificationBanner(title: "Error: Hardware fault", style: .warning)
                banner.show()
            case "E8#":
                let banner = StatusBarNotificationBanner(title: "Error: Already in motion", style: .warning)
                banner.show()
            case "E9#":
                let banner = StatusBarNotificationBanner(title: "Error: Unspecified error", style: .warning)
                banner.show()
            case "N/A#":
                let banner = StatusBarNotificationBanner(title: "Sync Success.", style: .success) // :CM# -- Sync
                banner.show()
            default:
                print("Defaut")
            }
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

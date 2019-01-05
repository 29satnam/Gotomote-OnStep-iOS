//
//  GotoObjectViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 7/28/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import SpaceTime
import MathUtil
import CocoaAsyncSocket
import NotificationBanner

class GotoObjectViewControllerTwo: UIViewController {
    var banner = StatusBarNotificationBanner(title: "", style: .success)
    var passedCoordinates:[String] = [String]()
    
    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    
    var filteredJSON: [JSON] = [JSON()]
    
    @IBOutlet var gotoBtn: UIButton!
    @IBOutlet var abortBtn: UIButton!
    
    @IBOutlet var leftArrowBtn: UIButton!
    @IBOutlet var rightArrowBtn: UIButton!
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
    var vcTitlePassed: String = String()
    var passedSlctdObjIndex: Int = Int()

    // Labeling
    @IBOutlet var longName: UILabel!
    @IBOutlet var shortName: UILabel!
    @IBOutlet var ObjType: UILabel!
    
    @IBOutlet var ra: UILabel!
    @IBOutlet var dec: UILabel!
    
    @IBOutlet var altitude: UILabel!
    @IBOutlet var azimuth: UILabel!
    
    @IBOutlet var vMag: UILabel!

    @IBOutlet var aboveHorizon: UILabel!
    
    var readerText: String = String()
    
    // retrieved
    var slctdJSONObj: [JSON] = [JSON()]
   // var raStr: String = String()
    var decStr: Double = Double()
    
    let formatter = NumberFormatter()
    
    var readerArray: [String] = [String]()
    
    // formed
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @objc func screenUpdate() {
        /*
         raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue
         var raSepa = raStr.split(separator: " ")
         decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
         
         let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second: 34), declination: DegreeAngle(Double(decStr)), distance: 1)
         
         */
        
        let raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].doubleValue //raStr: 05 34.5
        let raSepa = hourToString(hour: raStr).components(separatedBy: ":")

        // ----
        
        formatter.numberStyle = .decimal
        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue //  decStr: +22 01
        
        let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
        
        // get whole number for degree value
        // let decDD = floor(Double(decForm)!)
        let decDD = doubleToInteger(data: (Double(decForm)!))
        
        print("decStr", decStr, "decForm", decForm, "decDD", decDD)
        
        
        //----------------
        
        //seperate degree's decimal and change to minutes
        let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
        print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
        
        // format the mintutes value (precision correction)
        let frmtr = NumberFormatter()
        frmtr.numberStyle = .decimal
        
        let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
        
        
        print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
        
        // drop negative sign for minute value
        var x = Double(decformmDecimal)
        if (x! < 0) {
            x! = 0 - x!
            //   print("dec min is neg", 0 - x!) // negative
        } else if (x! == 0) {
            x! = x!
        } else {
            x! = x! // postive
        }
        
        // double value to integer for minutes value
        let decMM = doubleToInteger(data: x!)
        
        // ------------------ seconds
        
        //seperate degree's decimal and change to minutes
        let decStrDeciSec = decStrDecimal.rounded().truncatingRemainder(dividingBy: 1) * 60
        
        // format the mintutes value (precision correction)
        let decStrDeciSecPart = formatter.string(from: NSNumber(value:Int(decStrDeciSec)))!
        formatter.numberStyle = .decimal
        
        print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
        
        
        // drop negative sign for seconds value
        var y = Double(decStrDeciSecPart)
        if (y! < 0) {
            y! = 0 - y!
            //   print("dec min is neg", 0 - y!) // negative
        } else if (y! == 0) {
            y! = y!
        } else {
            y! = y! // postive
        }
        
        //  print("yyy", y!)
        var decString: String = String()
        // double value to integer for minutes value
        let decSS = doubleToInteger(data: Double(y!.rounded())) // round off
        
        // adjust formatting if degrees single value is negative
        let z = decDD
        if (z < 0) {
            decString = String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //    print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)) //neg
        } else if (z == 0) {
            decString = String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //    print(String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)) // not happening
        } else {
            decString = String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //   print(String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS))
        }
        
        var splitDec = decString.split(separator: ":")
        
        //Right Ascension in hours and minutes  ->     :SrHH:MM:SS# *
        //The declination is given in degrees and minutes. -> :SdsDD:MM:SS# *
        
        // https://groups.io/g/onstep/topic/ios_app_for_onstep/23675334?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,40,23675334
        
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second:                                                          Double(raSepa[2])!), declination: DegreeAngle(degree: Double(splitDec[0])!, minute: Double(splitDec[1])!, second: Double(splitDec[2])!), distance: 1)
        //    print("lolol:", raHH, raMM, raSS, decDD, Double(decMM)!)
        
        let date = Date()
        let locTime = ObserverLocationTime(location: CLLocation(latitude: Double(passedCoordinates[0])!, longitude: Double(passedCoordinates[1])!), timestamp: JulianDay(date: date))
        
        let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
        
        self.altitude.text = "Altitude: " + "\(vegaAziAlt.altitude.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        self.azimuth.text = "Azimuth: " + "\(vegaAziAlt.azimuth.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        
        self.aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
    }
    
    //         print("thisss:", String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    
    @IBAction func gotoBtn(_ sender: UIButton) {
        
        //---------------- Dec
        formatter.numberStyle = .decimal
        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue

        let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
        
        // get whole number for degree value
        // let decDD = floor(Double(decForm)!)
        let decDD = doubleToInteger(data: (Double(decForm)!))
        
        print("decStr", decStr, "decForm", decForm, "decDD", decDD)
        
        
        //----------------
        
        //seperate degree's decimal and change to minutes
        let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
        print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
        
        // format the mintutes value (precision correction)
        let frmtr = NumberFormatter()
        frmtr.numberStyle = .decimal
        
        let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
        
        
        print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
        
        // drop negative sign for minute value
        var x = Double(decformmDecimal)
        if (x! < 0) {
            x! = 0 - x!
            //   print("dec min is neg", 0 - x!) // negative
        } else if (x! == 0) {
            x! = x!
        } else {
            x! = x! // postive
        }
        
        // double value to integer for minutes value
        let decMM = doubleToInteger(data: x!)
        
        // ------------------ seconds
        
        //seperate degree's decimal and change to minutes
        let decStrDeciSec = decStrDecimal.rounded().truncatingRemainder(dividingBy: 1) * 60
        
        // format the mintutes value (precision correction)
        let decStrDeciSecPart = formatter.string(from: NSNumber(value:Int(decStrDeciSec)))!
        formatter.numberStyle = .decimal
        
        print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
        
        
        // drop negative sign for seconds value
        var y = Double(decStrDeciSecPart)
        if (y! < 0) {
            y! = 0 - y!
            //   print("dec min is neg", 0 - y!) // negative
        } else if (y! == 0) {
            y! = y!
        } else {
            y! = y! // postive
        }
        
        //  print("yyy", y!)
        var decString: String = String()
        // double value to integer for minutes value
        let decSS = doubleToInteger(data: Double(y!.rounded())) // round off
        
        // adjust formatting if degrees single value is negative
        let z = decDD
        if (z < 0) {
            decString = String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //    print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)) //neg
        } else if (z == 0) {
            decString = String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //    print(String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)) // not happening
        } else {
            decString = String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
            //   print(String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS))
        }
        
        print("decString:", decString)
        //------------------- RA
        
        let raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].doubleValue
        let raSepa = hourToString(hour: raStr)

        readerArray.removeAll()
        triggerConnection(cmd: ":Sr\(raStr)#:Sd\(decString)#:MS#", setTag: 1) //Set target RA // Set target Dec // GOTO
        print(":ç\(raSepa)#:Sd\(decString)#:MS#")
        
        //sr //          Return: 0 on failure
        //                  1 on success
        
        //sd //          Return: 0 on failure
        //                  1 on successsss3
        
        //  :CS#   Synchonize the telescope with the current right ascension and declination coordinates
        //         Returns: Nothing (Sync's fail silently)
        //  :CM#   Synchonize the telescope with the current database object (as above)
        //         Returns: "N/A#" on success, "En#" on failure where n is the error code per the :MS# command
        
    }
    
    // Mark: Slider - Increase Speed
    
    @IBAction func abortBtn(_ sender: UIButton) {
        triggerConnection(cmd: ":Q#", setTag: 0)
        // Returns: Nothing
    }
    
    // Mark: Slider - Increase Speed
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        switch Int(sender.value) {
        case 0:
            triggerConnection(cmd: ":R0#", setTag: 0)
        //         Returns: Nothing
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
        print("slctdJSONObj:", slctdJSONObj)
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
    
    
    //Mark: Show next object action
    @IBAction func nextObject(_ sender: UIButton) {
        //     print("passedSlctdObjIndex:", passedSlctdObjIndex, "slctdJSONObj.count:", slctdJSONObj.count - 1)
        if passedSlctdObjIndex >= slctdJSONObj.count - 1 {
            
            let alertController = UIAlertController(title: "Wait!", message: "You've reached at end of list.", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                // drop at first object of list
                self.passedSlctdObjIndex = 0
                self.setupLabelData()
            }))
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            passedSlctdObjIndex += 1
            setupLabelData()
            
        }
    }
    
    //Mark: Show previous object action
    @IBAction func previousObject(_ sender: UIButton) {
        print("passedSlctdObjIndex:", passedSlctdObjIndex, "slctdJSONObj.count:", slctdJSONObj.count - 1)
        if passedSlctdObjIndex < 1 {
            
            let alertController = UIAlertController(title: "Wait!", message: "You've reached at start of list.", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                // drop at last object of list
                self.passedSlctdObjIndex = self.slctdJSONObj.count - 1
                self.setupLabelData()
            }))
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            passedSlctdObjIndex -= 1
            setupLabelData()
        }
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
        addBtnProperties(button: leftArrowBtn)
        addBtnProperties(button: rightArrowBtn)
        addBtnProperties(button: revNSBtn)
        addBtnProperties(button: revEWBtn)
        addBtnProperties(button: syncBtn)
        
        addBtnProperties(button: northBtn)
        northBtn.backgroundColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        addBtnProperties(button: southBtn)
        southBtn.backgroundColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        addBtnProperties(button: westBtn)
        westBtn.backgroundColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        addBtnProperties(button: eastBtn)
        eastBtn.backgroundColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        
        speedSlider.tintColor = UIColor(red: 144/255.0, green: 19/255.0, blue: 254/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = vcTitlePassed
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
    }
    
    func setupLabelData() {
        print(slctdJSONObj[passedSlctdObjIndex])
        
        // Long Name
        if (slctdJSONObj[passedSlctdObjIndex]["objNum"]) == "" {
            longName.text = "N/A "
        } else {
            longName.text = "\(slctdJSONObj[passedSlctdObjIndex]["objNum"].stringValue) "
        }
        
        // Type Name
        if (slctdJSONObj[passedSlctdObjIndex]["OBJType"]) == JSON.null {
          //  shortName.text = ""
            
            // Type Name -- For star list
            if (slctdJSONObj[passedSlctdObjIndex]["ABVR"]) == JSON.null {
                shortName.text = ""
                
            } else {
                shortName.text = "\(slctdJSONObj[passedSlctdObjIndex]["ABVR"].stringValue) "
            }
            
        } else {
            shortName.text = "\(slctdJSONObj[passedSlctdObjIndex]["OBJType"].stringValue) "
        }
        
        // Second name
        if (slctdJSONObj[passedSlctdObjIndex]["OTHER"]) == JSON.null {
            ObjType.text = ""
            
        } else {
            ObjType.text = "\(slctdJSONObj[passedSlctdObjIndex]["OTHER"].stringValue) "
        }
        
        
        // RA
        if (slctdJSONObj[passedSlctdObjIndex]["RA"]) == "" {
            ra.text = "RA = N/A "
        } else {
            
            let raSt = slctdJSONObj[passedSlctdObjIndex]["RA"].doubleValue
            formatter.numberStyle = .decimal

            let raSepa = hourToString(hour: raSt).components(separatedBy: ":")

            ra.text = "RA = \(raSepa[0])h \(raSepa[1])m \(raSepa[2])s"  //+ (slctdJSONObj[passedSlctdObjIndex]["RA"].string?.replacingOccurrences(of: " ", with: "h "))! + "m"
            
        }
        
        formatter.numberStyle = .decimal
        
        // DEC
        if (slctdJSONObj[passedSlctdObjIndex]["DEC"]) == "" {
            dec.text = "DEC = N/A "
        } else {
            
            let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
            
            let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
            
            // get whole number for degree value
            // let decDD = floor(Double(decForm)!)
            let decDD = doubleToInteger(data: (Double(decForm)!))
            
            print("decStr", decStr, "decForm", decForm, "decDD", decDD)
            
            
            //----------------
            
            //seperate degree's decimal and change to minutes
            let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
            print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
            
            // format the mintutes value (precision correction)
            let frmtr = NumberFormatter()
            frmtr.numberStyle = .decimal
            
            let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
            
            
            print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
            
            // drop negative sign for minute value
            var x = Double(decformmDecimal)
            if (x! < 0) {
                x! = 0 - x!
                //   print("dec min is neg", 0 - x!) // negative
            } else if (x! == 0) {
                x! = x!
            } else {
                x! = x! // postive
            }
            
            // double value to integer for minutes value
            let decMM = doubleToInteger(data: x!)
            
            // ------------------ seconds
            
            //seperate degree's decimal and change to minutes
            let decStrDeciSec = decStrDecimal.rounded().truncatingRemainder(dividingBy: 1) * 60
            
            // format the mintutes value (precision correction)
            let decStrDeciSecPart = formatter.string(from: NSNumber(value:Int(decStrDeciSec)))!
            formatter.numberStyle = .decimal
            
            print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
            
            
            // drop negative sign for seconds value
            var y = Double(decStrDeciSecPart)
            if (y! < 0) {
                y! = 0 - y!
                //   print("dec min is neg", 0 - y!) // negative
            } else if (y! == 0) {
                y! = y!
            } else {
                y! = y! // postive
            }
            
            //  print("yyy", y!)
            var decString: String = String()
            // double value to integer for minutes value
            let decSS = doubleToInteger(data: Double(y!.rounded())) // round off
            
            // adjust formatting if degrees single value is negative
            let z = decDD
            if (z < 0) {
                decString = String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)
                //    print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)) //neg
            } else if (z == 0) {
                decString = String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
                //    print(String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)) // not happening
            } else {
                decString = String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)
                //   print(String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS))
            }
            
            var splitDec = decString.split(separator: ":")
            
            dec.text = "DEC = \(splitDec[0])° \(splitDec[1])' \(splitDec[1])\""
            // round off fix
        }
        
        // VMag
        if (slctdJSONObj[passedSlctdObjIndex]["Mag"]) == "" {
            vMag.text = "Visual Magnitude = N/A"
        } else {
            vMag.text = "Visual Magnitude = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["Mag"].numberValue)!) "
        }
    }
    
    func doubleToInteger(data:Double)-> Int {
        let doubleToString = "\(data)"
        let stringToInteger = (doubleToString as NSString).integerValue
        
        return stringToInteger
    }
    
    // Align the Star
    @IBAction func syncAction(_ sender: UIButton) {
        triggerConnection(cmd: ":CM#", setTag: 2)
        
        ////  :CM#   Synchonize the telescope with the current database object (as above)
        
        //         Returns: "N/A#" on success, "En#" on failure where n is the error code per the :MS# command
        
        ////  ---> GOTO Returns: "N/A#" on success, "En#" on failure where n is the error code per the :MS# command
    }
    
    // Pass Int back to controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#", setTag: 0)
        print("moveToNorth")
        //         Returns: Nothing
    }
    
    @objc func stopToNorth() {
        triggerConnection(cmd: ":Qn#", setTag: 0)
        print("stopToNorth")
        //         Returns: Nothing
    }
    
    // South
    @objc func moveToSouth() {
        triggerConnection(cmd: ":Ms#", setTag: 0)
        print("moveToSouth")
        //         Returns: Nothing
    }
    
    @objc func stopToSouth() {
        triggerConnection(cmd: ":Qs#", setTag: 0)
        print("stopToSouth")
        //         Returns: Nothing
    }
    
    // West
    @objc func moveToWest(_ sender: UIButton) {
        triggerConnection(cmd: ":Mw#", setTag: 0)
        print("moveToWest")
        //         Returns: Nothing
    }
    
    @objc func stopToWest() {
        triggerConnection(cmd: ":Qw#", setTag: 0)
        print("stopToWest")
        //         Returns: Nothing
    }
    
    // East
    @objc func moveToEast() {
        triggerConnection(cmd: ":Me#", setTag: 0)
        print("moveToEast")
        //         Returns: Nothing
    }
    
    @objc func stopToEast() {
        triggerConnection(cmd: ":Qe#", setTag: 0)
        print("stopToEast")
        //         Returns: Nothing
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
        
        if leftArrowBtn.isUserInteractionEnabled == true {
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
            self.leftArrowBtn.alpha = alpha
            self.rightArrowBtn.alpha = alpha
            self.speedSlider.alpha = alpha
            
            self.leftArrowBtn.isUserInteractionEnabled = activate
            self.rightArrowBtn.isUserInteractionEnabled = activate
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


extension GotoObjectViewControllerTwo: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText)
        switch tag {
        case 0:
            print("Tag 0:", getText!) // Returns nothing
        case 1:
            print("Tag 1:", getText!) // GOTO Pressed
            readerArray.append(getText!)
            print(readerArray.count, readerArray)
            if readerArray.count == 3 {
                
                print("Reader", readerArray[opt: 1]!) // Returns nothing
                switch getText! {
                case "0":
                    banner = StatusBarNotificationBanner(title: "Goto is possible.", style: .success)
                    banner.show()
                case "1":
                    banner = StatusBarNotificationBanner(title: "Error: Below the horizon limit", style: .warning)
                    banner.show()
                case "2":
                    banner = StatusBarNotificationBanner(title: "Error: Above overhead limit", style: .warning)
                    banner.show()
                case "3":
                    banner = StatusBarNotificationBanner(title: "Error: Controller in standby", style: .warning)
                    banner.show()
                case "4":
                    banner = StatusBarNotificationBanner(title: "Error: Mount is parked", style: .warning)
                    banner.show()
                case "5":
                    banner = StatusBarNotificationBanner(title: "Error: Goto in progress", style: .warning)
                    banner.show()
                case "6":
                    banner = StatusBarNotificationBanner(title: "Error: Outside limits (MaxDec, MinDec, UnderPoleLimit, MeridianLimit)", style: .warning)
                    banner.show()
                case "7":
                    banner = StatusBarNotificationBanner(title: "Error: Hardware fault", style: .warning)
                    banner.show()
                case "8":
                    banner = StatusBarNotificationBanner(title: "Error: Already in motion", style: .warning)
                    banner.show()
                case "9":
                    banner = StatusBarNotificationBanner(title: "Error: Unspecified error", style: .warning)
                    banner.show()
                case "N/A#":
                    banner = StatusBarNotificationBanner(title: "Sync Success.", style: .success) // :MS# -- GOTO
                    banner.show()
                default:
                    print("Defaut")
                }
            }
        case 2:
            print("Tag 2:", getText!) // Sync
            switch getText! {
            case "E0#":
                banner = StatusBarNotificationBanner(title: "Goto is possible", style: .success)
                banner.show()
            case "E1#":
                banner = StatusBarNotificationBanner(title: "Error: Below the horizon limit", style: .warning)
                banner.show()
            case "E2#":
                banner = StatusBarNotificationBanner(title: "Error: Above overhead limit", style: .warning)
                banner.show()
            case "E3#":
                banner = StatusBarNotificationBanner(title: "Error: Controller in standby", style: .warning)
                banner.show()
            case "E4#":
                banner = StatusBarNotificationBanner(title: "Error: Mount is parked", style: .warning)
                banner.show()
            case "E5#":
                banner = StatusBarNotificationBanner(title: "Error: Goto in progress", style: .warning)
                banner.show()
            case "E6#":
                banner = StatusBarNotificationBanner(title: "Error: Outside limits (MaxDec, MinDec, UnderPoleLimit, MeridianLimit)", style: .warning)
                banner.show()
            case "E7#":
                banner = StatusBarNotificationBanner(title: "Error: Hardware fault", style: .warning)
                banner.show()
            case "E8#":
                banner = StatusBarNotificationBanner(title: "Error: Already in motion", style: .warning)
                banner.show()
            case "E9#":
                banner = StatusBarNotificationBanner(title: "Error: Unspecified error", style: .warning)
                banner.show()
            case "N/A#":
                banner = StatusBarNotificationBanner(title: "Sync Success.", style: .success) // :CM# -- Sync
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
            let banner = StatusBarNotificationBanner(title: "Command processed.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) == "Connection refused" { // wrong port or ip
            print("Disconnected called:", err!.localizedDescription)
            banner = StatusBarNotificationBanner(title: "Unable to make connection, please check address & port.", style: .success)
            banner.show()
        } else if err != nil && String(err!.localizedDescription) != "Read operation timed out" && String(err!.localizedDescription) != "Socket closed by remote peer" {
            print("Disconnected called:", err!.localizedDescription) // Not nil, not timeout, not closed by server // Throws error like no connection..
            banner = StatusBarNotificationBanner(title: "\(err!.localizedDescription)", style: .danger)
            banner.show()
        }
    }
}

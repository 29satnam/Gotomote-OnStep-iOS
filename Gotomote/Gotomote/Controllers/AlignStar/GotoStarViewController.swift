//
//  GotoStarViewController.swift
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

class GotoStarViewController: UIViewController {
    var banner = StatusBarNotificationBanner(title: "", style: .success)
    
    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!
    
    var readerText: String = String()
    var readerArray: [String] = [String]()
    
    var utcString: String =  String()

    @IBOutlet var gotoBtn: UIButton!
    @IBOutlet var abortBtn: UIButton!

    @IBOutlet var leftArrowBtn: UIButton!
    @IBOutlet var rightArrowBtn: UIButton!
    @IBOutlet var revNSBtn: UIButton!
    @IBOutlet var revEWBtn: UIButton!
    @IBOutlet var alignBtn: UIButton!

    @IBOutlet var northBtn: UIButton!
    @IBOutlet var southBtn: UIButton!
    @IBOutlet var westBtn: UIButton!
    @IBOutlet var eastBtn: UIButton!
    
    @IBOutlet var speedSlider: UISlider!

    // Segue Data
    var alignTypePassed: Int = Int()
    var vcTitlePassed: String = String()
    var passedSlctdObjIndex: Int = Int()
    var coordinates:[String] = [String]() // to bee passed

    // Labeling
    @IBOutlet var longName: UILabel!
    @IBOutlet var shortName: UILabel!
    
    @IBOutlet var ra: UILabel!
    @IBOutlet var dec: UILabel!
    
    @IBOutlet var altitude: UILabel!
    @IBOutlet var azimuth: UILabel!
    
    @IBOutlet var vMag: UILabel!
    @IBOutlet var aboveHorizon: UILabel!
    
    var slctdJSONObj: [JSON] = [JSON]() //= grabJSONData(resource: "Bright Stars")
    
    var decStr: Double = Double()
    var raStr: Double = Double()
    
    let formatter = NumberFormatter()


    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    @objc func screenUpdate() {
        /*
        raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue
        var raSepa = raStr.split(separator: " ")
        decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second: 34), declination: DegreeAngle(Double(decStr)), distance: 1)
        */
        raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].doubleValue
        let raHHMMSS = hourToString(hour: raStr).components(separatedBy: ":")

        // ----

        //      let raSS = Double(raSepaMM[opt: 1]!)!/10*(60)
        
        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue //  decStr: +22 01
        // ----
        
        formatter.numberStyle = .decimal
        
        let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
        
        // get whole number for degree value
        // let decDD = floor(Double(decForm)!)
        let decDD = doubleToInteger(data: (Double(decForm)!))
        
     //   print("decStr", decStr, "decForm", decForm, "decDD", decDD)
        
        //----------------
        
        //seperate degree's decimal and change to minutes
        let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
     //   print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
        
        // format the mintutes value (precision correction)
        let frmtr = NumberFormatter()
        frmtr.numberStyle = .decimal
        
        let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
        
      //  print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
        
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
        
       // print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
        
        
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
        
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raHHMMSS[0])!, minute: Double(raHHMMSS[1])!, second: Double(raHHMMSS[2])!), declination: DegreeAngle(degree: (Double(splitDec[0])!), minute: (Double(splitDec[0])!), second: (Double(splitDec[0])!)), distance: 1)
        // TODO
      //  print(vegaCoord.declination, vegaCoord.rightAscension)
        
        let date = Date()
        let locTime = ObserverLocationTime(location: CLLocation(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!), timestamp: JulianDay(date: date))
        // T ODO
        let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
        
        self.altitude.text = "Altitude: " + "\(vegaAziAlt.altitude.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        self.azimuth.text = "Azimuth: " + "\(vegaAziAlt.azimuth.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        
        self.aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
        
    }
    
    //         print("thisss:", String(format: "%02d:%02d:%02d", hours, minutes, seconds))

    @IBAction func gotoBtn(_ sender: UIButton) {
        
        //--------------------- DEC
        
        formatter.numberStyle = .decimal
        decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
        
        formatter.numberStyle = .decimal
        
        let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
        
        // get whole number for degree value
        // let decDD = floor(Double(decForm)!)
        let decDD = doubleToInteger(data: (Double(decForm)!))
        
      //  print("decStr", decStr, "decForm", decForm, "decDD", decDD)
        
        //----------------
        
        //seperate degree's decimal and change to minutes
        let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
     //   print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
        
        // format the mintutes value (precision correction)
        let frmtr = NumberFormatter()
        frmtr.numberStyle = .decimal
        
        let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
        
      //  print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
        
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
        
      //  print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
        
        
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
        
       // var splitDec = decString.split(separator: ":")
        
        //------------------- RA
        
        readerArray.removeAll()
        
        let raSepa = hourToString(hour: raStr).components(separatedBy: ":")
        
        triggerConnection(cmd: ":Sr\(raSepa[opt: 0]!):\(raSepa[opt: 1]!):\(raSepa[opt: 2]!)#:Sd\(decString)#:MS#", setTag: 1) //Set target RA # Set target Dec
        print(":Sr\(raSepa[opt: 0]!):\(raSepa[opt: 1]!):\(raSepa[opt: 2]!)#:Sd\(decString)#:MS#")
        
        // :Sr16:29:00#:Sd-26:24:00#:MS#

        //  :MN#   Goto current RA/Dec but East of the Pier (within meridian limit overlap for GEM mounts)
        //         Returns: 0..9, see :MS#
    }
    
    // Mark: Slider - Increase Speed
    
    @IBAction func abortBtn(_ sender: UIButton) {
        triggerConnection(cmd: ":Q#", setTag: 3)
    }
    
    // Mark: Slider - Increase Speed
    @IBAction func sliderValueChanged(_ sender: UISlider) {

        switch Int(sender.value) {
        case 0:
            triggerConnection(cmd: ":R0#", setTag: 3)
        case 1:
            triggerConnection(cmd: ":R1#", setTag: 3)
        case 2:
            triggerConnection(cmd: ":R2#", setTag: 3)
        case 3:
            triggerConnection(cmd: ":R3#", setTag: 3)
        case 4:
            triggerConnection(cmd: ":R4#", setTag: 3)
        case 5:
            triggerConnection(cmd: ":R5#", setTag: 3)
        case 6:
            triggerConnection(cmd: ":R6#", setTag: 3)
        case 7:
            triggerConnection(cmd: ":R7#", setTag: 3)
        case 8:
            triggerConnection(cmd: ":R8#", setTag: 3)
        case 9:
            triggerConnection(cmd: ":R9#", setTag: 3)
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
        print("coordinates", coordinates)
        banner.bannerHeight = banner.bannerHeight + 5
        
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
        addBtnProperties(button: alignBtn)
        
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
        if (slctdJSONObj[passedSlctdObjIndex]["OTHER"]) == "" {
            longName.text = "N/A "
        } else {
            longName.text = "\(slctdJSONObj[passedSlctdObjIndex]["OTHER"].stringValue) "
        }
        
        // Short Name
        if (slctdJSONObj[passedSlctdObjIndex]["objNum"]) == "" {
            shortName.text = "N/A "
            
        } else {
            shortName.text = "\(slctdJSONObj[passedSlctdObjIndex]["objNum"].stringValue) "
        }
        
        // RA
        if (slctdJSONObj[passedSlctdObjIndex]["RA"]) == "" {
            ra.text = "RA = N/A "
        } else {
            raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].doubleValue
            formatter.numberStyle = .decimal
            
        //    print("raHH", raHH, "raMM", raMM, "raSS", raSS)
        let raHHMMSS = hourToString(hour: raStr).components(separatedBy: ":")
            
        ra.text = "RA = \(raHHMMSS[0])h \(raHHMMSS[1])m \(raHHMMSS[2])s"
        }
        
        formatter.numberStyle = .decimal
        
        // DEC
        if (slctdJSONObj[passedSlctdObjIndex]["DEC"]) == "" {
            dec.text = "DEC = N/A "
   //     } else {
            
         /*   if slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                print("it's an intege")
                dec.text = "DEC = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["DEC"].numberValue)!)" + "°"
*/
            } else {

            formatter.numberStyle = .decimal

            decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
            
            formatter.numberStyle = .decimal
            
            let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
            
            // get whole number for degree value
            // let decDD = floor(Double(decForm)!)
            let decDD = doubleToInteger(data: (Double(decForm)!))
            
         //   print("decStr", decStr, "decForm", decForm, "decDD", decDD)
            
            //----------------
            
            //seperate degree's decimal and change to minutes
            let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
         //   print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
            
            // format the mintutes value (precision correction)
            let frmtr = NumberFormatter()
            frmtr.numberStyle = .decimal
            
            let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
            
      //      print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
            
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
            
        //    print("decStrDeciSecPart", decStrDeciSecPart, "decStrDeciSec", decStrDeciSec)
            
            
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

                dec.text = "DEC = \(splitDec[0])° " + "\(splitDec[1])' " + "\(splitDec[2])\""

             //   print("raHH", raHH, "raMM", raMM, "raSS", raSS)
               // var raHHMMSS = String(format: "%02d:%02d:%02d", Int(raHH)!, raMM, Int(raSS)!)
      //      }

            // round off fix
        }
        
        // Mag
        if (slctdJSONObj[passedSlctdObjIndex]["Mag"]) == "" {
            vMag.text = "Visual Magnitude = N/A"
        } else {
            vMag.text = "Visual Magnitude = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["Mag"].numberValue)!) "
        }
    }

    // Align the Star
    @IBAction func alignAction(_ sender: UIButton) {
        triggerConnection(cmd: ":A+#", setTag: 2) // Align accept
    }
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#", setTag: 3)
        print("moveToNorth")
    }

    @objc func stopToNorth(_ sender: UIButton) {
        triggerConnection(cmd: ":Qn#", setTag: 3)
        print("stopToNorth")
    }
    
    // South
    @objc func moveToSouth() {
        triggerConnection(cmd: ":Ms#", setTag: 3)
        print("moveToSouth")
    }
    
    @objc func stopToSouth() {
       triggerConnection(cmd: ":Qs#", setTag: 3)
        print("stopToSouth")
    }
    
    // West
    @objc func moveToWest() {
        triggerConnection(cmd: ":Mw#", setTag: 3)
        print("moveToWest")
    }
    
    @objc func stopToWest() {
       triggerConnection(cmd: ":Qw#", setTag: 3)
        print("stopToWest")
    }
    
    // East
    @objc func moveToEast() {
       triggerConnection(cmd: ":Me#", setTag: 3)
        print("moveToEast")
    }
    
    @objc func stopToEast() {
        triggerConnection(cmd: ":Qe#", setTag: 3)
        print("stopToEast")
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
            self.alignBtn.alpha = alpha
            self.leftArrowBtn.alpha = alpha
            self.rightArrowBtn.alpha = alpha
            self.speedSlider.alpha = alpha
            
            self.leftArrowBtn.isUserInteractionEnabled = activate
            self.rightArrowBtn.isUserInteractionEnabled = activate
            self.revNSBtn.isUserInteractionEnabled = activate
            self.revEWBtn.isUserInteractionEnabled = activate
            self.alignBtn.isUserInteractionEnabled = activate
            self.speedSlider.isUserInteractionEnabled = activate
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Pass Int back to controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? SelectStarTableViewController {
            destination.alignType = alignTypePassed
            
            if vcTitlePassed == "FIRST STAR" {
                
                // Start second star alignment.
                print("start second")
              //  triggerConnection(cmd: ":A2#", setTag: 4)
                destination.vcTitle = "SECOND STAR"
                destination.coordinates = coordinates
                destination.utcString = utcString
                destination.filteredJSON = slctdJSONObj

            } else if vcTitlePassed ==  "SECOND STAR" {
                
                // Start third star alignment.
                print("start third")
              //  triggerConnection(cmd: ":A3#", setTag: 4)
                destination.vcTitle = "THIRD STAR"
                destination.coordinates = coordinates
                destination.utcString = utcString
                destination.filteredJSON = slctdJSONObj
                
            } else {
                destination.vcTitle = "STAR ALIGNMENT"
                destination.coordinates = coordinates
                destination.utcString = utcString
                destination.filteredJSON = slctdJSONObj
                
            }
        } else if segue.identifier == "backToInitialize" {
            
            if let destination = segue.destination as? InitializeViewController {
                destination.navigationItem.hidesBackButton = true
                destination.utcString = utcString
                print("oi", utcString)
                
            }
        }
    }
}


extension GotoStarViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let getText = String(data: data, encoding: .utf8)
        print("got:", getText)
        switch tag {
        case 0:
            print("Tag 0:", getText!) // Abort
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
            print("Tag 2:", getText!) // Align Accpet
            if getText! == "0" {
                print("Failed")
                banner = StatusBarNotificationBanner(title: "Align accept failed.", style: .warning)
                
                banner.show()
            } else {
                print("Success")
                alignTypePassed = alignTypePassed - 1
                if alignTypePassed <= 0 {       // 1 star
                    banner = StatusBarNotificationBanner(title: "Align accepted successfully.", style: .success)
                    
                    banner.show()
                    performSegue(withIdentifier: "backToInitialize", sender: self) // InitializeViewController
                } else if alignTypePassed == 1 { // 2 star
                    banner = StatusBarNotificationBanner(title: "Align accepted successfully.", style: .success)
                    
                    banner.show()
                    triggerConnection(cmd: ":A1#", setTag: 4)
                    print(":A1")
                } else if alignTypePassed == 2 { // 3 star
                    banner = StatusBarNotificationBanner(title: "Align accepted successfully.", style: .success)
                    
                    banner.show()
                    triggerConnection(cmd: ":A2#", setTag: 5)
                    print(":A2")

                }
            }
        case 3:
            print("Tag 3:", getText!) // Returns nothing
            if getText! == "0" {
            }
        case 4:
            print("Tag 4:", getText!) // 2 star
            if getText! == "1" {
                banner = StatusBarNotificationBanner(title: "Star #1 aligment started.", style: .success)
                
                banner.show()
                performSegue(withIdentifier: "backToStarList", sender: self) // SelectStarTableViewController
            }
        case 5:
            print("Tag 5:", getText!) // 3 star
            if getText! == "1" {
                banner = StatusBarNotificationBanner(title: "Star #2 aligment started.", style: .success)
                
                banner.show()
                performSegue(withIdentifier: "backToStarList", sender: self) // SelectStarTableViewController
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
// Read operation timed out

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

class GotoObjectViewController: UIViewController {

    var socketConnector: SocketDataManager!
    var clientSocket: GCDAsyncSocket!

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
    
    // Labeling
    @IBOutlet var longName: UILabel!
    @IBOutlet var shortName: UILabel!
    
    @IBOutlet var ra: UILabel!
    @IBOutlet var dec: UILabel!
    
    @IBOutlet var altitude: UILabel!
    @IBOutlet var azimuth: UILabel!
    
    @IBOutlet var vMag: UILabel!
    @IBOutlet var dist: UILabel!
    @IBOutlet var aboveHorizon: UILabel!
    
    var slctdJSONObj = grabJSONData(resource: "Bright Stars")
    
    var raStr: String = String()
    var decStr: Double = Double()

    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    @objc func screenUpdate() {
        
        raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue
        var raSepa = raStr.split(separator: " ")
        decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
        
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second: 34), declination: DegreeAngle(Double(decStr)), distance: 1)
        
        let date = Date()
        let locTime = ObserverLocationTime(location: CLLocation(latitude: 45, longitude: 68), timestamp: JulianDay(date: date))
        
        let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
        
        self.altitude.text = "Altitude: " + "\(vegaAziAlt.altitude.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        self.azimuth.text = "Azimuth: " + "\(vegaAziAlt.azimuth.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'"
        
        self.aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
        
    }
    
    //         print("thisss:", String(format: "%02d:%02d:%02d", hours, minutes, seconds))

    @IBAction func gotoBtn(_ sender: UIButton) {
        //   triggerConnection(cmd: ":Sd-23:12:12#")
        // triggerConnection(cmd: ":Sa-23:12:12#")
        //  triggerConnection(cmd: ":Gd#")
        //  triggerConnection(cmd: ":Sr12:05:45#")
    //    print("raStr", raStr, "decStr", decStr)
//        raStr 05 17 decStr 46.0
        
        // RA =     :SrHH:MM:SS# *
        // DEC =    :SdsDD:MM:SS# *
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
      //  print("cleanValue", String(format: "%.0f", decStr))
        let decDD = String(format: "%.0f", decStr) // -17
        
        
        
        
        let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
        var decformmDecimal = formatter.string(from: NSNumber(value:Int(decStrDecimal)))!

        var decDropNeg = Double(decformmDecimal)

        
        
        
        // drop negative sign
        if (decDropNeg! < 0) {
            print("decMM", 0 - decDropNeg!) // negative
            decDropNeg! = 0 - decDropNeg!
        } else if (decDropNeg! == 0) {
            decDropNeg! = decDropNeg!
        } else {
            decDropNeg! = decDropNeg!
        }
        print("decMM!", decDropNeg!)
        
        
        
        let raArray = raStr.split(separator: " ")
        
        let decFormat = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
        let decRep = "\(decFormat)".replacingOccurrences(of: ".", with: ":")
        
        let decArray = "\(decStr)".split(separator: ".")
      //  print("first:", decArray[opt: 0]!, "seconf:", decArray[opt: 1]!)
        
        

        
        
        
        // Add neg/pos sign then execute
        if (decStr < 0) {
            print("negative")
            triggerConnection(cmd: ":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!).0#:Sd\(decRep)#") //Set target RA # Set target Dec
            print(":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!).0#:Sd\(decRep)#")
        } else if (decStr == 0) {
         //   print("zero")
        } else {
            print("positive")
            triggerConnection(cmd: ":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!).0#:Sd+\(decRep)#") //Set target RA # Set target Dec
            print(":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!).0#:Sd+\(decRep)#")
        }
        
        //:Sr05:17.0# :Sd+46:00# right
        //:Sr05:15.0# :Sd-08:20#
        //
        
        
        //:Sr12:48.0# :Sd-59:70#
        
        
        
        
        
      //  print(":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!)#:Sds\(decRep)#") // :SrHH:MM#:Sd
      //  triggerConnection(cmd: ":Sr\(raArray[opt: 0]!):\(raArray[opt: 1]!)#:SdsDD:MM:SS#") //Set target RA # Set target Dec

    }
    
    // Mark: Slider - Increase Speed
    
    @IBAction func abortBtn(_ sender: UIButton) {
        triggerConnection(cmd: ":Q#")
    }
    
    // Mark: Slider - Increase Speed
    @IBAction func sliderValueChanged(_ sender: UISlider) {

        switch Int(sender.value) {
        case 0:
            triggerConnection(cmd: ":R0#")
        case 1:
            triggerConnection(cmd: ":R1#")
        case 2:
            triggerConnection(cmd: ":R2#")
        case 3:
            triggerConnection(cmd: ":R3#")
        case 4:
            triggerConnection(cmd: ":R4#")
        case 5:
            triggerConnection(cmd: ":R5#")
        case 6:
            triggerConnection(cmd: ":R6#")
        case 7:
            triggerConnection(cmd: ":R7#")
        case 8:
            triggerConnection(cmd: ":R8#")
        case 9:
            triggerConnection(cmd: ":R9#")
        default:
            print("sero")
        }

    }
    
    
    func triggerConnection(cmd: String) {
        
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try clientSocket.connect(toHost: "192.168.0.1", onPort: UInt16(9999), withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: -1, tag: 0)
        } catch {
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        northBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: southBtn)
        southBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: westBtn)
        westBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        addBtnProperties(button: eastBtn)
        eastBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        speedSlider.tintColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)

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
        if (slctdJSONObj[passedSlctdObjIndex]["NAME"]) == "" {
            shortName.text = "N/A "
            
        } else {
            shortName.text = "\(slctdJSONObj[passedSlctdObjIndex]["NAME"].stringValue) "
        }
        
        // RA
        if (slctdJSONObj[passedSlctdObjIndex]["RA"]) == "" {
            ra.text = "RA = N/A "
        } else {
            ra.text = "RA = " + (slctdJSONObj[passedSlctdObjIndex]["RA"].string?.replacingOccurrences(of: " ", with: "h "))! + "m"
            
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        // DEC
        if (slctdJSONObj[passedSlctdObjIndex]["DEC"]) == "" {
            dec.text = "DEC = N/A "
        } else {
            
            if slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                print("it's an intege")
                dec.text = "DEC = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["DEC"].numberValue)!)" + "°"

            } else {
                dec.text = "DEC = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["DEC"].numberValue)!.replacingOccurrences(of: ".", with: "° "))" + "'"

            }
            
            let value = (slctdJSONObj[passedSlctdObjIndex]["DEC"]).numberValue
            let int = floor(Double(truncating: value))
            let decimal = Double(truncating: value).truncatingRemainder(dividingBy: 1)
            print("int:", int, "deci:", decimal)
            
        }
        
        // VMag
        if (slctdJSONObj[passedSlctdObjIndex]["VMAG"]) == "" {
            vMag.text = "Visual Magnitude = N/A"
        } else {
            vMag.text = "Visual Magnitude = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["VMAG"].numberValue)!) "
        }
        
        // Distance
        if (slctdJSONObj[passedSlctdObjIndex]["DISTLY"]) == "" {
            dist.text = "Distance = N/A "
        } else {
            dist.text = "Distance = \(slctdJSONObj[passedSlctdObjIndex]["DISTLY"].doubleValue) ly"
        }
    }

    // Align the Star
    @IBAction func alignAction(_ sender: UIButton) {
        triggerConnection(cmd: ":A+#")
        alignTypePassed = alignTypePassed - 1
        print("this:", alignTypePassed)
        if alignTypePassed <= 0 {
            performSegue(withIdentifier: "backToInitialize", sender: self)
        } else {
            
            
            performSegue(withIdentifier: "backToStarList", sender: self)
        }
    }
    
    // Pass Int back to controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? SelectStarTableViewController {
            destination.alignType = alignTypePassed
            
            if vcTitlePassed == "FIRST STAR" {
                
                // Start second star alignment.
                print("start third")
                triggerConnection(cmd: ":A2#")
                destination.vcTitle = "SECOND STAR"
                
            } else if vcTitlePassed ==  "SECOND STAR" {
                
                // Start third star alignment.
                print("start third")
                triggerConnection(cmd: ":A3#")
                destination.vcTitle = "THIRD STAR"
                
            } else {
                destination.vcTitle = "STAR ALIGNMENT"
            }
        } else if segue.identifier == "initialize" {
            
            // trigger delegate socket values
            if let destination = segue.destination as? InitializeViewController {
                destination.navigationItem.hidesBackButton = true
            }
        }
        
    }
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#")
        print("moveToNorth")
    }

    @objc func stopToNorth(_ sender: UIButton) {
        triggerConnection(cmd: ":Qn#")
        print("stopToNorth")
    }
    
    // South
    @objc func moveToSouth() {
        triggerConnection(cmd: ":Ms#")
        print("moveToSouth")
    }
    
    @objc func stopToSouth() {
       triggerConnection(cmd: ":Qs#")
        print("stopToSouth")
    }
    
    // West
    @objc func moveToWest() {
        triggerConnection(cmd: ":Mw#")
        print("moveToWest")
    }
    
    @objc func stopToWest() {
       triggerConnection(cmd: ":Qw#")
        print("stopToWest")
    }
    
    // East
    @objc func moveToEast() {
       triggerConnection(cmd: ":Me#")
        print("moveToEast")
    }
    
    @objc func stopToEast() {
        triggerConnection(cmd: ":Qe#")
        print("stopToEast")
    }
    
    // Stop
    @IBAction func stopScope(_ sender: Any) {
        triggerConnection(cmd: ":Q#")
     //   print("stopScope")
        //    :T+#
       //    triggerConnection(cmd: ":R9#")

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
}


extension GotoObjectViewController: GCDAsyncSocketDelegate {
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected Called: ", err?.localizedDescription as Any)
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
        
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let text = String(data: data, encoding: .utf8)
        print("didRead:", text!)
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
}


extension Double {
    func formatNumber(minimumIntegerDigits: Int, minimumFractionDigits: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumIntegerDigits = minimumIntegerDigits
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        
        return numberFormatter.string(for: self) ?? ""
    }
}


extension Float
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

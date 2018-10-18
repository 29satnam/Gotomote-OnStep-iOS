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
    
    var filteredJSON: JSON = JSON()
    
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
    
    // retrieved
    var slctdJSONObj: JSON = JSON()
    var raStr: String = String()
    var decStr: Double = Double()
    
    let formatter = NumberFormatter()
    
    // formed
    
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
        
        //---------------- Dec

        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].string?.components(separatedBy: " ")
        var decString: String = String()
        let z = Int(decStr![0])!
        if (z < 0) {
            decString = String(format: "%03d:%02d", Int(decStr![0])!, Int(decStr![1])!)
            //    print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS)) //neg
        } else if (z == 0) {
            decString = String(format: "%02d:%02d", Int(decStr![0])!, Int(decStr![1])!)
            //    print(String(format: "%02d:%02d:%02d", decDD as CVarArg, decMM, decSS)) // not happening
        } else {
            decString = String(format: "+%02d:%02d", Int(decStr![0])!, Int(decStr![1])!)
            //   print(String(format: "+%02d:%02d:%02d", decDD as CVarArg, decMM, decSS))
        }
        
        print("decString::", decString)
        //------------------- RA

        let raArray = raStr.split(separator: " ")
        
        let raHH = raArray[0]
        let raMM = doubleToInteger(data: (Double(raArray[1])!))
        
        // seperate minutes's decimal and change to second
        let raMMSecSepa = Double(raArray[1])!.truncatingRemainder(dividingBy: 1) * 60
        
        // format the mintutes value (precision correction)
        let raSS = formatter.string(from: NSNumber(value:Int(raMMSecSepa)))!
        
        let RAHHMMSS = String(format: "%02d:%02d:%02d", Int(raHH)!, raMM, Int(raSS)!)

        triggerConnection(cmd: ":Sr\(RAHHMMSS)#:Sd\(decString):00#:CS#") //Set target RA # Set target Dec
         print("this -> :Sr\(RAHHMMSS)#:Sd\(decString):00#:MS#")
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

        print("filteredJSON:", filteredJSON)
        
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
        if (slctdJSONObj[passedSlctdObjIndex]["OBJECT"]) == "" {
            shortName.text = "N/A "
            
        } else {
            shortName.text = "\(slctdJSONObj[passedSlctdObjIndex]["OBJECT"].stringValue) "
        }
        
        // RA
        if (slctdJSONObj[passedSlctdObjIndex]["RA"]) == "" {
            ra.text = "RA = N/A "
        } else {
            
            raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue
            formatter.numberStyle = .decimal
            print("raStr", raStr)
            let raArray = raStr.split(separator: " ")
            let raHH = raArray[0]
            let raMM = doubleToInteger(data: (Double(raArray[1])!))
            
            // seperate minutes's decimal and change to second
            let raMMSecSepa = Double(raArray[1])!.truncatingRemainder(dividingBy: 1) * 60
            
            // format the mintutes value (precision correction)
            let raSS = formatter.string(from: NSNumber(value:Int(raMMSecSepa)))!
            
            print("raHH", raHH, "raMM", raMM, "raSS", raSS)
            let raHHMMSS = String(format: "%02d:%02d:%02d", Int(raHH)!, raMM, Int(raSS)!)
            
            var splitRA = raHHMMSS.split(separator: ":")
            print("splitRA", splitRA.count)
            ra.text = "RA = \(splitRA[0])h \(splitRA[1])m \(splitRA[2])s"  //+ (slctdJSONObj[passedSlctdObjIndex]["RA"].string?.replacingOccurrences(of: " ", with: "h "))! + "m"
            
        }
        
        formatter.numberStyle = .decimal
        
        // DEC
        if (slctdJSONObj[passedSlctdObjIndex]["DEC"]) == "" {
            dec.text = "DEC = N/A "
        } else {
                
            let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].string?.components(separatedBy: " ")
            
            dec.text = "DEC = \(decStr![0])° \(decStr![1])'"
            // round off fix
        }
        
        // VMag
        if (slctdJSONObj[passedSlctdObjIndex]["MAG"]) == "" {
            vMag.text = "Visual Magnitude = N/A"
        } else {
            vMag.text = "Visual Magnitude = \(formatter.string(from: slctdJSONObj[passedSlctdObjIndex]["MAG"].numberValue)!) "
        }
        
        // Distance
        if (slctdJSONObj[passedSlctdObjIndex]["CLASS"]) == "" {
            dist.text = "CLASS = N/A "
        } else {
            dist.text = "CLASS = \(slctdJSONObj[passedSlctdObjIndex]["CLASS"].doubleValue)"
        }
    }
    
    func doubleToInteger(data:Double)-> Int {
        let doubleToString = "\(data)"
        let stringToInteger = (doubleToString as NSString).integerValue
        
        return stringToInteger
    }
    
    // Align the Star
    @IBAction func syncAction(_ sender: UIButton) {
        triggerConnection(cmd: ":A+#")
      //  alignTypePassed = alignTypePassed - 1
      //  print("this:", alignTypePassed)
     /*   if alignTypePassed <= 0 {
            performSegue(withIdentifier: "backToInitialize", sender: self)
        } else {
            
            performSegue(withIdentifier: "backToStarList", sender: self)
        } */
    }
    
    // Pass Int back to controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // North
    @objc func moveToNorth() {
        triggerConnection(cmd: ":Mn#")
        print("moveToNorth")
    }
    
    @objc func stopToNorth() {
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
    @objc func moveToWest(_ sender: UIButton) {
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


extension JSON{
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}

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

class GotoObjectViewController: UIViewController {

    var delegate: TriggerConnectionDelegate?
    
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
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    
    @objc func screenUpdate() {
        
        let raStr = slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue.split(separator: " ")
        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].doubleValue
            
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raStr[0])!, minute: Double(raStr[1])!, second: 34), declination: DegreeAngle(Double(decStr)), distance: 1)
        
        let date = Date()
        

        //let locTime = ObserverLocationTime(location: location!, timestamp: JulianDay(date: date))
        
        let locTime = ObserverLocationTime(location: CLLocation(latitude: 45, longitude: 68), timestamp: JulianDay(date: date))
        
        let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
        
        self.altitude.text = "Altitude: " + "\(vegaAziAlt.altitude.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'" //String(format: "%.3f", vegaAziAlt.altitude.wrappedValue).replacingOccurrences(of: ".", with: "° ") + "'"
        self.azimuth.text = "Azimuth: " + "\(vegaAziAlt.azimuth.wrappedValue.roundedDecimal(to: 3))".replacingOccurrences(of: ".", with: "° ") + "'" //String(format: "%.3f", vegaAziAlt.azimuth.wrappedValue).replacingOccurrences(of: ".", with: "° ") + "'"
        
        self.aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
        
     //   print("latitude:", locTime.coordinate.latitude,"longitude:", location!.coordinate.longitude)
            
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
        delegate?.triggerConnection(cmd: ":A+#")
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
                delegate?.triggerConnection(cmd: ":A2#")
                destination.vcTitle = "SECOND STAR"
                
            } else if vcTitlePassed ==  "SECOND STAR" {
                
                // Start third star alignment.
                print("start third")
                delegate?.triggerConnection(cmd: ":A3#")
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
        delegate?.triggerConnection(cmd: ":Mn#")
        print("moveToNorth")
    }

    @objc func stopToNorth(_ sender: UIButton) {
        delegate?.triggerConnection(cmd: ":Qn#")
        print("stopToNorth")
    }
    
    // South
    @objc func moveToSouth() {
        delegate?.triggerConnection(cmd: ":Ms#")
        print("moveToSouth")
    }
    
    @objc func stopToSouth() {
        delegate?.triggerConnection(cmd: ":Qs#")
        print("stopToSouth")
    }
    
    // West
    @objc func moveToWest() {
        delegate?.triggerConnection(cmd: ":Mw#")
        print("moveToWest")
    }
    
    @objc func stopToWest() {
        delegate?.triggerConnection(cmd: ":Qw#")
        print("stopToWest")
    }
    
    // East
    @objc func moveToEast() {
        delegate?.triggerConnection(cmd: ":Me#")
        print("moveToEast")
    }
    
    @objc func stopToEast() {
        delegate?.triggerConnection(cmd: ":Qe#")
        print("stopToEast")
    }
    
    // Stop
    @IBAction func stopScope(_ sender: Any) {
        delegate?.triggerConnection(cmd: ":Q#")
        print("stopScope")
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

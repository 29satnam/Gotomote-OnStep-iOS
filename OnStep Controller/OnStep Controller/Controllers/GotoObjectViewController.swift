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
    
    // Location Manager Singleton Call
    var userCoords = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var managerInstance = FetchLocation.SharedManager
    
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabelData()
        setupUserInterface()
        fetchUserCurrentLocation()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(screenUpdate))
        displayLink.add(to: .main, forMode: RunLoop.Mode.default)
        

        northBtn.addTarget(self, action: #selector(moveToNorth), for: UIControl.Event.touchDown)
        northBtn.addTarget(self, action: #selector(stopToNorth), for: UIControl.Event.touchUpInside)
    }
    
    func fetchUserCurrentLocation() {
        
        let locationFetch = FetchLocation.SharedManager
        locationFetch.parentObject = self
        locationFetch.startUpdatingLocation()
        locationFetch.completionBlock = { [unowned self] (userCoordinates, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
            
            if let userLocation = userCoordinates as? CLLocationCoordinate2D {
                self.userCoords = userLocation
            }
        }
    }
    

    //Mark: Show next object action
    //Mark: Show next object action
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
        let decStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].stringValue
        
        let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raStr[0])!, minute: Double(raStr[1])!, second: 34), declination: DegreeAngle(Double(decStr)!), distance: 1)
        
        let date = Date()
        if let location = managerInstance.locationManager.location {
            
            let locTime = ObserverLocationTime(location: location, timestamp: JulianDay(date: date))
            let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
            
            altitude.text = "Altitude: " + String(format: "%.3f", vegaAziAlt.altitude.wrappedValue).replacingOccurrences(of: ".", with: "° ") + "'"
            azimuth.text = "Azimuth: " + String(format: "%.3f", vegaAziAlt.azimuth.wrappedValue).replacingOccurrences(of: ".", with: "° ") + "'"
            
            aboveHorizon.text = "Above Horizon? = \(vegaAziAlt.altitude.wrappedValue > 0 ? "Yes" : "No")"
            
            print("latitude:", location.coordinate.latitude,"longitude:", location.coordinate.longitude)

        }
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
      //  navigationItem.hidesBackButton = true
        
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
            ra.text = "RA = \(slctdJSONObj[passedSlctdObjIndex]["RA"].stringValue.replacingOccurrences(of: " ", with: "h "))" + "m"
            
        }
        
        // DEC
        if (slctdJSONObj[passedSlctdObjIndex]["DEC"]) == "" {
            dec.text = "DEC = N/A "
        } else {
            dec.text = "DEC = \(slctdJSONObj[passedSlctdObjIndex]["DEC"].stringValue.replacingOccurrences(of: ".", with: "° "))" + "'"
            
            let raStr = slctdJSONObj[passedSlctdObjIndex]["DEC"].stringValue.split(separator: " ")
            print(raStr)
        }
        
        // VMag
        if (slctdJSONObj[passedSlctdObjIndex]["VMAG"]) == "" {
            vMag.text = "Visual Magnitude = N/A"
        } else {
            vMag.text = "Visual Magnitude = \(slctdJSONObj[passedSlctdObjIndex]["VMAG"].doubleValue) "
        }
        
        // Distance
        if (slctdJSONObj[passedSlctdObjIndex]["DISTLY"]) == "" {
            dist.text = "Distance = N/A "
        } else {
            dist.text = "Distance = \(slctdJSONObj[passedSlctdObjIndex]["DISTLY"].doubleValue) ly"
        }
    }

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
                destination.vcTitle = "SECOND STAR"
            } else if vcTitlePassed ==  "SECOND STAR" {
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
    }
    
    // East
    
    @objc func MoveToEast() {
        delegate?.triggerConnection(cmd: ":Me#")
    }
    
    @objc func stopToEast() {
        delegate?.triggerConnection(cmd: ":Qe#")
    }
    
    @IBAction func stopScope(_ sender: Any) {
        delegate?.triggerConnection(cmd: ":Q#")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

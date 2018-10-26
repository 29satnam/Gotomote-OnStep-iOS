//
//  SelectStarTableViewController
//  OnStep Controller
//
//  Created by Satnam on 8/28/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import SpaceTime
import MathUtil


class SelectStarTableViewController: UITableViewController {
    var instance: LandingViewController = LandingViewController()
    
    var jsonObj: JSON = JSON()
    var alignType: Int = Int()
    var vcTitle: String = String()
    var slctdObj: JSON = JSON()
    var slctdObjIndex: Int = Int()
    
    var coordinates:[String] = [String]()
    
    var readerText: String = String()
    
    var filteredJSON: [JSON] = [JSON()] //[[String : Any]] = [[String : Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        jsonObj = grabJSONData(resource: "Bright Stars")
        print("coordinates", coordinates)
        navigationItem.title = vcTitle
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        let abortAlig = UIBarButtonItem(title: "Abort", style: .plain , target: self, action: #selector(abortAlignment))
        abortAlig.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.navigationItem.rightBarButtonItem = abortAlig
        

        filteredJSON.removeAll()
        
        for (key, entry) in jsonObj {
        //    print("key:", key, "entryValue:", entry)
            
            //  Right Ascension in hours and minutes for epoch 2000. // "RA": "06 45"
            //  Declination in degrees for epoch 2000.               // "DEC": -16.7
            
            let raStr = jsonObj[Int(key)!]["RA"].stringValue // "RA": "06 45",
            let raSepa = raStr.components(separatedBy: " ")
            
            let raHH = Double(raSepa[opt: 0]!)!
            let raSepaMM = raSepa[opt: 1]!.components(separatedBy: ".")  // "DEC": -16.7
            
            let raMM = Double(raSepaMM[opt: 0]!)! // "34"
      //      let raSS = Double(raSepaMM[opt: 1]!)!/10*(60)
            
            let decStr = jsonObj[Int(key)!]["DEC"].doubleValue //  decStr: +22 01
            let decSepa = "\(decStr)".components(separatedBy: ".")
            
            let decDD = Double(decSepa[opt: 0]!)! // 22.0
            let decMM = Int(decSepa[opt: 1]!)! // Double()! // 22.0
            
       //     print("decMM:", decMM)
            
         //   print("raStr:", raStr, "decStr:", decStr)
            
            //Right Ascension in hours and minutes  ->     :SrHH:MM:SS# *
            //The declination is given in degrees and minutes. -> :SdsDD:MM:SS# *
            
            // https://groups.io/g/onstep/topic/ios_app_for_onstep/23675334?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,40,23675334
            
            let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: raHH, minute: raMM, second: 0.0), declination: DegreeAngle(degree: decDD, minute: Double(decMM), second: 0.0), distance: 1)

            let date = Date()
            let locTime = ObserverLocationTime(location: CLLocation(latitude: 30.9090157, longitude: 75.851601), timestamp: JulianDay(date: date))
            
            let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
            
            if vegaAziAlt.altitude.wrappedValue > 0 {
                let filt = jsonObj[Int(key)!]
                filteredJSON.append(filt)
           //     print("ya")
            }
        }
     //   print("filteredJSON:", filteredJSON)
        tableView.reloadData()
        
        
    }
    @objc func abortAlignment(){
        print("clicked")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? GotoStarViewController {

            destination.alignTypePassed = alignType
            destination.vcTitlePassed = vcTitle
            destination.passedSlctdObjIndex = slctdObjIndex
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filteredJSON.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StarListTableViewCell
        
        // Number Empty Check
        if (self.filteredJSON[indexPath.row]["NUMBER"]) == "" {
            cell.numberLabel.text = "N/A "
        } else {
            cell.numberLabel.text = "\(self.filteredJSON[indexPath.row]["NUMBER"].stringValue) "
        }
        
        // Name Empty Check
        if (self.filteredJSON[indexPath.row]["NAME"]) == "" {
            cell.objectLabel.text = "N/A / "
        } else {
            cell.objectLabel.text = "\(self.filteredJSON[indexPath.row]["NAME"].stringValue) / "
        }
        
        // Other Empty Check
        if (self.filteredJSON[indexPath.row]["OTHER"]) == "" {
            cell.otherLabel.text = "N/A"
        } else {
            cell.otherLabel.text = "\(self.filteredJSON[indexPath.row]["OTHER"].stringValue)"
        }
        
        // Distance Empty Check
        if (self.filteredJSON[indexPath.row]["DISTLY"]) == "" {
            cell.magLabel.text = "N/A"
        } else {
            cell.magLabel.text = "Distance: \(self.filteredJSON[indexPath.row]["DISTLY"].doubleValue) ly"
        }
        
        // Visual Magnitude Empty Check
        if (self.filteredJSON[indexPath.row]["VMAG"]) == "" {
            cell.typeLabel.text = "N/A"
        } else {
            cell.typeLabel.text = "\(self.filteredJSON[indexPath.row]["VMAG"].doubleValue) Mv"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        slctdObj = filteredJSON[indexPath.row]
        slctdObjIndex = indexPath.row

        self.performSegue(withIdentifier: "gotoSegue", sender: self)
    }
    
}

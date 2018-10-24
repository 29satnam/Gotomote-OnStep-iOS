//
//  SelectObjectTableViewController
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

class SelectObjectTableViewController: UITableViewController {
    
    // To pass
    var jsonObj: JSON = JSON()
    var alignType: Int = Int()
    var vcTitle: String = String()
    var slctdObjIndex: Int = Int()

    var filteredJSON: [JSON] = [JSON()] //[[String : Any]] = [[String : Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (key, entry) in jsonObj {
            print("key:", key, "entryValue:", entry)
            
            let raStr = jsonObj[Int(key)!]["RA"].stringValue //raStr: 05 34.5
            let raSepa = raStr.components(separatedBy: " ")// stringValue.split(separator: " ")
            
            let raHH = Double(raSepa[opt: 0]!)!
            let raSepaMM = raSepa[opt: 1]!.components(separatedBy: ".")  // ["34", "5"]
            
            let raMM = Double(raSepaMM[opt: 0]!)! // "34"
            let raSS = Double(raSepaMM[opt: 1]!)!/10*(60)
            
            
            let decStr = jsonObj[Int(key)!]["DEC"].stringValue //  decStr: +22 01
            let decSepa = decStr.components(separatedBy: " ")
            
            let decDD = Double(decSepa[opt: 0]!)! // 22.0
            let decMM = String(format: "%02d", Int(decSepa[opt: 1]!)! as CVarArg)// Double()! // 22.0
            
            print("decMM:", decMM)
            
            print("raStr:", raStr, "decStr:", decStr)
            
            //Right Ascension in hours and minutes  ->     :SrHH:MM:SS# *
            //The declination is given in degrees and minutes. -> :SdsDD:MM:SS# *
            
            // https://groups.io/g/onstep/topic/ios_app_for_onstep/23675334?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,40,23675334

            let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: raHH, minute: raMM, second: raSS), declination: DegreeAngle(degree: decDD, minute: Double(decMM)!, second: 0.0), distance: 1)
            print(vegaCoord.declination, vegaCoord.rightAscension)
            let date = Date()
            let locTime = ObserverLocationTime(location: CLLocation(latitude: 45, longitude: 68), timestamp: JulianDay(date: date))
            
            let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
            
            if vegaAziAlt.altitude.wrappedValue > 0 {
                let filt = jsonObj[Int(key)!]
                filteredJSON.append(filt)
                print("ya")
            }
        }
        print("filteredJSON:", filteredJSON)
        tableView.reloadData()
       // navigationItem.title = "SELECT FIRST STAR"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
      //  let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
      //  navigationItem.leftBarButtonItem = backButton
        
   /*     let abortAlig = UIBarButtonItem(title: "Abort", style: .plain , target: self, action: #selector(abortAlignment))
        abortAlig.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.navigationItem.rightBarButtonItem = abortAlig */
    }
    
    @objc func abortAlignment(){
        print("clicked")
        print("filteredJSON", filteredJSON)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
   /* @objc func goBack(){
        dismiss(animated: true, completion: nil)
    } */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? GotoObjectViewController {
            
            destination.alignTypePassed = alignType
            destination.vcTitlePassed = vcTitle
            destination.passedSlctdObjIndex = slctdObjIndex
            destination.slctdJSONObj = jsonObj
            
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
        return filteredJSON.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ObjectListTableViewCell
        
        // Object Empty Check
        if (self.filteredJSON[indexPath.row]["OBJECT"]) == "" {
            cell.objectLabel.text = "N/A /"
        } else {
            cell.objectLabel.text = "\(self.filteredJSON[indexPath.row]["OBJECT"].stringValue) / "
        }
        
        // Other Empty Check
        if (self.filteredJSON[indexPath.row]["OTHER"]) == "" {
            cell.otherLabel.text = "N/A"
        } else {
            cell.otherLabel.text = "\(self.filteredJSON[indexPath.row]["OTHER"].stringValue)"
        }
        
        // Magnitude Empty Check
        if (self.filteredJSON[indexPath.row]["MAG"]) == "" {
                cell.magLabel.text = "N/A"
        } else {
            cell.magLabel.text = "\(self.filteredJSON[indexPath.row]["MAG"].doubleValue) Mv"
        }
        
        
        // Type Empty Check
        if (self.filteredJSON[indexPath.row]["TYPE"]) == "" {
            cell.typeLabel.text = "N/A"
        } else {
          //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
            
            switch (self.filteredJSON[indexPath.row]["TYPE"].stringValue) {
            case "ASTER":
                cell.typeLabel.text = "Asterism"
            case "BRTNB":
                cell.typeLabel.text = "Bright Nebula"
            case "CL+NB":
                cell.typeLabel.text = "Cluster with Nebulosity"
            case "DRKNB":
                cell.typeLabel.text = "Dark Nebula"
            case "GALCL":
                cell.typeLabel.text = "Galaxy cluster"
            case "GALXY":
                cell.typeLabel.text = "Galaxy"
            case "GLOCL":
                cell.typeLabel.text = "Globular Cluster"
            case "GX+DN":
                cell.typeLabel.text = "Diffuse Nebula in a Galaxy"
            case "GX+GC":
                cell.typeLabel.text = "Globular Cluster in a Galaxy"
            case "G+C+N":
                cell.typeLabel.text = "Cluster with Nebulosity in a Galaxy"
            case "LMCCN":
                cell.typeLabel.text = "Cluster with Nebulosity in the LMC"
            case "LMCDN":
                cell.typeLabel.text = "Diffuse Nebula in the LMC"
            case "LMCGC":
                cell.typeLabel.text = "Globular Cluster in the LMC"
            case "LMCOC":
                cell.typeLabel.text = "Open cluster in the LMC"
            case "NONEX":
                cell.typeLabel.text = "Nonexistent"
            case "OPNCL":
                cell.typeLabel.text = "Open Cluster"
            case "PLNNB":
                cell.typeLabel.text = "Planetary Nebula"
            case "SMCCN":
                cell.typeLabel.text = "Cluster with Nebulosity in the SMC"
            case "SMCDN":
                cell.typeLabel.text = "Diffuse Nebula in the SMC"
            case "SMCGC":
                cell.typeLabel.text = "Globular Cluster in the SMC"
            case "SMCOC":
                cell.typeLabel.text = "Open cluster in the SMC"
            case "SNREM":
                cell.typeLabel.text = "Supernova Remnant"
            case "QUASR":
                cell.typeLabel.text = "Quasar"
            case "1STAR":
                cell.typeLabel.text = "1 Star"
            case "2STAR":
                cell.typeLabel.text = "2 Star"
            case "3STAR":
                cell.typeLabel.text = "3 Star"
            case "4STAR":
                cell.typeLabel.text = "4 Star"
            case "5STAR":
                cell.typeLabel.text = "5 Star"
            default:
                cell.typeLabel.text = "N/A"

            }
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        slctdObjIndex = indexPath.row
        self.performSegue(withIdentifier: "gotoObjectSyncSegue", sender: self)
    }

}



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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (key, entry) in jsonObj {
            print("key0:", key, "entryValue:", entry)
            
          /*  var raStr = jsonObj["RA"].stringValue
            //  print("raStr:", raStr.stringValue.split(separator: " "))
            
            var raSepa = raStr.components(separatedBy: " ")// stringValue.split(separator: " ")
            var decStr = jsonObj["DEC"].stringValue
            
            let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second: 34), declination: DegreeAngle(Double(raSepa[0])!), distance: 1)
            
            let date = Date()
            let locTime = ObserverLocationTime(location: CLLocation(latitude: 45, longitude: 68), timestamp: JulianDay(date: date))
            
            let vegaAziAlt = HorizontalCoordinate.init(equatorialCoordinate: vegaCoord, observerInfo: locTime)
            
            if vegaAziAlt.altitude.wrappedValue > 0 {
                let filt = JSON(jsonObj)
                filteredJSON.append(filt)
            } */
        }
        

        
        
        
        
        
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
        return self.jsonObj.count
    }

    var filteredJSON: [JSON] = [JSON()] //[[String : Any]] = [[String : Any]]()

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ObjectListTableViewCell
        
        // Object Empty Check
        if (self.jsonObj[indexPath.row]["OBJECT"]) == "" {
            cell.objectLabel.text = "N/A /"
        } else {
            cell.objectLabel.text = "\(self.jsonObj[indexPath.row]["OBJECT"].stringValue) / "
        }
        
        // Other Empty Check
        if (self.jsonObj[indexPath.row]["OTHER"]) == "" {
            cell.otherLabel.text = "N/A"
        } else {
            cell.otherLabel.text = "\(self.jsonObj[indexPath.row]["OTHER"].stringValue)"
        }
        
        // Magnitude Empty Check
        if (self.jsonObj[indexPath.row]["MAG"]) == "" {
                cell.magLabel.text = "N/A"
        } else {
            cell.magLabel.text = "\(self.jsonObj[indexPath.row]["MAG"].doubleValue) Mv"
        }
        
        
        // Type Empty Check
        if (self.jsonObj[indexPath.row]["TYPE"]) == "" {
            cell.typeLabel.text = "N/A"
        } else {
          //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
            
            switch (self.jsonObj[indexPath.row]["TYPE"].stringValue) {
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



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

class SelectObjectTableViewControllerTwo: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)

    var leftConstraint: NSLayoutConstraint!
    var coordinates:[String] = [String]()
    
    // To pass
    var jsonObj: JSON = JSON()
    var alignType: Int = Int()
    var vcTitle: String = String()
    var slctdObjIndex: Int = Int()
    
    var filteredJSON: [JSON] = [JSON()]
    
    let formatter = NumberFormatter()
    
    var searchedArray: JSON = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        setupSearchController()
        // trasparent bar
        if let character = coordinates[1].character(at: 0) {
            print("character")
            if character == "-" {
                coordinates[1] = "+\(coordinates[1].dropFirst())"
            } else {
                coordinates[1] = "-\(coordinates[1].dropFirst())"
            }
        }
        
        filteredJSON.removeAll()
        calculateData()
        tableView.reloadData()
        
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.title = vcTitle + " LIST"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
    }
    
    func setupSearchController() {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.placeholder = "Search In " + vcTitle.capitalized
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.barStyle = .black
        
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.red
        searchController.searchBar.clearBackgroundColor()
        
        searchController.searchBar.backgroundColor = UIColor.black
        searchController.searchBar.searchBarStyle = .minimal

        tableView.tableHeaderView = searchController.searchBar
    }
    
    func calculateData() {
        
        for (key, entry) in jsonObj {
            //  Right Ascension in hours and minutes for epoch 2000. // "RA": "06 45"
            //  Declination in degrees for epoch 2000.               // "DEC": -16.7
            
            let raStr = jsonObj[Int(key)!]["RA"].doubleValue // "RA": 0.139791
            let raSepa = hourToString(hour: raStr).components(separatedBy: ":")
            
            // ----
            
            formatter.numberStyle = .decimal
            let decStr = jsonObj[Int(key)!]["DEC"].doubleValue //  decStr: +22 01
            
            let decForm = decStr.formatNumber(minimumIntegerDigits: 2, minimumFractionDigits: 2)
            
            // get whole number for degree value
            // let decDD = floor(Double(decForm)!)
            let decDD = doubleToInteger(data: (Double(decForm)!))
            
        //    print("decStr", decStr, "decForm", decForm, "decDD", decDD)
            
            //----------------
            
            //seperate degree's decimal and change to minutes
            let decStrDecimal = decStr.truncatingRemainder(dividingBy: 1) * 60
         //   print("decStrDecimal", decStrDecimal) // -47.99999999999983 alpha cent
            
            // format the mintutes value (precision correction)
            let frmtr = NumberFormatter()
            frmtr.numberStyle = .decimal
            
            let decformmDecimal = frmtr.string(from: NSNumber(value:Int(decStrDecimal.rounded())))!
            
        //    print("decStrDecimal",decStrDecimal, "decformmDecimal", decformmDecimal)
            
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
            
            var splitDec = decString.split(separator: ":")
            
            //Right Ascension in hours and minutes  ->     :SrHH:MM:SS# *
            //The declination is given in degrees and minutes. -> :SdsDD:MM:SS# *
            
            // https://groups.io/g/onstep/topic/ios_app_for_onstep/23675334?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,40,23675334
            
            let vegaCoord = EquatorialCoordinate(rightAscension: HourAngle(hour: Double(raSepa[0])!, minute: Double(raSepa[1])!, second:                                                          Double(raSepa[2])!), declination: DegreeAngle(degree: Double(splitDec[0])!, minute: Double(splitDec[1])!, second: Double(splitDec[2])!), distance: 1)
            
            let date = Date()
            let locTime = ObserverLocationTime(location: CLLocation(latitude: Double(coordinates[0])!, longitude: Double(coordinates[1])!), timestamp: JulianDay(date: date))
            
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
     //   print("clicked")
       // print("filteredJSON", filteredJSON)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? GotoObjectViewControllerTwo {
            
            destination.alignTypePassed = alignType
            destination.vcTitlePassed = vcTitle
            destination.passedSlctdObjIndex = slctdObjIndex
            destination.slctdJSONObj = filteredJSON
            destination.passedCoordinates = coordinates
            
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

        if searchController.isActive && searchController.searchBar.text != "" {
            return searchedArray.count
        } else {
            return filteredJSON.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ObjectListTableViewCellTwo
        
        if searchController.isActive && searchController.searchBar.text != "" {
            // Object Empty Check
            if (self.searchedArray[indexPath.row]["objNum"]) == "" { // changed
                cell.objectLabel.text = "N/A /"
            } else {
                cell.objectLabel.text = "\(self.searchedArray[indexPath.row]["objNum"].stringValue)"
            }
            
            // Other Empty Check
            if (self.searchedArray[indexPath.row]["ABVR"]) == "" { // changed
                cell.otherLabel.text = "N/A"
            } else {
                cell.otherLabel.text = "\(self.searchedArray[indexPath.row]["ABVR"].stringValue)"
            }
            
            // Magnitude Empty Check
            if (self.searchedArray[indexPath.row]["Mag"]) == "" { // changed
                cell.magLabel.text = "N/A"
            } else {
                cell.magLabel.text = "\(self.searchedArray[indexPath.row]["Mag"].doubleValue) Mv"
            }
            
            
            // Type Empty Check
            if (self.searchedArray[indexPath.row]["OBJType"]) == "" { // changed
                cell.typeLabel.text = "N/A"
            } else {
                //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
                cell.typeLabel.text = "\(self.searchedArray[indexPath.row]["OBJType"].stringValue)"
            }
            
            // OTHER Empty Check - OTHER
            if (self.searchedArray[indexPath.row]["OTHER"]) == JSON.null { // OTHER NAME
                cell.secName.text = ""
            } else {
                //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
                cell.secName.text = " - \(self.searchedArray[indexPath.row]["OTHER"].stringValue)"
            }
            
        } else { // not seaching
            // Object Empty Check
            if (self.filteredJSON[indexPath.row]["objNum"]) == "" { // changed
                cell.objectLabel.text = "N/A /"
            } else {
                cell.objectLabel.text = "\(self.filteredJSON[indexPath.row]["objNum"].stringValue)"
            }
            
            // Other Empty Check
            if (self.filteredJSON[indexPath.row]["ABVR"]) == "" { // changed
                cell.otherLabel.text = "N/A"
            } else {
                cell.otherLabel.text = "\(self.filteredJSON[indexPath.row]["ABVR"].stringValue)"
            }
            
            // Magnitude Empty Check
            if (self.filteredJSON[indexPath.row]["Mag"]) == "" { // changed
                cell.magLabel.text = "N/A"
            } else {
                cell.magLabel.text = "\(self.filteredJSON[indexPath.row]["Mag"].doubleValue) Mv"
            }
            
            
            // Type Empty Check
            if (self.filteredJSON[indexPath.row]["OBJType"]) == "" { // changed
                cell.typeLabel.text = "N/A"
            } else {
                //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
                cell.typeLabel.text = "\(self.filteredJSON[indexPath.row]["OBJType"].stringValue)"
            }
            
            // OTHER Empty Check - OTHER
            if (self.filteredJSON[indexPath.row]["OTHER"]) == JSON.null { // OTHER NAME
                cell.secName.text = ""
            } else {
                //  cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["TYPE"].stringValue)"
                cell.secName.text = " - \(self.filteredJSON[indexPath.row]["OTHER"].stringValue)"
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            let index = filteredJSON.index(of: searchedArray[indexPath.row])
            slctdObjIndex = index!
            self.performSegue(withIdentifier: "gotoObjectSyncSegueTwo", sender: self)
        } else {
            slctdObjIndex = indexPath.row
            self.performSegue(withIdentifier: "gotoObjectSyncSegueTwo", sender: self)
        }
    }
}


extension SelectObjectTableViewControllerTwo: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
                let searchPredicate = NSPredicate(format: "objNum contains[cd] %@", term)
                if let arrayObjs = JSON(filteredJSON).arrayObject {
                    let filtered = JSON(arrayObjs.filter{ searchPredicate.evaluate(with: $0) })
                    searchedArray = filtered
                    self.tableView.reloadData()
                }
            }
            
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

extension Double {
    func formatNumber(minimumIntegerDigits: Int, minimumFractionDigits: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumIntegerDigits = minimumIntegerDigits
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        
        return numberFormatter.string(for: self) ?? ""
    }
}


extension Float {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


extension Double {
    
    func splitIntoParts(decimalPlaces: Int, round: Bool) -> (leftPart: Int, rightPart: Int) {
        
        var number = self
        if round {
            //round to specified number of decimal places:
            let divisor = pow(10.0, Double(decimalPlaces))
            number = Darwin.round(self * divisor) / divisor
        }
        
        //convert to string and split on decimal point:
        let parts = String(number).components(separatedBy: ".")
        
        //extract left and right parts:
        let leftPart = Int(parts[0]) ?? 0
        let rightPart = Int(parts[1]) ?? 0
        
        return(leftPart, rightPart)
    }
}

extension UISearchBar {
    
    func clearBackgroundColor() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }
        
        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UISearchBarBackground) {
                    subview.alpha = 0
                }
            }
        }
    }
}

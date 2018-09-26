//
//  SelectStarTableViewController
//  OnStep Controller
//
//  Created by Satnam on 8/28/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import SwiftyJSON


class SelectStarTableViewController: UITableViewController {

    var instance: LandingViewController = LandingViewController()
    
    var jsonObj: JSON = JSON()
    var alignType: Int = Int()
    var vcTitle: String = String()
    var slctdObj: JSON = JSON()
    var slctdObjIndex: Int = Int()
    
    var delegate: TriggerConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonObj = grabJSONData(resource: "Bright Stars")

        navigationItem.title = vcTitle
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        let abortAlig = UIBarButtonItem(title: "Abort", style: .plain , target: self, action: #selector(abortAlignment))
        abortAlig.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.navigationItem.rightBarButtonItem = abortAlig
        
    }
    @objc func abortAlignment(){
        print("clicked")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? GotoObjectViewController {

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
        return self.jsonObj.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StarListTableViewCell
        
        // Number Empty Check
        if (self.jsonObj[indexPath.row]["NUMBER"]) == "" {
            cell.numberLabel.text = "N/A "
        } else {
            cell.numberLabel.text = "\(self.jsonObj[indexPath.row]["NUMBER"].stringValue) "
        }
        
        // Name Empty Check
        if (self.jsonObj[indexPath.row]["NAME"]) == "" {
            cell.objectLabel.text = "N/A / "
        } else {
            cell.objectLabel.text = "\(self.jsonObj[indexPath.row]["NAME"].stringValue) / "
        }
        
        // Other Empty Check
        if (self.jsonObj[indexPath.row]["OTHER"]) == "" {
            cell.otherLabel.text = "N/A"
        } else {
            cell.otherLabel.text = "\(self.jsonObj[indexPath.row]["OTHER"].stringValue)"
        }
        
        // Distance Empty Check
        if (self.jsonObj[indexPath.row]["DISTLY"]) == "" {
            cell.magLabel.text = "N/A"
        } else {
            cell.magLabel.text = "Distance: \(self.jsonObj[indexPath.row]["DISTLY"].doubleValue) ly"
        }
        
        // Visual Magnitude Empty Check
        if (self.jsonObj[indexPath.row]["VMAG"]) == "" {
            cell.typeLabel.text = "N/A"
        } else {
            cell.typeLabel.text = "\(self.jsonObj[indexPath.row]["VMAG"].doubleValue) Mv"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        slctdObj = jsonObj[indexPath.row]
        slctdObjIndex = indexPath.row

        self.performSegue(withIdentifier: "gotoSegue", sender: self)
    }
    
}

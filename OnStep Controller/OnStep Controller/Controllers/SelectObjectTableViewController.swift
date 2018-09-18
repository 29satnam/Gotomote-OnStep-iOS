//
//  SelectObjectTableViewController
//  OnStep Controller
//
//  Created by Satnam on 8/28/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit
import SwiftyJSON


class SelectObjectTableViewController: UITableViewController {

    var jsonObj: JSON = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // navigationItem.title = "SELECT FIRST STAR"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func goBack(){
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
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
        self.performSegue(withIdentifier: "gotoSegue", sender: self)
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



}

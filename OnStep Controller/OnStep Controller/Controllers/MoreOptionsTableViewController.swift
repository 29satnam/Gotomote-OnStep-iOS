//
//  MoreOptionsTableViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/15/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

protocol PopViewDelegate: class {
    func passIdentifier(_ identifier: String)
}

class MoreOptionsTableViewController: UITableViewController {

    weak var delegate: PopViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
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

        return 8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == 0 {
            
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("tracking")
            }
        } else if indexPath.row == 1 {

            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("obsSite")
            }
        } else if indexPath.row == 2 {
            
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("gotomax")
            }
        } else if indexPath.row == 3 {
            
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("limits")
            }
        } else if indexPath.row == 4 {
            
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("backlash")
            }
        } else if indexPath.row == 5 {
            
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.passIdentifier("settings")
            }
        }
        
       
    }
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
 
*/
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

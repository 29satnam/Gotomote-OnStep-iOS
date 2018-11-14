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
    
    @IBOutlet var switchScreen: UISwitch!
    
    weak var delegate: PopViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //   $Q - PEC Control
        //  :$QZ+  Enable RA PEC compensation
        //         Returns: nothing
        //  :$QZ-  Disable RA PEC Compensation
        //         Returns: nothing
        //  :$QZZ  Clear the PEC data buffer
        //         Return: Nothing
        //  :$QZ/  Ready Record PEC
        //         Returns: nothing
        //  :$QZ!  Write PEC data to EEPROM
        //         Returns: nothing
        //  :$QZ?  Get PEC status
        //         Returns: S#
        
        tableView.tableFooterView = UIView()
        switchScreen.tintColor = .black
        switchScreen.onTintColor = .black

        if (UIApplication.shared.isIdleTimerDisabled == true) {
            switchScreen.isOn = true
        } else {
            switchScreen.isOn = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchScreenOff(_ sender: UISwitch) {
        if (sender.isOn == true){
            UIApplication.shared.isIdleTimerDisabled = true
        } else{
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return 7
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
}

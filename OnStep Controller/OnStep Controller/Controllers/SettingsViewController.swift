//
//  SettingsViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var ipAddTF: CustomTextField!
    @IBOutlet var portTF: CustomTextField!
    @IBOutlet var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtnProperties(button: uploadBtn)
        addTFProperties(tf: ipAddTF, placeholder: "192.168.1.1")
        addTFProperties(tf: portTF, placeholder: "9999")
        
        navigationItem.title = "BACKLASH"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class CustomTextField: UITextField {
    //Custom TF with Border configuration and font size
    var bottomBorder = UIView()
    
    override func awakeFromNib() {
        
        // Setup Bottom-Border\
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomBorder)
        
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true // Set Border-Strength
        
    }
}

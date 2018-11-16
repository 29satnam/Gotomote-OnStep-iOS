//
//  EnterCoordinatesViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/16/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit

class EnterCoordinatesViewController: UIViewController {

    @IBOutlet var raHH: CustomTextField!
    @IBOutlet var raMM: CustomTextField!
    @IBOutlet var raSS: CustomTextField!

    @IBOutlet var decDD: CustomTextField!
    @IBOutlet var decMM: CustomTextField!
    @IBOutlet var decSS: CustomTextField!
    
    @IBOutlet var acceptBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addBtnProperties(button: acceptBtn)
        
        addTFProperties(tf: raHH, placeholder: "HH")
        addTFProperties(tf: raMM, placeholder: "MM")
        addTFProperties(tf: raSS, placeholder: "SS")
        
        addTFProperties(tf: decDD, placeholder: "DD")
        addTFProperties(tf: decMM, placeholder: "MM")
        addTFProperties(tf: decSS, placeholder: "SS")
        
        navigationItem.title = "ENTER COORDINATES"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
      //  let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
      //  self.navigationItem.backBarButtonItem = item
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

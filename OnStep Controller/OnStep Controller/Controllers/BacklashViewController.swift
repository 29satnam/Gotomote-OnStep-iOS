//
//  BacklashViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class BacklashViewController: UIViewController {

    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet var backRaTF: CustomTextField!
    @IBOutlet var backDecTF: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: backRaTF, placeholder: " ")
        addTFProperties(tf: backDecTF, placeholder: " ")

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

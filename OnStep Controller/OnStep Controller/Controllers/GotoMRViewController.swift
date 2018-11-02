//
//  GotoMRViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/21/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class GotoMRViewController: UIViewController {
    // GOTO: Asked
    @IBOutlet var fastestBtn: UIButton!
    @IBOutlet var fasterBtn: UIButton!
    @IBOutlet var defaultBtn: UIButton!
    @IBOutlet var slowerBtn: UIButton!
    @IBOutlet var slowestBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addBtnProperties(button: fastestBtn)
        addBtnProperties(button: fasterBtn)
        addBtnProperties(button: defaultBtn)
        addBtnProperties(button: slowerBtn)
        addBtnProperties(button: slowestBtn)


        navigationItem.title = "GOTO MAX RATE"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  InitiaizeViewController.swift
//  OnStep Controller
//
//  Created by candy on 09/08/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class InitializeViewController: UIViewController {

    @IBOutlet var segmentControl: TTSegmentedControl!
    var alignTypeInit: Int = Int()
    
    @IBOutlet weak var setDateTimeBtn: UIButton!
    @IBOutlet weak var starAlignmentBtn: UIButton!
    @IBOutlet weak var atHomeBtn: UIButton!
    @IBOutlet weak var returnHomeBtn: UIButton!
    @IBOutlet weak var parkBtn: UIButton!
    @IBOutlet weak var unParkBtn: UIButton!
    @IBOutlet weak var setParkBtn: UIButton!
    
    @IBOutlet weak var dimmerBtn: UIButton!
    @IBOutlet weak var brighterBtn: UIButton!

    var delegate: TriggerConnectionDelegate?
    
    @objc func backBtn() {
        print("tapped")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        let bckBtn = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(backBtn))
        bckBtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.navigationItem.rightBarButtonItem = bckBtn
        
        navigationItem.title = "INITIALIZE/PARK"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        
        setupUserInterface()
    }

    
    // Start Alignment
    @IBAction func startAlignAct(_ sender: UIButton) {

         delegate?.triggerConnection(cmd: ":A1#")
        self.performSegue(withIdentifier: "toStartAlignTableView", sender: self)
    }
    
    // Mark: Set Date Time
    @IBAction func setDateTimeAct(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        delegate?.triggerConnection(cmd: ":SC\(Date().string(with: "MM/dd/yy"))#")
        delegate?.triggerConnection(cmd: ":SL\(dateFormatter.string(from: NSDate() as Date))#")
    }
    
    // Mark: Select a Start
    
    // At Home/Reset
    @IBAction func atHomeAct(_ sender: UIButton) {
        // :hC#
        delegate?.triggerConnection(cmd: ":hC#")
    }
    
    // Return Home
    @IBAction func returnHomeAct(_ sender: UIButton) {
        // :hF#
        delegate?.triggerConnection(cmd: ":hF#")
    }
    
    // Park
    @IBAction func parkAct(_ sender: UIButton) {
        // :hP#
        delegate?.triggerConnection(cmd: ":hP#")
    }
    
    // Un-Park
    @IBAction func unParkAct(_ sender: UIButton) {
        // :hR#
        delegate?.triggerConnection(cmd: ":hR#")
    }

    // Set-Park
    @IBAction func setParkAct(_ sender: UIButton) {
        // :hQ#
        delegate?.triggerConnection(cmd: ":hQ#")
    }
    
    // Mark: Reticule
    
    // Dimmer
    @IBAction func dimmerAct(_ sender: UIButton) {
        // :B-#
        delegate?.triggerConnection(cmd: ":B-#")
    }
    
    //Brighter
    @IBAction func BrighterAct(_ sender: UIButton) {
        // :B+#
        delegate?.triggerConnection(cmd: ":B+#")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    func setupUserInterface() {
        
        segmentControl.itemTitles = ["1 Star", "2 Star", "3 Star"]
        segmentControl.allowChangeThumbWidth = false
        segmentControl.selectedTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.selectedTextColor = UIColor.black
        segmentControl.defaultTextFont = UIFont(name: "SFUIDisplay-Medium", size: 14.0)!
        segmentControl.defaultTextColor = UIColor.white
        segmentControl.useGradient = false
        segmentControl.useShadow = false
        segmentControl.containerBackgroundColor = .clear
        segmentControl.thumbColor = (UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0))
        
        segmentControl.selectItemAt(index: 0, animated: true)
        alignTypeInit = 1
        segmentControl.didSelectItemWith = { index, title in
            print(index + 1)
            self.alignTypeInit = index + 1
        }
        
        addBtnProperties(button: setDateTimeBtn)
        
        addBtnProperties(button: starAlignmentBtn)
        starAlignmentBtn.backgroundColor = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        
        addBtnProperties(button: atHomeBtn)
        addBtnProperties(button: returnHomeBtn)
        addBtnProperties(button: parkBtn)
        addBtnProperties(button: unParkBtn)
        addBtnProperties(button: setParkBtn)
        
        addBtnProperties(button: dimmerBtn)
        addBtnProperties(button: brighterBtn)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let destination = segue.destination as? SelectStarTableViewController {
            print("Init:", alignTypeInit)
            destination.alignType = alignTypeInit
            destination.vcTitle = "FIRST STAR"
            destination.delegate = self.delegate
            
        }
    }
}


//
//  TrackingViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/20/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class TrackingViewController: UIViewController {
    
    @IBOutlet var trSiderBtn: UIButton!
    @IBOutlet var trLunarBtn: UIButton!
    @IBOutlet var trSolarBtn: UIButton!
    
    
    @IBOutlet var coFullBtn: UIButton!
    @IBOutlet var coReftBrn: UIButton!
    @IBOutlet var coDualAxBtn: UIButton!
    @IBOutlet var coSnglAxBtn: UIButton!
    @IBOutlet var coOffBtn: UIButton!
    
    
    @IBOutlet var raSlowerBtn: UIButton!
    @IBOutlet var raFasterBtn: UIButton!
    @IBOutlet var raResetBtn: UIButton!
    
    @IBOutlet var TrCoStopBtn: UIButton!
    @IBOutlet var TrCoStartBtn: UIButton!
    


    var delegate: TriggerConnectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBtnProperties(button: trSiderBtn)
        addBtnProperties(button: trLunarBtn)
        addBtnProperties(button: trSolarBtn)
        addBtnProperties(button: coFullBtn)
        addBtnProperties(button: coReftBrn)
        addBtnProperties(button: coDualAxBtn)
        addBtnProperties(button: coSnglAxBtn)
        addBtnProperties(button: coOffBtn)
        addBtnProperties(button: raSlowerBtn)
        addBtnProperties(button: raFasterBtn)
        addBtnProperties(button: raResetBtn)

        addBtnProperties(button: TrCoStopBtn)
        addBtnProperties(button: TrCoStartBtn)
        
        navigationItem.title = "OBS SITES"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        

    }
    //Mark - Tracking Rate
    
    // - Sidereal Rate
    @IBAction func sSiderealAct(_ sender: UIButton) {
        // :STdd.ddddd# // TODO
        delegate?.triggerConnection(cmd: ":TQ")
    }
    
    // - Lunar Rate
    @IBAction func sLunarAct(_ sender: UIButton) {
        // :TL#
        delegate?.triggerConnection(cmd: ":TL#")
    }
    
    // - Solar Rate
    @IBAction func sSolarrateAct(_ sender: UIButton) {
        // :TS#
        delegate?.triggerConnection(cmd: ":TS#")
    }
    
    //Mark - Compensated Tracking:
    
    // - Full
    @IBAction func cFullAct(_ sender: UIButton) {
        // TODO -- Confirm
        delegate?.triggerConnection(cmd: ":To#")
    }
    
    // - Refraction
    @IBAction func cReftAct(_ sender: UIButton) {
        //:Tr#
        delegate?.triggerConnection(cmd: ":Tr#")
    }
    
    // - Dual
    @IBAction func cDualAct(_ sender: UIButton) {
        // TODO
        delegate?.triggerConnection(cmd: "") // -------------
    }

    // - Single
    @IBAction func cSingleAct(_ sender: UIButton) {
        // TODO
        delegate?.triggerConnection(cmd: "") // --------------
    }
    
    // - Off
    @IBAction func cOffAct(_ sender: UIButton) {
        // TODO
        delegate?.triggerConnection(cmd: ":Tn#")
    }
    
    //Mark - Adjust Rate by 0.1Hz:
    
    // - Slower
    @IBAction func aSlowerAct(_ sender: UIButton) {
        // Track rate decrease 0.02Hz TODO - Run 5x
        delegate?.triggerConnection(cmd: ":T-#")
    }
    
    // - Faster
    @IBAction func aFasterAct(_ sender: UIButton) {
        // Track rate increase 0.02Hz TODO - Run 5x
        delegate?.triggerConnection(cmd: ":T+#")
    }
    
    // - Reset
    @IBAction func aRestAct(_ sender: UIButton) {
        // :TR#
        delegate?.triggerConnection(cmd: ":TR#")
    }
    
    // - Tracking Control
    @IBAction func tStopAct(_ sender: UIButton) {
        // :Te#
        delegate?.triggerConnection(cmd: ":Td#")
    }
    
    // - Start
    @IBAction func tStartAct(_ sender: UIButton) {
        // :Te#
        delegate?.triggerConnection(cmd: ":Te#")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, senderspo: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

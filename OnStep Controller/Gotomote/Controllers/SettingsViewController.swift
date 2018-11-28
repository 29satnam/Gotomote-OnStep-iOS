//
//  SettingsViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

let addressPort:UserDefaults = UserDefaults.standard

import UIKit
import NotificationBanner

class SettingsViewController: UIViewController {
    var banner = StatusBarNotificationBanner(title: "", style: .success)

    @IBOutlet var ipAddTF: CustomTextField!
    @IBOutlet var portTF: CustomTextField!
    @IBOutlet var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        banner.bannerHeight = banner.bannerHeight + 5
        
        addBtnProperties(button: uploadBtn)
        addTFProperties(tf: ipAddTF, placeholder: "192.168.0.1")
        addTFProperties(tf: portTF, placeholder: "9999")
        
        navigationItem.title = "CONNECTION"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        // Populate data
        if addressPort.value(forKey: "addressPort") as? String == nil {
            addressPort.set("192.168.0.1:9999", forKey: "addressPort")
            addressPort.synchronize()
        } else {
            let addrPort = (addressPort.value(forKey: "addressPort") as? String)?.components(separatedBy: ":")

            self.ipAddTF.text = addrPort![opt: 0]
            self.portTF.text = addrPort![opt: 1]
        }
        
    }
    
    @IBAction func saveAddress(_ sender: UIButton) {
        if !ipAddTF.text!.isEmpty && !portTF.text!.isEmpty {
            addressPort.set("\(ipAddTF.text!):\(portTF.text!)", forKey: "addressPort")
            addressPort.synchronize()
            banner = StatusBarNotificationBanner(title: "Address and port saved.", style: .success)
            banner.show()
        } else {
            print("address or port can't be empty.") // TODO
            banner = StatusBarNotificationBanner(title: "Address or port textfields can't be empty.", style: .danger)
            banner.show()
        }
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

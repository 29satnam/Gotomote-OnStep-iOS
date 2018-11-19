//
//  EnterCoordinatesViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/16/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit

class EnterCoordinatesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var raHH: CustomTextField!
    @IBOutlet var raMM: CustomTextField!
    @IBOutlet var raSS: CustomTextField!

    @IBOutlet var decDD: CustomTextField!
    @IBOutlet var decMM: CustomTextField!
    @IBOutlet var decSS: CustomTextField!
    
    @IBOutlet var acceptBtn: UIButton!
    
    var declination: String = String()
    var rightAscension: String = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        raHH.delegate = self
        raMM.delegate = self
        raSS.delegate = self
        decDD.delegate = self
        decMM.delegate = self
        decSS.delegate = self
        
        addBtnProperties(button: acceptBtn)
        
        addTFProperties(tf: raHH, placeholder: "HH") // 0
        addTFProperties(tf: raMM, placeholder: "MM") // 1
        addTFProperties(tf: raSS, placeholder: "[SS]") // 2
        addTFProperties(tf: decDD, placeholder: "[-]DD") // 3
        addTFProperties(tf: decMM, placeholder: "MM") // 4
        addTFProperties(tf: decSS, placeholder: "[SS]") // 5
        
        navigationItem.title = "ENTER COORDINATES"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        self.view.backgroundColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var check: Bool = Bool()
        var maxLength = 2
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 0 || textField.tag == 1 || textField.tag == 2 || textField.tag == 4 || textField.tag == 5 {
            
            if newString.length <= maxLength {
                // return true
                if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                    check = true
                } else {
                    check = false
                }
            }
            
        } else if textField.tag == 3 {
            maxLength = 3
            if newString.length <= maxLength {
                // return true
                if CharacterSet(charactersIn: "-0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                    check = true
                } else {
                    check = false
                }
            }
        }
        
        return check
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        
        if (raSS.text?.isEmpty)! {
            raSS.text = "00"
        }

        if (decSS.text?.isEmpty)! {
            decSS.text = "00"
        }
        
        if !raHH.text!.isEmpty && !raMM.text!.isEmpty && !raSS.text!.isEmpty && !decDD.text!.isEmpty && !decMM.text!.isEmpty && !decSS.text!.isEmpty {
            
            if !(00...23).contains(Int(raHH.text!)!) || !(00...59).contains(Int(raMM.text!)!) || !(00...59).contains(Int(raSS.text!)!) || !(-90...90).contains(Int(decDD.text!)!) || !(00...59).contains(Int(decMM.text!)!) || !(00...59).contains(Int(decSS.text!)!) {
                print("show error - Not in range") // Not in range TODO
            } else {
                if !(0...235959).contains(Int(raHH.text! + raMM.text! + raSS.text!)!) || !(-900000...900000).contains(Int(decDD.text! + decMM.text! + decSS.text!)!) {
                    print("show error - Not in range") // Not in range TODO
                } else {
                    print("do stuff")
                  //  print(String(format: "%03d:%02d:%02d", decDD as CVarArg, decMM, decSS))
                    
                    var declination = String(format: "%+02d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!) // init
                    var rightAscension = String(format: "%02d:%02d:%02d", Int(raHH.text!)!, Int(raMM.text!)!, Int(raSS.text!)!)
                    
                    // add positive sign
                    var y = (Int(raHH.text! + raMM.text! + raSS.text!)!)
                    if (y < 0) {
                     //   y! = 0 - y! // negative
                        declination = String(format: "%-03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    } else if (y == 0) {
                        declination = String(format: "%+03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    } else {
                        declination = String(format: "%+03d:%02d:%02d", Int(decDD.text!)!, Int(decMM.text!)!, Int(decSS.text!)!)
                    }
                    print("declination", declination, "rightAscension", rightAscension) 
                }
            }
        } else {
            print("show error - can't be empty") // TODO cant be empty
        }
    }
    
}

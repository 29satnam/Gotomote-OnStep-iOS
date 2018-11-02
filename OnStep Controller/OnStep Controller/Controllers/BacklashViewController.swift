//
//  BacklashViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import UIKit

class BacklashViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet var backRaTF: CustomTextField!
    @IBOutlet var backDecTF: CustomTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backRaTF.delegate = self
        backDecTF.delegate = self
        
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: backRaTF, placeholder: " ")
        addTFProperties(tf: backDecTF, placeholder: " ")

        navigationItem.title = "BACKLASH"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black

    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        
        if !backRaTF.text!.isEmpty || !backDecTF.text!.isEmpty {
            print("do stuff")
        } else {
            print("show error")
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var check: Bool = Bool()
        
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length <= maxLength {
           // return true
            if CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) == true {
                check = true
            } else {
                check = false
            }
        }
        
        return check
        
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

extension String {
    
    var containsValidCharacter: Bool {
        let characterSet = CharacterSet(charactersIn: "12345")
        let range = (self as NSString).rangeOfCharacter(from: characterSet)
        return range.location != NSNotFound
    }
}

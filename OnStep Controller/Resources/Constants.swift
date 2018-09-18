//
//  Constants.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import Foundation
import UIKit
import MathUtil
import SwiftyJSON

func addBtnProperties(button: UIButton) {
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor(white: 1, alpha: 0.25).cgColor //UIColor.white.cgColor
    button.layer.cornerRadius = 6
    button.backgroundColor = UIColor(white: 1, alpha: 0.03)
}

func addTFProperties(tf: UITextField, placeholder: String) {
    tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:[NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.25)])
    tf.textColor = .white
    tf.backgroundColor = .clear
}

// Mark: Get data outta json file
func grabJSONData(resource: String) -> JSON {
    var jsonData: JSON = JSON()
    if let path = Bundle.main.path(forResource: resource, ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            jsonData = try JSON(data: data)
        } catch let error {
            print("parse error: \(error.localizedDescription)")
        }
    } else {
        print("Invalid filename/path.")
    }
    return jsonData
}


let julianDayFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 5
    return formatter
}()

let coordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    return formatter
}()

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    formatter.timeZone = TimeZone(secondsFromGMT: 0)!
    return formatter
}()

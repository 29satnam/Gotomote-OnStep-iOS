//
//  ObjectListTableViewCellTwo.swift
//  OnStep Controller
//
//  Created by Satnam on 9/9/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit

class ObjectListTableViewCellTwo: UITableViewCell {
    
    @IBOutlet var objectLabel: UILabel! // objNum
    @IBOutlet var otherLabel: UILabel! // ABVR
    
    @IBOutlet var magLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var secName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

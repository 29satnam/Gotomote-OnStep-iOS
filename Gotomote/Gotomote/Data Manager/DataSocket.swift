//
//  DataSocket.swift
//  OnStep Controller
//
//  Created by Satnam on 7/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//

import Foundation

struct DataSocket {
    
    let ipAddress: String!
    let port: Int!
    
    init(ip: String, port: String){        
        self.ipAddress = ip
        self.port      = Int(port)
    }
}

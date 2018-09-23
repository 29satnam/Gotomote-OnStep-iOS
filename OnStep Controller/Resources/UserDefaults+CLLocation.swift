//
//  UserDefaults+CLLocation.swift
//
//
//  Created by John Spiropoulos on 28/09/16.
//  Copyright © 2016 John Spiropoulos. All rights reserved.
//

/*
Swift 3 Helper extension:
usage example:
Store: UserDefaults.standard.set(location:myLocation, forKey:"myLocation")
Retreive: UserDefaults.standard.location(forKey:"myLocation")
*/

import CoreLocation
import Foundation

extension UserDefaults {
    
    func set(location:CLLocation, forKey key: String){
        let locationLat = NSNumber(value:location.coordinate.latitude)
        let locationLon = NSNumber(value:location.coordinate.longitude)
        self.set(["lat": locationLat, "lon": locationLon], forKey:key)
    }
    
    func location(forKey key: String) -> CLLocation?
    { 
        if let locationDictionary = self.object(forKey: key) as? Dictionary<String,NSNumber> {
        	let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["lon"]!.doubleValue
            return CLLocation(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}

//
//  BacklashViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 8/22/18.
//  Copyright © 2018 Satnam Singh. All rights reserved.
//
import Foundation
import CoreLocation
import UIKit

struct CompletionBlocks {
    
    typealias ReturnBlock = (_ returnObject: AnyObject?, _ error: Error?) -> ()
}

class FetchLocation : NSObject {
    
    static let SharedManager = FetchLocation()
    
    //Step - 1: Initialize ClLocation Mananger
    var locationManager : CLLocationManager!
    
    //Step - 2: Declare Variables
    var parentObject : UIViewController?
    var userCurrentLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var completionBlock : CompletionBlocks.ReturnBlock?
    
    //Step - 3: Create functions for Location Manager
    private override init() {
        super.init()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
        } else {
            self.showPopIfLocationServiceIsDisable()
        }
    }
    
    func startUpdatingLocation() {
        DispatchQueue.main.async(execute: {
            self.locationManager.startUpdatingLocation()
        })
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.main.async(execute: {
            self.locationManager.stopUpdatingLocation()
        })
    }
    
    func showPopIfLocationServiceIsDisable() {
        
        let alert = UIAlertController(title: "Access to GPS is restricted", message: "GPS access is restricted. Draw path by location, please enable GPS in the Settings > Privacy > Location Services.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        guard let parentVC = parentObject else { return }
        parentVC.present(alert, animated: true)
        
    }
    
}

extension FetchLocation : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error.localizedDescription)
        guard let cB = self.completionBlock else { return }
        cB(nil, error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            
            let newCoordinate = manager.location!.coordinate
            
            if userCurrentLocation.latitude != newCoordinate.latitude && userCurrentLocation.longitude != newCoordinate.longitude {
                userCurrentLocation = manager.location!.coordinate
                guard let cB = self.completionBlock else { return }
                cB(userCurrentLocation as AnyObject, nil)
            }
            
            self.stopUpdatingLocation()
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            self.showPopIfLocationServiceIsDisable()
        case .authorizedWhenInUse:
            self.startUpdatingLocation()
        case .notDetermined:
            self.startUpdatingLocation()
        default:
            self.startUpdatingLocation()
        }
    }
    
}

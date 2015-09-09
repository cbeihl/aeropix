//
//  GpsHandler.swift
//  AeroPix
//
//  Created by Chris on 8/11/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import UIKit
import CoreLocation

class GpsHandler: NSObject, CLLocationManagerDelegate {
    
    var imagePicker : UIImagePickerController
    var distLabel: UILabel
    var gpsAccurLabel: UILabel
    var photosTakenLabel: UILabel
    var flightLog, picLog: FlightLogger
    
    var currentLoc:CLLocation? = nil
    var distSinceLastPhoto = 0.0
    var photosTaken: Int = 0
    var isRunning = false
    
    
    init(imagePicker: UIImagePickerController, distLabel: UILabel, gpsAccurLabel: UILabel, photosTakenLabel: UILabel, flightLog: FlightLogger, picLog: FlightLogger) {
        self.imagePicker = imagePicker
        self.distLabel = distLabel
        self.gpsAccurLabel = gpsAccurLabel
        self.photosTakenLabel = photosTakenLabel
        self.flightLog = flightLog
        self.picLog = picLog
    }
    
    func setRunning(isRunning: Bool) {
        self.isRunning = isRunning
    }
    
    func getCurrentLoc() -> CLLocation? {
        return self.currentLoc
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if (locations.count > 0) {
            let loc = locations[locations.count - 1] as! CLLocation
            if (isRunning) {
                println(loc)
                let commaStr = ","
                let locArray = [ loc.timestamp.description, loc.coordinate.latitude.description, loc.coordinate.longitude.description, loc.altitude.description, loc.horizontalAccuracy.description, loc.speed.description, loc.course.description ]
                let locStr = commaStr.join(locArray)
                println(locStr)
                flightLog.writeLog(locStr)
                
                if (currentLoc != nil) {
                    let dist = currentLoc?.distanceFromLocation(loc) as CLLocationDistance!
                    distSinceLastPhoto += dist
                }
                currentLoc = loc
                
                // update distance UI
                let distString = NSString(format: "%.1f", distSinceLastPhoto)
                distLabel.text = "\(distString)m"
                
                // check if distance to take photo has been reached
                println("distance since last photo - \(distSinceLastPhoto) meters")
                if (distSinceLastPhoto > 60) {
                    println("taking photo")
                    flightLog.writeLog("taking photo")
                    imagePicker.takePicture()
                    photosTaken++
                    photosTakenLabel.text = "\(photosTaken)"
                    let picLogStr = commaStr.join([ loc.timestamp.timeIntervalSince1970.description, photosTaken.description ])
                    println(picLogStr)
                    picLog.writeLog(picLogStr)
                    distSinceLastPhoto = 0.0
                }
            }
            
            // update gps UI
            let gpsAccurStr = NSString(format: "%.0f", loc.horizontalAccuracy)
            gpsAccurLabel.text = "~\(gpsAccurStr)m"
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location Manager Error : \(error)")
    }
    
    
}
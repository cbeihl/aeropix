//
//  ViewController.swift
//  AeroPix
//
//  Created by Chris on 7/27/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var cameraNotAvailLabel: UILabel!
    
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    
    let picker = UIImagePickerController()
    
    let locationMgr = CLLocationManager()
    var currentLoc:CLLocation? = nil
    var distSinceLastPhoto = 0.0
    var isRunning:Bool = false
    
    let flightLog = FlightLogger()
    
    // UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up UIImagePickerController
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.showsCameraControls = false
        } else {
            cameraNotAvailLabel.hidden = false
        }
        picker.mediaTypes = [ kUTTypeImage ]
        
        // set up location services
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            println("Requesting authorization to use location services ...")
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.startUpdatingLocation()
        } else {
            println("Location services authorized !")
            locationMgr.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4)
            self.cameraView.insertSubview(picker.view, atIndex: 0)
        }
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UIImagePickerController Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        println("Saving image to camera roll...")
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    //  Action Handlers
    
    @IBAction func greenButtonHandler(sender: UIButton) {
        redButton.hidden = false
        greenButton.hidden = true
        isRunning = true
    }
    
    @IBAction func redButtonHandler(sender: UIButton) {
        greenButton.hidden = false
        redButton.hidden = true
        isRunning = false
    }
    
    
    // CLLocationManager Delegates
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if (isRunning && locations.count > 0) {
            let loc = locations[locations.count - 1] as! CLLocation
            println(loc)
            flightLog.writeLog(loc.description)
            if (currentLoc != nil) {
                let dist = currentLoc?.distanceFromLocation(loc) as CLLocationDistance!
                distSinceLastPhoto += dist
            } else {
                currentLoc = loc
            }
            
            // check if distance to take photo has been reached
            println("distance since last photo - \(distSinceLastPhoto) meters")
            if (distSinceLastPhoto > 50) {
                println("taking photo")
                picker.takePicture()
                distSinceLastPhoto = 0.0
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location Manager Error : \(error)")
    }
    
}

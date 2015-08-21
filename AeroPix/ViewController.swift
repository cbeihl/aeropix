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
import CoreMotion

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    // Interface Builder Outlets
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var cameraNotAvailLabel: UILabel!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var gpsAccurLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var photosTakenLabel: UILabel!
    @IBOutlet weak var barometerLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    let locationMgr = CLLocationManager()
    let altimeter = CMAltimeter()
    
    let picker = UIImagePickerController()
    var gpsHandler: GpsHandler? = nil
    
    let gpsFlightLog = FlightLogger(filename: "flightlog_gps.txt", firstLine: "Timestamp,Latitude,Longitude,Accuracy,Speed (mps),Course (degrees)")
    let altFlightLog = FlightLogger(filename: "flightlog_alt.txt", firstLine: "Seconds,Relative Altitude (meters),Pressure (kPa)")
    
    let dateFormatter = NSDateFormatter()
    var startDate: NSDate? = nil
    var timerObj: NSTimer? = nil
    
    var isRunning:Bool = false
    
    
    // UIViewController Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set Up UIImagePickerController
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.showsCameraControls = false
        } else {
            cameraNotAvailLabel.hidden = false
        }
        picker.mediaTypes = [ kUTTypeImage ]
        
        // Set Up Location Services
        gpsHandler = GpsHandler(imagePicker: picker, distLabel: distanceLabel, gpsAccurLabel: gpsAccurLabel, photosTakenLabel: photosTakenLabel,  flightLog: gpsFlightLog)
        locationMgr.delegate = gpsHandler
        locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            println("Requesting authorization to use location services ...")
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.startUpdatingLocation()
        } else {
            println("Location services authorized !")
            locationMgr.startUpdatingLocation()
        }
        
        // Set Up Barometer
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (altData: CMAltitudeData!, error: NSError!) in
                let pressureStr = NSString(format: "%.1f", altData.relativeAltitude as Double)
                self?.barometerLabel.text = "\(pressureStr) m"
                if (self!.isRunning) {
                    println(altData)
                    self!.altFlightLog.writeLog(altData.description)
                }
            }
        } else {
            println("Altimeter is NOT available !")
        }
        
        // Timer setup
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            // make camera preview big enough to fill available space
            picker.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.6, 1.6)
            self.cameraView.insertSubview(picker.view, atIndex: 0)
        }
        
        // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
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
    
    
    // Timer Functions
    
    func startTimer() {
        if (timerObj == nil) {
            timerObj = NSTimer.scheduledTimerWithTimeInterval(1.0/10.0, target: self, selector: "timerHandler", userInfo: nil, repeats: true)
            startDate = NSDate()
        }
    }
    
    func stopTimer() {
        timerObj?.invalidate()
        timerObj = nil
    }
    
    func timerHandler() {
        let curDate = NSDate()
        let timeInterval = curDate.timeIntervalSinceDate(startDate!)
        let timerDate = NSDate(timeIntervalSince1970: timeInterval)
        let timeString = dateFormatter.stringFromDate(timerDate)
        timerLabel.text = timeString
    }
    
    //  Action Handlers
    
    @IBAction func greenButtonHandler(sender: UIButton) {
        redButton.hidden = false
        greenButton.hidden = true
        isRunning = true
        gpsHandler?.setRunning(isRunning)
        startTimer()
    }
    
    @IBAction func redButtonHandler(sender: UIButton) {
        greenButton.hidden = false
        redButton.hidden = true
        isRunning = false
        gpsHandler?.setRunning(isRunning)
        stopTimer()
    }
    
}

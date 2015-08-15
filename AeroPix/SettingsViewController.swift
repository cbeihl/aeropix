//
//  SettingsViewController.swift
//  AeroPix
//
//  Created by Chris on 8/12/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
    
    override func viewWillAppear(animated: Bool) {
        self.view.superview?.backgroundColor = UIColor.clearColor()
        super.viewWillAppear(animated)
    }
    
    @IBAction func doneBtnHandler(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

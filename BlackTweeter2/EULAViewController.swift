//
//  EULAViewController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 12/3/18.
//  Copyright © 2018 ZumbiilBen. All rights reserved.
//

import Foundation
import UIKit

class EULAViewController: UIViewController {
    
    
    
    @IBAction func Accept(_ sender: Any) {
        AppDelegate.eulaCompleted = true
        
        let btUserDefaults = UserDefaults.standard
        btUserDefaults.set(AppDelegate.eulaCompleted, forKey: "eulaCompleted")
        btUserDefaults.synchronize()
        print("eulaCompleted is now: : ", btUserDefaults.bool(forKey: "eulaCompleted"))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.buildNavigationDrawerInterface()
        
    }
    
    
    override func viewDidLoad() {
        //nothing yet
    }
}

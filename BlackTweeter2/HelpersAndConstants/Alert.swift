//
//  Alert.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 12/4/17.
//  Copyright © 2017 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit

protocol TweetAlert {
    func showAlert()
}

extension TweetAlert where Self: UIViewController {
    func showAlert() {
        let alert = UIAlertController(title: title, message: "message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "buttonTitle", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

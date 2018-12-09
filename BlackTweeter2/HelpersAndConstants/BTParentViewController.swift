//
//  BTParentViewController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 10/30/18.
//  Copyright © 2018 ZumbiilBen. All rights reserved.
//

import Foundation

import UIKit
import SwifteriOS

//https://stackoverflow.com/questions/30483104/presenting-uialertcontroller-from-uitableviewcell
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}

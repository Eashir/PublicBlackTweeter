//
//  RealToast.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 4/21/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
        func toastMessage(_ message: String){
            guard let window = UIApplication.shared.keyWindow else {return}
            let messageLbl = UILabel()
            messageLbl.text = message
            messageLbl.textAlignment = .center
            messageLbl.font = UIFont.boldSystemFont(ofSize: 14)
            messageLbl.textColor = UIColor(displayP3Red: 204/255, green: 249/255, blue: 240/255, alpha: 0.7)
            messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.8)
            
            let textSize:CGSize = messageLbl.intrinsicContentSize
            let labelWidth = min(textSize.width, window.frame.width - 40)
            
            messageLbl.frame = CGRect(x: 20, y: window.frame.height - 150, width: labelWidth + 30, height: textSize.height + 20)
            messageLbl.center.x = window.center.x
            messageLbl.layer.cornerRadius = messageLbl.frame.height/2
            messageLbl.layer.masksToBounds = true
            window.addSubview(messageLbl)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                UIView.animate(withDuration: 3, animations: {
                    messageLbl.alpha = 0
                }) { (_) in
                    messageLbl.removeFromSuperview()
                }
            }
        }
    }




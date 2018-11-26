//
//  TWTButton.swift
//  TB_TwitterHeader
//
//  Created by Yari D'areglia on 08/12/2016.

import UIKit

class TWTButton: UIButton {

    override func awakeFromNib() {
        
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(displayP3Red: 64/255, green: 42/255, blue: 21/255, alpha: 1).cgColor
      //  self.layer.borderColor = AppConstants.tweeterBrown as! CGColor
        
        
    }

}

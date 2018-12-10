//
//  CollectionVeiwCell.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 4/15/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var categoryPic: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryPic.layer.cornerRadius = 8.0
    }
    
}

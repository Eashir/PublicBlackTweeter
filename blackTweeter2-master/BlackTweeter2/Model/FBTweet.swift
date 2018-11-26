//
//  FBTweet.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 7/26/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation

struct FBTweet{
    var name: String?
    var order: Int?
    var tweetId: String?
    var status: LatestStatus?
    
    public mutating func setStatus (thisStatus: LatestStatus) {
        self.status = thisStatus
    }
    
    func getStatus() -> LatestStatus {
        return self.status!
    }
}

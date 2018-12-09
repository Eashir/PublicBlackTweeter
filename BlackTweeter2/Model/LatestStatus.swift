//
//  MyStatus.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 12/8/17.
//  Copyright © 2017 Ember Roar Studios. All rights reserved.
//

import Foundation
struct LatestStatus {
    var userId: String?
    var textTweet: String?
    var profileImageUrl: String?
    
    var gifImageViewUrl: String?
    var regularUrl: String?
    var hasGif: Bool?
    var statusImageUrl0: String?
    var statusImageUrl1: String?
    var statusImageUrl2: String?
    var statusImageUrl3: String?
   
    var textFullName: String?
    var textUsername: String?
    var likeCount: String?
    var retweetCount: String?
    var tweetId: String?
    var didFavorite: Bool?
    var didRetweet: Bool?
    var timeStamp: String?
    
    var retweetedBy: String?
    var isARetweet: Bool = false
    var isAQuote: Bool = false
    var RTUsername: String?
    var RTFullName: String?
    var RTText: String?
    var RTgifString: String?
    var RTmediaString0: String?
    var RTmediaString1: String?
    var RTmediaString2: String?
    var RTmediaString3: String?
}

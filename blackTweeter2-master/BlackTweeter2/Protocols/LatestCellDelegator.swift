//
//  LatestCellDelegator.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 3/20/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation

protocol LatestCellDelegator {
    func goToProfilePage(userID dataobjectUID: String, profileImage dataProfileImage: UIImageView)
    func goToProfNaked(userId dataobjectUID: String)
    func goReplyToTweet(tweetID dataTweetID: String)
    func goQuoteTweet(tweetText dataTweetText: String, username dataUsername: String)
}

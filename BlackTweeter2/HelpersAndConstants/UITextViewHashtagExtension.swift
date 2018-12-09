//
//  UITextViewHashtagExtension.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 3/11/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation

import UIKit

//https://stackoverflow.com/questions/37582299/how-to-make-uitextview-hashtag-link-open-another-viewcontroller
//also try     //THIRD ANSWER (NOT WORKING YET)
//https://stackoverflow.com/questions/34294064/how-to-make-uitextview-detect-hashtags
extension UITextView {
    
//    func resolveHashTags(){
//
//        // turn string in to NSString
//        let nsText:NSString = self.text as! NSString
//
//        // this needs to be an array of NSString.  String does not work.
//        let words:[NSString] = nsText.components(separatedBy: " ") as [NSString]
//
//        // you can't set the font size in the storyboard anymore, since it gets overridden here.
//        let attrs = [
//            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0)
//        ]
//
//        // you can staple URLs onto attributed strings
//        let attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
//
//        // tag each word if it has a hashtag
//        for word in words {
//
//            // found a word that is prepended by a hashtag!
//            // homework for you: implement @mentions here too.
//            if word.hasPrefix("#") {
//
//                // a range is the character position, followed by how many characters are in the word.
//                // we need this because we staple the "href" to this range.
//                let matchRange:NSRange = nsText.range(of: word as String)
//
//                // convert the word from NSString to String
//                // this allows us to call "dropFirst" to remove the hashtag
//                var stringifiedWord:String = word as String
//
//                // drop the hashtag
//                stringifiedWord = String(stringifiedWord.characters.dropFirst())
//
//
//                // check to see if the hashtag has numbers.
//                // ribl is "#1" shouldn't be considered a hashtag.
//                let digits = NSCharacterSet.decimalDigits
//
//                if let numbersExist = stringifiedWord.rangeOfCharacter(from: digits) {
//                    // hashtag contains a number, like "#1"
//                    // so don't make it clickable
//                } else {
//                    // set a link for when the user clicks on this word.
//                    // it's not enough to use the word "hash", but you need the url scheme syntax "hash://"
//                    // note:  since it's a URL now, the color is set to the project's tint color
//                    attrString.addAttribute(NSAttributedStringKey.link, value: "hash:\(stringifiedWord)", range: matchRange)
//                    print("\(stringifiedWord) is a hashtag")
//                }
//
//            }
//        }
//
//        // we're used to textView.text
//        // but here we use textView.attributedText
//        // again, this will also wipe out any fonts and colors from the storyboard,
//        // so remember to re-add them in the attrs dictionary above
//        self.attributedText = attrString
//    }
}

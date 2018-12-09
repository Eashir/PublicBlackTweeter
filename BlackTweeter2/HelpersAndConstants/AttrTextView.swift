//
//  AttrTextView.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 3/13/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit

//https://medium.com/@eliothan/clickable-hashtags-and-mentions-in-swift-3-0-c627c7d3dd9d
enum wordType{
    case hashtag
    case mention
    case plain
}

//A custom text view that allows hashtags and @ symbols to be separated from the rest of the text and triggers actions upon selection
class AttrTextView: UITextView {
    var textString: NSString?
    var attrString: NSMutableAttributedString?
    var callBack: ((String, wordType, String) -> Void)?
    var thisTweetId: String?
    var thisUsername: String?
    
    
    public func setText(text: String, withHashtagColor hashtagColor: UIColor, andMentionColor mentionColor: UIColor, andCallBack callBack: @escaping (String, wordType, String) -> Void, normalFont: UIFont, hashTagFont: UIFont, mentionFont: UIFont) {
        self.callBack = callBack
        self.attrString = NSMutableAttributedString(string: text)
        self.textString = NSString(string: text)
        
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedStringKey.font, value: normalFont, range: NSRange(location: 0, length: (textString?.length)!))
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: (textString?.length)!))
        
        // Call a custom set Hashtag and Mention Attributes Function
        setAttrWithName(attrName: "Hashtag", wordPrefix: "#", color: hashtagColor, text: text, font: hashTagFont)
        setAttrWithName(attrName: "Mention", wordPrefix: "@", color: mentionColor, text: text, font: mentionFont)
        //setAttrWithName(attrName: "Plain", color: UIColor.black, text: text, font: mentionFont)
        
        // Add tap gesture that calls a function tapRecognized when tapped
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(tapGesture:)))
        addGestureRecognizer(tapper)
    }
    
    public func setText(status: LatestStatus, withHashtagColor hashtagColor: UIColor, andMentionColor mentionColor: UIColor, andCallBack callBack: @escaping (String, wordType, String) -> Void, normalFont: UIFont, hashTagFont: UIFont, mentionFont: UIFont) {
        self.callBack = callBack
        self.attrString = NSMutableAttributedString(string: status.textTweet!)
        self.textString = NSString(string: status.textTweet!)
        self.thisTweetId = status.tweetId
        self.thisUsername = status.textUsername
        
        // Set initial font attributes for our string
        attrString?.addAttribute(NSAttributedStringKey.font, value: normalFont, range: NSRange(location: 0, length: (textString?.length)!))
        attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: (textString?.length)!))
        
        // Call a custom set Hashtag and Mention Attributes Function
        setAttrWithName(attrName: "Hashtag", wordPrefix: "#", color: hashtagColor, text: status.textTweet!, font: hashTagFont)
        setAttrWithName(attrName: "Mention", wordPrefix: "@", color: mentionColor, text: status.textTweet!, font: mentionFont)
        //setAttrWithName(attrName: "Plain", color: UIColor.black, text: text, font: mentionFont)
        
        // Add tap gesture that calls a function tapRecognized when tapped
        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized(tapGesture:)))
        addGestureRecognizer(tapper)
    }
    
    
    
    private func setAttrWithName(attrName: String, wordPrefix: String, color: UIColor, text: String, font: UIFont) {
        //Words can be separated by either a space or a line break
        let charSet = CharacterSet(charactersIn: " \n")
        let words = text.components(separatedBy: charSet)
        
        //Filter to check for the # or @ prefix
        for word in words.filter({$0.hasPrefix(wordPrefix)}) {
            let range = textString!.range(of: word)
            attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
            attrString?.addAttribute(NSAttributedStringKey(rawValue: attrName), value: 1, range: range)
            attrString?.addAttribute(NSAttributedStringKey(rawValue: "Clickable"), value: 1, range: range)
            attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        }
        self.attributedText = attrString
    }
    
    private func setAttrWithName(attrName: String, color: UIColor, text: String, font: UIFont) {
        //Words can be separated by either a space or a line break
        let charSet = CharacterSet(charactersIn: " \n")
        let words = text.components(separatedBy: charSet)
        
        //Filter to check for the # or @ prefix
        for word in words {
            let range = textString!.range(of: word)
            attrString?.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
            attrString?.addAttribute(NSAttributedStringKey(rawValue: attrName), value: 1, range: range)
            attrString?.addAttribute(NSAttributedStringKey(rawValue: "Clickable"), value: 1, range: range)
            attrString?.addAttribute(NSAttributedStringKey.font, value: font, range: range)
        }
        self.attributedText = attrString
    }
    
    
    
    @objc func tapRecognized(tapGesture: UITapGestureRecognizer) {
        var wordString: String?         // The String value of the word to pass into callback function
        var char: NSAttributedString!   //The character the user clicks on. It is non optional because if the user clicks on nothing, char will be a space or " "
        var word: NSAttributedString?   //The word the user clicks on
        var isHashtag: AnyObject?
        var isAtMention: AnyObject?
        
        // Gets the range of the character at the place the user taps
        let point = tapGesture.location(in: self)
        let charPosition = closestPosition(to: point)
        let charRange = tokenizer.rangeEnclosingPosition(charPosition!, with: .character, inDirection: 1)
        
        //Checks if the user has tapped on a character.
        if charRange != nil {
            let location = offset(from: beginningOfDocument, to: charRange!.start)
            let length = offset(from: charRange!.start, to: charRange!.end)
            let attrRange = NSMakeRange(location, length)
            char = attributedText.attributedSubstring(from: attrRange)
            
            //If the user has not clicked on anything, exit the function
            if char.string == " "{
                print("User clicked on nothing")
                return
            }
            
            // Checks the character's attribute, if any
            isHashtag = char?.attribute(NSAttributedStringKey(rawValue: "Hashtag"), at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, char!.length)) as AnyObject?
            isAtMention = char?.attribute(NSAttributedStringKey(rawValue: "Mention"), at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, char!.length)) as AnyObject?
        }
        
        // Gets the range of the word at the place user taps
        let wordRange = tokenizer.rangeEnclosingPosition(charPosition!, with: .word, inDirection: 1)
        
        /*
         Check if wordRange is nil or not. The wordRange is nil if:
         1. The User clicks on the "#" or "@"
         2. The User has not clicked on anything. We already checked whether or not the user clicks on nothing so 1 is the only possibility
         */
        if wordRange != nil{
            // Get the word. This will not work if the char is "#" or "@" ie, if the user clicked on the # or @ in front of the word
            let wordLocation = offset(from: beginningOfDocument, to: wordRange!.start)
            let wordLength = offset(from: wordRange!.start, to: wordRange!.end)
            let wordAttrRange = NSMakeRange(wordLocation, wordLength)
            word = attributedText.attributedSubstring(from: wordAttrRange)
            wordString = word!.string
        }else{
            /*
             Because the user has clicked on the @ or # in front of the word, word will be nil as
             tokenizer.rangeEnclosingPosition(charPosition!, with: .word, inDirection: 1) does not work with special characters.
             What I am doing here is modifying the x position of the point the user taps the screen. Moving it to the right by about 12 points will move the point where we want to detect for a word, ie to the right of the # or @ symbol and onto the word's text
             */
            var modifiedPoint = point
            modifiedPoint.x += 12
            let modifiedPosition = closestPosition(to: modifiedPoint)
            let modifedWordRange = tokenizer.rangeEnclosingPosition(modifiedPosition!, with: .word, inDirection: 1)
            if modifedWordRange != nil{
                let wordLocation = offset(from: beginningOfDocument, to: modifedWordRange!.start)
                let wordLength = offset(from: modifedWordRange!.start, to: modifedWordRange!.end)
                let wordAttrRange = NSMakeRange(wordLocation, wordLength)
                word = attributedText.attributedSubstring(from: wordAttrRange)
                wordString = word!.string
            }
        }
        
        if let stringToPass = wordString{
            // Runs callback function if word is a Hashtag or Mention
            if isHashtag != nil && callBack != nil {
                callBack!(stringToPass, wordType.hashtag, "")
            } else if isAtMention != nil && callBack != nil {
                callBack!(stringToPass, wordType.mention, self.thisUsername!)
            }else {
                callBack!(stringToPass, wordType.plain, self.thisTweetId!)
            }
        }
    }
    
    
}

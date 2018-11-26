//
//  WriteViewController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 11/16/17.
//  Copyright © 2017 Ember Roar Studios. All rights reserved.
//

import Foundation
import SwifteriOS
import UIKit
import Locksmith

//this is what we are doing
//https://www.youtube.com/watch?v=ht-iPdQ6PsY
//how to do check box https://www.youtube.com/watch?v=juMWo5wniKg
class WriteViewController: BaseViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BEMCheckBoxDelegate {
    
    var swifter: Swifter?
    let TWITTER_CONSUMER_KEY = UserDefaults.standard.object(forKey: "twitterConsumerKey")
    let TWITTER_CONSUMER_SECRET_KEY = UserDefaults.standard.object(forKey: "twitterConsumerSecretKey")
    let CALLBACK_URL = "http://www.google.com"
    var tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    var tweetMedia: [String: Any]?
    public var tweetID: String?
    public var initTweetText: String?
    public var initUsername: String?
    var replyUsername: String?
    // @IBOutlet weak var isSwitched: UISwitch!
    @IBOutlet weak var numberOfChar: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    // @IBOutlet weak var rtImage: UIImageView!
    @IBOutlet weak var sendTweetButton: UIBarButtonItem!
    @IBOutlet weak var postTweetButton: UIButton!
    @IBOutlet weak var inReplyLabel: UILabel!
    
    @IBOutlet weak var sarcasmCheckbox: BEMCheckBox!
    
    //    @IBAction func picSwitcher(_ sender: Any) {
    //        if isSwitched.isOn  {
    //            rtImage.alpha = 1
    //        }else{
    //            rtImage.alpha = 0
    //        }
    //    }
    
    @IBAction func nevermindButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func postTweet(_ sender: Any) {
        // https://www.appcoda.com/custom-view-controller-transitions-tutorial/
        // https://stackoverflow.com/questions/38799143/dismiss-view-controller-with-custom-animation
        //https://stackoverflow.com/questions/25900227/change-dismissviewcontrolleranimateds-animation
        //add placeholder to textView https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
        tweetButtonClicked()
    }
    
    @IBAction func sendTweet(_ sender: Any) {
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo", message: "What you wanna do?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Snap a Pic", style: .default, handler: {(action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Ummm...Your Camera's not Working")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose a Pic", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil
        ))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        print("selecting pic")
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let failureHandler: (Error) -> Void = { error in
            print("😕 Couldn't post tweet  because: \(error.localizedDescription)")
        }
        //this is the data
        print("this is the raw data", info)
        tweetMedia = info// member variable to check if tweet has media
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String ) -> Bool
    {
        let newLength: Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar:Int = 280 - newLength
        
        numberOfChar.text = "\(remainingChar)"
        if remainingChar < 14 {
            //numberOfChar.text = "0"
            numberOfChar.textColor = UIColor.red
        } else {
            numberOfChar.textColor = AppConstants.tweeterBrown //UIColor.black 
            numberOfChar.text = "\(remainingChar)"
        }
        return (newLength) > 280 ? false : true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sarcasmCheckbox.delegate = self
        
        
        self.swifter = Swifter(consumerKey: self.TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: tokenDictionary!["accessTokenKey"] as! String, oauthTokenSecret: tokenDictionary!["accessTokenSecret"] as! String)
        
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with you network 😕.")
        }
        //self.tweetID is used to determine if this was a reply or not (not a quote)
        if ((tweetID) != nil){
            print("tweetid is not nil ", tweetID!)
            inReplyLabel.isHidden = false
            self.swifter?.getTweet(for: tweetID!, trimUser: false, includeMyRetweet: false, includeEntities: true, includeExtAltText: false, tweetMode: TweetMode.default, success:{ json in
                
                if let screenName = json["user"]["screen_name"].string {
                    // mainScreenName.text = "@\(screenName)"
                    self.inReplyLabel.text?.append(screenName)
                    self.replyUsername = screenName
                    print("THE SCREEN NAME IS: ", screenName)
                }
                //print (json)
            },failure: failureHandler)
        }
        // tweetTextView.text = "This me saying something really really sarcastic haha 😜"
        if ((initTweetText != nil) && (initUsername != nil)){
            tweetTextView.text = "'@" + initUsername! + " " + initTweetText! + "\n - RT'd using #BlackTweeterApp -'"
            self.numberOfChar.text = String(280-tweetTextView.text.count)
        }else if (initUsername != nil){
            tweetTextView.text = initUsername
        }else {
            tweetTextView.text = ""
        }
        
        tweetTextView.contentInsetAdjustmentBehavior = .automatic
        tweetTextView.becomeFirstResponder()
        tweetTextView.isUserInteractionEnabled = true
        tweetTextView.layer.cornerRadius = 5
        tweetTextView.layer.borderWidth = 1
        tweetTextView.delegate = self
        tweetTextView.layer.borderColor = UIColor.brown.cgColor
        //        isSwitched.setOn(false, animated: false)
        //        rtImage.alpha = 0
        
        
    }
    
    
    func randomizTextview(textview: UITextView) {
        let result = textview.text.characters.map {
            if arc4random_uniform(2) == 0 {
                return String($0).lowercased()
            }
            return String($0).uppercased()
            }.joined(separator: "")
        textview.text = result
    }
    
    func tweetButtonClicked () {
        let failureHandler: (Error) -> Void = { error in
            print("😕 Couldn't post tweet  because: \(error.localizedDescription)")
        }
        
        
        var tweetText: String!
        if let text: String = tweetTextView.text {
            if (text.count < 1) {
                alert(title: "Are you serious rn?", message: "Yea, so Imma need you to put some valid text in the tweet. Thanks.")
            }else if (text.count > 280) {
                alert(title: "Naw", message: "Thant's wayyy too many characters, shorten that for me Slim.")
            }
            tweetText = text
        }else{
            alert(title: "Dang", message: "There was problem posting that tweet smh")
        }
        //this is media less tweet (inReplyToStatusID:String works btw)
        
        
        if (tweetMedia == nil){
            print("this is the status id: ", self.tweetID)
            //let statusID = self.tweetID!
            //how to dismiss after tweet is sent https://stackoverflow.com/questions/35807334/how-to-dismiss-a-uiviewcontroller-from-a-uialertcontrollers-uialertaction-handl
            //self.tweetID is used to determine if this was a reply or not (not a quote)
            if (self.tweetID != nil){
                tweetText = "@\(self.replyUsername!) " + tweetText
            }
            self.swifter?.postTweet(status: tweetText, inReplyToStatusID: self.tweetID, trimUser: false, tweetMode: TweetMode.extended, success: { json in
                print(json)
                self.tweetTextView.text = ""
                self.numberOfChar.text = "280"
                self.alert(title: "Tweet sent", message: "👍🏾")
            }, failure: failureHandler)
        }else{
            let picForTwitterApi = tweetMedia![UIImagePickerControllerOriginalImage] as! UIImage
            let image = UIImagePNGRepresentation(picForTwitterApi) as Data?
            
            
            self.swifter?.postMedia(image!, additionalOwners: nil, success: { json in
                let mediaIdString = json["media_id_string"].string
                print("ben mediaIdString: ", mediaIdString!)
                print(json)
                //self.tweetID is used to determine if this was a reply or not (not a quote)
                if (self.tweetID != nil){
                    tweetText = "@\(self.replyUsername!) " + tweetText
                }
                
                self.swifter?.postTweet(status: tweetText, inReplyToStatusID: self.tweetID, coordinate: nil, placeID: nil, displayCoordinates: false, trimUser: false, mediaIDs: [mediaIdString!], attachmentURL: nil, tweetMode: TweetMode.default, success: { json in
                    print(json)
                    self.alert(title: "Tweet PHOTO sent", message: "👍🏾")
                }, failure: failureHandler)
                
            }, failure: failureHandler)
        }
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if (tweetTextView.text.count > 0){
            print("did tap checkbox ", checkBox.tag, " and is on? ", checkBox.on)
            if(checkBox.on){
                randomizTextview(textview: tweetTextView)
            }else{
                tweetTextView.text = tweetTextView.text.lowercased()
            }
        }
    }
    
    //how to dismiss after tweet is sent https://stackoverflow.com/questions/35807334/how-to-dismiss-a-uiviewcontroller-from-a-uialertcontrollers-uialertaction-handl
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aight", style: .default, handler:{ action in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}

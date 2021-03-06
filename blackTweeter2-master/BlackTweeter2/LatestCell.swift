//
//  LatestCell.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 12/7/17.
//  Copyright © 2017 Ember Roar Studios. All rights reserved.
//

import UIKit
import SwifteriOS
import SDWebImage
import AVKit
import AVFoundation
import Kingfisher
import Locksmith
import CollieGallery
import SwiftLinkPreview
import ImageSlideshow
protocol CustomCellUpdater: class { // the name of the protocol you can put any
    func updateTableView()
}

class LatestCell: UITableViewCell {
    
    var delegate: LatestCellDelegator!
    weak var customCelldelegate: CustomCellUpdater?
    //https://github.com/gmunhoz/CollieGallery
    var collieDelegate: CollieGalleryDelegate!
    
    @IBOutlet weak var adBar: UILabel!
    
    @IBOutlet weak var cellLatestTweet: AttrTextView!
    @IBOutlet weak var cellFullName: UILabel!
    @IBOutlet weak var RetweetedByLabel: UILabel!
    @IBOutlet weak var cellUsername: UILabel!
    @IBOutlet weak var cellTimestamp: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var AllPicsStackView: UIStackView!
//    @IBOutlet weak var SecondPicImageView: UIImageView!
    @IBOutlet weak var ThreeAndFourStackView: UIStackView!
//    @IBOutlet weak var FourthImageView: UIImageView!
    @IBOutlet weak var gifStackView: UIStackView!
    
    @IBOutlet fileprivate weak var statusImage0: UIImageView!
    @IBOutlet weak var statusImage1: UIImageView!
    @IBOutlet weak var statusImage2: UIImageView!
    @IBOutlet weak var statusImage3: UIImageView!
    @IBOutlet weak var getGifButton: UIButton?
    
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var quoteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var fullBackground: UIView!
    @IBOutlet weak var videoPlayerSuperview: UIView!
    @IBOutlet weak var RTplayIcon: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    
    @IBOutlet weak var regularUrlDescStack: UIStackView!
    //@IBOutlet private weak var textField: UITextField?
    //@IBOutlet private weak var randomTextButton: UIButton?
    //@IBOutlet private weak var submitButton: UIButton?
    //@IBOutlet private weak var favicon: UIImageView?
    //@IBOutlet private weak var detailedView: UIView?
    @IBOutlet private weak var slideshow: ImageSlideshow?
    @IBOutlet private weak var centerLoadingActivityIndicatorView: UIActivityIndicatorView?
    @IBOutlet private weak var openWithButton: UIButton?
    @IBOutlet private weak var indicator: UIActivityIndicatorView?
    @IBOutlet private weak var previewArea: UIView?
    @IBOutlet private weak var previewAreaLabel: UILabel?
    @IBOutlet private weak var previewTitle: AttrTextView?
    @IBOutlet private weak var previewCanonicalUrl: AttrTextView?
    @IBOutlet private weak var previewDescription: AttrTextView?
    private let placeholderImages = [ImageSource(image: UIImage(named: "default_profile_")!)]
    
    @IBOutlet weak var RTStackView: UIStackView!
    @IBOutlet weak var RTFullName: UILabel!
    @IBOutlet weak var RTUsername: UILabel!
    @IBOutlet weak var RTText: AttrTextView!
    @IBOutlet weak var RTAllPicsStackView: UIStackView!
    @IBOutlet weak var RTVideoSuperView: UIView!
    
    @IBOutlet fileprivate weak var RTstatusImage0: UIImageView!
    @IBOutlet weak var RTstatusImage1: UIImageView!
    @IBOutlet weak var RTstatusImage2: UIImageView!
    @IBOutlet weak var RTstatusImage3: UIImageView!
    @IBOutlet weak var RTThreeAndFourStackView: UIStackView!
    
    
    var imageLoader: ImageCacheLoader?
    var myId: String?
    var printTweetId: String?
    var printUserId: String?
    var printTweetText: String?
    var printUsername: String?
    let TWITTER_CONSUMER_KEY = UserDefaults.standard.object(forKey: "twitterConsumerKey")
    let TWITTER_CONSUMER_SECRET_KEY = UserDefaults.standard.object(forKey: "twitterConsumerSecretKey")
    let OAUTH_TOKEN = "928135071521017856-7w0pKnkd6Z3fsCkIjwpjZFlSzD1RkDL" //GET_YOUR_OWN_KEY
    let OAUTH_TOKEN_SECRET = "RUViQbwNK1o2IThlJe4LyK3AWo6mwIdGp7fJje5M9l9z6"//GET_YOUR_OWN_KEY
    let CALLBACK_URL = "http://www.google.com"
    let profileJpgString: String = "_bigger.jpg"
    var swifter: Swifter?
    var likeOutside: Bool?
    var retweetOutside: Bool?
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    
    var RTavPlayer: AVPlayer?
    var RTavPlayerLayer: AVPlayerLayer?
    var RTpaused: Bool = false
    
    var pictures = [CollieGalleryPicture]()
    var style = ToastStyle()
    
    let tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    
    //let slp = SwiftLinkPreview.init()
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    private var result = SwiftLinkPreview.Response()
    
    
    @IBAction func likeAction(_ sender: UIButton) {
        print("like button clicked")
        like(sender: sender)
    }
    @IBAction func retweetAction(_ sender: UIButton) {
        print("retweet button clicked")
        retweet(sender: sender)
    }
    @IBAction func replyAction(_ sender: Any) {
        print("reply button clicked")
        reply()
    }
    
    @IBAction func quoteAction(_ sender: Any) {
        print("quote button clicked")
        quote()  
    }
    
    @IBAction func getGifAction(_ sender: Any) {
        copyGif(gifUrl: (latestStatus?.gifImageViewUrl)!)
    }
    
    @IBAction func trashAction(_ sender: Any) {
        // reloadTalbeveiwInsideOfCell()
        deleteTweet()
    }
    
    
    //THIS IS HOW WE SET THE VIDEO IN THE VIEW: youre going to have to do alot more look here: https://stackoverflow.com/questions/33702490/embedding-videos-in-a-tableview-cell
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    var RTvideoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            RTavPlayer?.replaceCurrentItem(with: self.RTvideoPlayerItem)
        }
    }
    
    var latestStatus: LatestStatus? {
        didSet {
            getGifButton?.backgroundColor = .clear
            getGifButton?.layer.cornerRadius = 10
            getGifButton?.layer.borderWidth = 1
            getGifButton?.layer.borderColor = AppConstants.tweeterBrown.cgColor 
            
            //self.getGifButton?.isHidden = false
            RetweetedByLabel.isHidden = true
            RTStackView.isHidden = false
            self.adBar.isHidden = true // has to be set as hidden for every single cell individually
            videoPlayerSuperview.isHidden = true
            RTVideoSuperView.isHidden = true

            slideshow?.isHidden = true
            regularUrlDescStack.isHidden = true
            
            AllPicsStackView.isHidden = false
            statusImage1.isHidden = false
            ThreeAndFourStackView.isHidden = false
            statusImage3.isHidden = false
            gifStackView.isHidden = false
            trashButton.isHidden = true
            likeOutside = latestStatus?.didFavorite
            retweetOutside = latestStatus?.didRetweet
            
            RTAllPicsStackView.isHidden = false
            RTstatusImage1.isHidden = false
            RTThreeAndFourStackView.isHidden = false
            RTstatusImage3.isHidden = false
            
            if (latestStatus?.didFavorite == true){
                likeButton.setImage(UIImage(named: "icon-heart-teal"), for: .normal)
                likeButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
                likeButton.alpha = 1.0
            }else {
                likeButton.setImage(UIImage(named: "icon-heart"), for: .normal)
                likeButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
                likeButton.alpha = 0.5
            }
            
            if (latestStatus?.didRetweet == true){
                retweetButton.setImage(UIImage(named: "icon-retweet-teal"), for: .normal)
                retweetButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
                retweetButton.alpha = 1.0
            }else {
                retweetButton.setImage(UIImage(named: "icon-retweet"), for: .normal)
                retweetButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
                retweetButton.alpha = 0.5
            }
            
            if (tokenDictionary != nil ){
                if (tokenDictionary!["realUserId"] as! String != nil){
                    myId = tokenDictionary!["realUserId"] as? String
                }
            } else {
                alert(title: "Ummmmm", message: "Go head and Log in for me" , uivc: parentViewController!)
            }
            
            
            if (myId == latestStatus?.userId as! String){
                self.trashButton.isHidden = false
            }
            
            if let fullName = latestStatus?.textFullName{
                self.cellFullName.text = fullName
            }
            
            if let retweetedBy = latestStatus?.retweetedBy{
                RetweetedByLabel.isHidden = false
                self.RetweetedByLabel.text = "Retweeted By: \(retweetedBy)"
            }
            
            if let userName = latestStatus?.textUsername {
                self.cellUsername.text = "@\(userName)"
            }
            
            if let timestamp = latestStatus?.timeStamp {
                self.cellTimestamp.text = timestamp
            }
            
            
            if let profileImageUrl = latestStatus?.profileImageUrl {
                profileImageView.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "default_profile_.png"))
                profileImageView.layer.cornerRadius = 10.0
                profileImageView.clipsToBounds = true
            }
            
            if let rtFullName = latestStatus?.RTFullName{
                self.RTFullName.text = rtFullName
            }
            if let rtUsername = latestStatus?.RTUsername{
                self.RTUsername.text = "@\(rtUsername)"
            }
            if var rtTextString = latestStatus?.RTText{
                self.RTText.text = rtTextString
            }
            
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profPicClick(tapGestureRecognizer:)))
            
            profileImageView?.isUserInteractionEnabled = true
            profileImageView?.addGestureRecognizer(tapGestureRecognizer)
            
            let tapFullNameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profPicClick(tapFullNameGestureRecognizer:)))
            cellFullName.isUserInteractionEnabled = true
            cellFullName.addGestureRecognizer(tapFullNameGestureRecognizer)
            
            let tapNakedRecognizer = UITapGestureRecognizer(target: self, action: #selector(profPicClick(tapNakedGestureRecognizer:)))
            cellUsername.isUserInteractionEnabled = true
            cellUsername.addGestureRecognizer(tapNakedRecognizer)
            
            let galleryTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(statusImageClick(galleryTapGestureRecog:)))
            AllPicsStackView?.isUserInteractionEnabled = true
            AllPicsStackView?.addGestureRecognizer(galleryTapGestureRecog)
            
            let RTgalleryTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(statusImageClick(galleryTapGestureRecog:)))
            RTAllPicsStackView?.isUserInteractionEnabled = true
            RTAllPicsStackView?.addGestureRecognizer(RTgalleryTapGestureRecog)
            
            let videoTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(videoPlayerSuperviewClick(videoGestureRecognizer:)))
            videoPlayerSuperview?.isUserInteractionEnabled = true
            videoPlayerSuperview?.addGestureRecognizer(videoTapGestureRecog)
            
            let RTvideoTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(videoPlayerSuperviewClickRT(videoGestureRecognizer:)))
            RTVideoSuperView?.isUserInteractionEnabled = true
            RTVideoSuperView?.addGestureRecognizer(RTvideoTapGestureRecog)
            
            let backgroundTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(backgroundClick(backgroundGestureRecognizer:)))
            //fullBackground.isUserInteractionEnabled = true
            fullBackground.addGestureRecognizer(backgroundTapGestureRecog)
            
            let previewTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(previewTitleClick(previewGestureRecognizer:)))
            let previewTapGestureRecog2 = UITapGestureRecognizer(target: self, action: #selector(previewTitleClick(previewGestureRecognizer:)))
            let previewTapGestureRecog3 = UITapGestureRecognizer(target: self, action: #selector(previewTitleClick(previewGestureRecognizer:)))
            
            previewTitle?.isUserInteractionEnabled = true
            slideshow?.isUserInteractionEnabled = true
            previewCanonicalUrl?.isUserInteractionEnabled = true
            previewTitle?.addGestureRecognizer(previewTapGestureRecog)
            slideshow?.addGestureRecognizer(previewTapGestureRecog2)
            previewCanonicalUrl?.addGestureRecognizer(previewTapGestureRecog3)
            
            
            //THIS IS HOW WE SET THE VIDEO IN THE VIEW: youre going to have to do alot more look here: https://stackoverflow.com/questions/33702490/embedding-videos-in-a-tableview-cell
            if let gifImageViewUrl = latestStatus?.gifImageViewUrl {
                videoPlayerItem = AVPlayerItem.init(url: URL(string: gifImageViewUrl)!)
                playIcon.isHidden = false
                if (latestStatus?.hasGif == true){
                    //   print("gif is valid: ", gifImageViewUrl)
                    if (self.getGifButton != nil){
                        self.getGifButton?.isHidden = false
                    }
                }
                //play video
               // self.startPlayback()
            }
            
            if let gifImageViewUrl = latestStatus?.RTgifString {
                RTvideoPlayerItem = AVPlayerItem.init(url: URL(string: gifImageViewUrl)!)
                RTplayIcon.isHidden = false
                //play video
                //self.startPlayback()
            }
            
            if (latestStatus?.isAQuote == false){
                if let thisRegularUrl = latestStatus?.regularUrl{
                    slp.preview(thisRegularUrl,
                                onSuccess: { result in
                                    //print("slp result: \(result)")
                                    self.result = result
                    },
                                onError: { error in print("slp error:  \(error)")})
                }
            }else {
                latestStatus?.regularUrl = nil
            }

            if (latestStatus?.isAQuote == false){
                RTStackView.isHidden = true
            }
            
            
            if var textString = latestStatus?.textTweet{
                if (textString.hasPrefix("BlackTweeterAd")){
                    
                    if let range = textString.range(of: "BlackTweeterAd ") {
                        textString.removeSubrange(range)
                        
                        //always hidden for now
                        //  self.adBar.isHidden = false
                    }
                }
                
                self.cellLatestTweet.text = textString
            }
            
            if let likeCount = latestStatus?.likeCount {
                self.likeButton.setTitle(" \(likeCount)", for: .normal)
            }
            
            if let retweetCount = latestStatus?.retweetCount {
                self.retweetButton.setTitle(" \(retweetCount)", for: .normal)
            }
            
            printTweetId = latestStatus?.tweetId
            printUserId = latestStatus?.userId
            printTweetText = latestStatus?.textTweet
            printUsername = latestStatus?.textUsername
            
        }
    }
    
    @objc func didTap() {
       // slideshow.presentFullScreenController(from: self)
        print("did tap pic")
    }
    
    private func updateUI(enabled: Bool) {
        
        //self.indicator?.isHidden = enabled
        //self.textField?.isEnabled = enabled
        //self.randomTextButton?.isEnabled = enabled
        //self.submitButton?.isEnabled = enabled
        
    }
    
    private func startCrawling() {
        
        //self.centerLoadingActivityIndicatorView?.startAnimating()
        self.updateUI(enabled: false)//does nothing
        //self.showHideAll(hide: true)
        //self.textField?.resignFirstResponder()
        //self.indicator?.isHidden = false
        
    }
    
    private func endCrawling() {
        
        self.updateUI(enabled: true)//does nothing
        
    }
    
    // Update UI
    private func showHideAll(hide: Bool) {
        
        self.slideshow?.isHidden = hide
        
        //self.detailedView?.isHidden = hide
        self.openWithButton?.isHidden = hide
        //self.previewAreaLabel?.isHidden = !hide
        
    }
    
    private func setUpSlideshow() {
        self.slideshow?.backgroundColor = UIColor.white
        self.slideshow?.slideshowInterval = 4.0
        self.slideshow?.pageControlPosition = PageControlPosition.hidden
        self.slideshow?.contentScaleMode = .scaleAspectFit
    }
    
    
    
    
    private func setData() {
        if let value: [String] = self.result[.images] as? [String] {
            if !value.isEmpty {
        
                var images: [InputSource] = []
                
                for image in value {
                    if let source = AlamofireSource(urlString: image) {
                        images.append(source)
                    }
                }
                
                self.setImage(images: images)
            } else {
                self.setImage(image: self.result[.image] as? String)
            }
            
        } else {
            self.setImage(image: self.result[.image] as? String)
        }
        
        if let value: String = self.result[.title] as? String {
            
            self.previewTitle?.text = value.isEmpty ? "No title" : value
            
        } else {
            self.previewTitle?.text = "No title"
        }
        
        if let value: String = self.result[.canonicalUrl] as? String {
            self.previewCanonicalUrl?.text = value.isEmpty ? "No url" : value
        }else{
            self.previewCanonicalUrl?.text = "No url"
        }
        
        if let value: String = self.result[.description] as? String {
            self.previewDescription?.text = value.isEmpty ? "No description" : value
            
        } else {
            self.previewTitle?.text = "No description"
            self.previewCanonicalUrl?.text = "No url"
        }
        
        self.showHideAll(hide: false)
        self.endCrawling()
        
        
    }
    
    func getRegularWebsite(){
        let textFieldText = self.latestStatus?.regularUrl
        if (textFieldText != nil){
            if let url = self.slp.extractURL(text: textFieldText!),
                let cached = self.slp.cache.slp_getCachedResponse(url: url.absoluteString) {
                self.result = cached
                self.setData()
                result.forEach { print("\($0):", $1) }
                
            } else {
                self.slp.preview(
                    textFieldText!,
                    onSuccess: { result in
                        result.forEach { print("\($0):", $1) }
                        self.result = result
                        self.setData()
                },
                    onError: { error in
                        print(error)
                        self.endCrawling()
                })
            }
        }
    }
    
    func openSafariForRegUrl(){
        if let url = self.result[.finalUrl] as? URL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    
    private func setImage(image: String?) {
        if let image: String = image {
            if !image.isEmpty {
                if let source = AlamofireSource(urlString: image) {
                    self.setImage(images: [source])
                    if(latestStatus?.retweetedBy != nil){
                        RetweetedByLabel.isHidden = false
                    }
                } else {
                    //self.slideshow?.setImageInputs(placeholderImages)
                }
            } else {
                //self.slideshow?.setImageInputs(placeholderImages)
            }
        } else {
           // self.slideshow?.setImageInputs(placeholderImages)
        }
       // self.centerLoadingActivityIndicatorView?.stopAnimating()
    }
    
    private func setImage(images: [InputSource]?) {
        
        if let images = images {
            self.slideshow?.setImageInputs(images)
            if(latestStatus?.retweetedBy != nil){
                RetweetedByLabel.isHidden = false
            }
        } else {
           // self.slideshow?.setImageInputs(placeholderImages)
        }
        //self.centerLoadingActivityIndicatorView?.stopAnimating()
        
    }
    
    
    fileprivate func resetImages() {
        statusImage0.image = nil
        statusImage1.image = nil
        statusImage2.image = nil
        statusImage3.image = nil
        
        RTstatusImage0.image = nil
        RTstatusImage1.image = nil
        RTstatusImage2.image = nil
        RTstatusImage3.image = nil
        pictures = []
       // var images: [InputSource] = []
        self.slideshow?.setImageInputs([])
        self.previewCanonicalUrl?.text = nil
        self.previewTitle?.text = nil
    }
    
    //https://stackoverflow.com/questions/46901059/uitableviewcell-subclass-wrong-image-in-cell-or-old-image-bug
    func update(_ data: LatestStatus) {
        resetImages()
        
        if(latestStatus?.gifImageViewUrl == nil){
            videoPlayerSuperview.isHidden = true
            playIcon.isHidden = true
        }else {
            videoPlayerSuperview.isHidden = false
            playIcon.isHidden = false
        }
        
        if(latestStatus?.RTgifString == nil){
            RTVideoSuperView.isHidden = true
            RTplayIcon.isHidden = true
        }else {
            RTVideoSuperView.isHidden = false
            RTplayIcon.isHidden = false
        }
        
        if (latestStatus?.regularUrl == nil){
            slideshow?.isHidden = true
            regularUrlDescStack.isHidden = true
        }else{
            slideshow?.isHidden = false
            regularUrlDescStack.isHidden = false
        }
        
        //if I have four images do nothing else...
        if (latestStatus?.statusImageUrl2 != nil && latestStatus?.statusImageUrl3 == nil){
            statusImage3.isHidden = true
        } else if (latestStatus?.statusImageUrl1 != nil && latestStatus?.statusImageUrl2 == nil){
            ThreeAndFourStackView.isHidden = true
        } else if (latestStatus?.statusImageUrl0 != nil && latestStatus?.statusImageUrl1 == nil) {
            ThreeAndFourStackView.isHidden = true
            statusImage1.isHidden = true
        } else if (latestStatus?.statusImageUrl0 == nil) {
            AllPicsStackView.isHidden = true
        }
        
        if (latestStatus?.hasGif == false){
            gifStackView.isHidden = true
        }
        
        if (latestStatus?.statusImageUrl0 != nil){
            let fileUrl = URL(string: (latestStatus?.statusImageUrl0)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            statusImage0.kf.setImage(with: resource)
            
            //https://github.com/gmunhoz/CollieGallery
            var picture = CollieGalleryPicture()
            if (statusImage0.image == nil){
                let picture = CollieGalleryPicture(url: (latestStatus?.statusImageUrl0)!)
                pictures.append(picture)
            }else if (statusImage0.image != nil){
                picture = CollieGalleryPicture(image: (statusImage0.image!))
                pictures.append(picture)//whe might have to do picture = picture[] first
            }
            
        }
        if (latestStatus?.statusImageUrl1 != nil){
            let fileUrl = URL(string: (latestStatus?.statusImageUrl1)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            statusImage1.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.statusImageUrl1)!)
            pictures.append(picture)
        }
        if (latestStatus?.statusImageUrl2 != nil){
            let fileUrl = URL(string: (latestStatus?.statusImageUrl2)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            statusImage2.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.statusImageUrl2)!)
            pictures.append(picture)
            
        }
        if (latestStatus?.statusImageUrl3 != nil){
            let fileUrl = URL(string: (latestStatus?.statusImageUrl3)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            statusImage3.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.statusImageUrl3)!)
            pictures.append(picture)
        }
        
        
        //if I have four RT images do nothing else...
        if (latestStatus?.RTmediaString2 != nil && latestStatus?.RTmediaString3 == nil){
            RTstatusImage3.isHidden = true
        } else if (latestStatus?.RTmediaString1 != nil && latestStatus?.RTmediaString2 == nil){
            RTThreeAndFourStackView.isHidden = true
        } else if (latestStatus?.RTmediaString0 != nil && latestStatus?.RTmediaString1 == nil) {
            RTThreeAndFourStackView.isHidden = true
            RTstatusImage1.isHidden = true
        } else if (latestStatus?.RTmediaString0 == nil) {
            RTAllPicsStackView.isHidden = true
        }
        
        if (latestStatus?.RTmediaString0 != nil){
            let fileUrl = URL(string: (latestStatus?.RTmediaString0)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            RTstatusImage0.kf.setImage(with: resource)
            
            //https://github.com/gmunhoz/CollieGallery
            var picture = CollieGalleryPicture()
            if (RTstatusImage0.image == nil){
                let picture = CollieGalleryPicture(url: (latestStatus?.RTmediaString0)!)
                pictures.append(picture)
            }else if (RTstatusImage0.image != nil){
                picture = CollieGalleryPicture(image: (RTstatusImage0.image!))
                pictures.append(picture)//whe might have to do picture = picture[] first
            }
        }
        if (latestStatus?.RTmediaString1 != nil){
            let fileUrl = URL(string: (latestStatus?.RTmediaString1)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            RTstatusImage1.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.RTmediaString1)!)
            pictures.append(picture)
        }
        if (latestStatus?.RTmediaString2 != nil){
            let fileUrl = URL(string: (latestStatus?.RTmediaString2)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            RTstatusImage2.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.RTmediaString2)!)
            pictures.append(picture)
        }
        if (latestStatus?.RTmediaString3 != nil){
            let fileUrl = URL(string: (latestStatus?.RTmediaString3)!)
            let resource = ImageResource(downloadURL: fileUrl!)
            RTstatusImage3.kf.setImage(with: resource)
            let picture = CollieGalleryPicture(url: (latestStatus?.RTmediaString3)!)
            pictures.append(picture)
        }
    
        
        //if there is a picture of video, remove the url in the textTweet
        if (latestStatus?.statusImageUrl0 != nil || latestStatus?.gifImageViewUrl != nil || (latestStatus?.isAQuote)!){
            var arrayOfTweet = latestStatus?.textTweet?.characters.split{$0 == " "}.map(String.init)
            arrayOfTweet = arrayOfTweet!.filter(){!$0.hasPrefix("http")}//remove words that begin with http (aka urls)
            self.cellLatestTweet.text = arrayOfTweet!.joined(separator: " ")
        }
        self.cellLatestTweet.text = self.cellLatestTweet.text.replacingOccurrences(of: "&gt;", with: ">")
        self.cellLatestTweet.text = self.cellLatestTweet.text.replacingOccurrences(of: "&lt;", with: "<")
        self.RTText.text = self.RTText.text.replacingOccurrences(of: "&gt;", with: ">")
        self.RTText.text = self.RTText.text.replacingOccurrences(of: "&lt;", with: "<")
        self.cellLatestTweet.text = self.cellLatestTweet.text.replacingOccurrences(of: "&amp;", with: "&")
        self.RTText.text = self.RTText.text.replacingOccurrences(of: "&amp;", with: "&")
        
        getRegularWebsite()
        setUpSlideshow()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc func profPicClick(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("profile pic clicked")
        var transImage = tapGestureRecognizer.view as! UIImageView
        let fUserId = printUserId
        print("fuserid: ", fUserId)
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.goToProfilePage(userID: fUserId!, profileImage: transImage as! UIImageView)
        }else{
            print("self.delegate is nil")
        }
    }
    
    @objc func profPicClick(tapNakedGestureRecognizer: UITapGestureRecognizer)
    {
        let fUserId = printUsername
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.goToProfNaked(userId: fUserId!)
        }
    }
    
    @objc func profPicClick(tapFullNameGestureRecognizer: UITapGestureRecognizer)
    {
        let fUserId = printUsername
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.goToProfNaked(userId: fUserId!)
        }
    }
    
    @objc func statusImageClick(galleryTapGestureRecog: UITapGestureRecognizer)
    {
        let options = CollieGalleryOptions()
        options.parallaxFactor = 0.8
        options.maximumZoomScale = 2.5
        // options.gapBetweenPages = 20
        var gallery = CollieGallery(pictures: pictures, options: options)
        if (self.collieDelegate != nil){
            self.collieDelegate?.gallery!(gallery, indexChangedTo: 0)
        }
    }
    
    @objc func videoPlayerSuperviewClick(videoGestureRecognizer: UITapGestureRecognizer){
        self.playExternalVideo(gifImageUrl: (latestStatus?.gifImageViewUrl)!)
    }
    
    @objc func videoPlayerSuperviewClickRT(videoGestureRecognizer: UITapGestureRecognizer){
        self.playExternalVideo(gifImageUrl: (latestStatus?.RTgifString)!)
    }
    
    @objc func backgroundClick(backgroundGestureRecognizer: UITapGestureRecognizer) {
        backgroundClicked()
    }
    
    @objc func previewTitleClick(previewGestureRecognizer: UITapGestureRecognizer) {
        openSafariForRegUrl()
    }
    
    
    
    func playExternalVideo (gifImageUrl: String) {
        let videoURL = URL(string: (gifImageUrl))
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        self.parentViewController?.present(playerViewController, animated: true, completion: {() -> Void in
            playerViewController.player?.play()
        })
    }
    
    
    
    func backgroundClicked (){
        print("background clicked")
    }
    
    
    @objc func videoClick(tapGestureRecognizer: UITapGestureRecognizer)
    {
        var transVideo = tapGestureRecognizer.view as! UIView
        let playerController : AVPlayerViewController = {
            
            if let urlForPlayer = URL(string: "your_video_url") {
                $0.player = AVPlayer(url: urlForPlayer)
            }
            return $0
        } (AVPlayerViewController())
    }
    
    func updateButtons(){
        latestStatus?.didFavorite = likeOutside
        latestStatus?.didRetweet = retweetOutside
        reset()
        
        if (latestStatus?.didFavorite == true){
            likeButton.setImage(UIImage(named: "icon-heart-teal"), for: .normal)
            likeButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
            likeButton.alpha = 1.0
        }else {
            likeButton.setImage(UIImage(named: "icon-heart"), for: .normal)
            likeButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
            likeButton.alpha = 0.5
        }
        if (latestStatus?.didRetweet == true){
            retweetButton.setImage(UIImage(named: "icon-retweet-teal"), for: .normal)
            retweetButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
            retweetButton.alpha = 1.0
        }else {
            retweetButton.setImage(UIImage(named: "icon-retweet"), for: .normal)
            retweetButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
            retweetButton.alpha = 0.5
        }
    }
    
    func reset(){
        likeButton.setImage(UIImage(named: "icon-heart"), for: .normal)
        likeButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
        likeButton.alpha = 0.5
        retweetButton.setImage(UIImage(named: "icon-retweet"), for: .normal)
        retweetButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
        retweetButton.alpha = 0.5
        
        if (latestStatus?.hasGif == false){
            if (self.getGifButton != nil){
                self.getGifButton?.isHidden = true
            }
        }
        if(latestStatus?.gifImageViewUrl == nil){
            videoPlayerSuperview.isHidden = true
            playIcon.isHidden = true
        }else {
            videoPlayerSuperview.isHidden = false
            playIcon.isHidden = false
        }
        
        if(latestStatus?.RTgifString == nil){
            RTVideoSuperView.isHidden = true
        }else {
            RTVideoSuperView.isHidden = false
        }
        
        if (latestStatus?.regularUrl == nil){
            slideshow?.isHidden = true
            regularUrlDescStack.isHidden = true
        }else{
            slideshow?.isHidden = false
            regularUrlDescStack.isHidden = false
        }
    }
    
    func like(sender: UIButton) {
        let failureHandler: (Error) -> Void = { error in
            print("Was unable to like 😕 because: \(error.localizedDescription)")
            self.makeToast("Liked 👍🏾", duration: 2.0, position: .center, style: self.style)
        }
        if (self.likeOutside == false){
            swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: OAUTH_TOKEN, oauthTokenSecret: OAUTH_TOKEN_SECRET)
            swifter?.favoriteTweet(forID: printTweetId!, includeEntities: false, tweetMode: TweetMode.default, success: { json in
                print ("now liking")
                
                self.likeOutside = true
                let row = sender.tag
                self.style.backgroundColor = AppConstants.tweeterDarkGreen
                self.changeButton(senderButton: sender, actualButton: self.likeButton)
                //
                ReusableTableView.favoriteSelected[row] = true
                self.makeToast("Liked 👍🏾", duration: 2.0, position: .center, style: self.style)
            }, failure: failureHandler)
        }else if (self.likeOutside == true){
            swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: OAUTH_TOKEN, oauthTokenSecret: OAUTH_TOKEN_SECRET)
            swifter?.unfavoriteTweet(forID: printTweetId!, includeEntities: false, tweetMode: TweetMode.default, success: { json in
                self.likeOutside = false
                print ("now UNliking")
                let row = sender.tag
                self.style.backgroundColor = AppConstants.tweeterDarkGreen
                self.changeButton(senderButton: sender, actualButton: self.likeButton)
                //                //this is only done to make the s
                ReusableTableView.favoriteSelected[row] = false
                self.makeToast("Unliked 👎🏾", duration: 2.0, position: .center, style: self.style)
                
            }, failure: failureHandler)
        }
    }
    
    
    func retweet(sender: UIButton) {
        let failureHandler: (Error) -> Void = { error in
            print("Was unable to retweet 😕 because: \(error.localizedDescription)")
        }
        
        if (self.retweetOutside == false){
            swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: OAUTH_TOKEN, oauthTokenSecret: OAUTH_TOKEN_SECRET)
            swifter?.retweetTweet(forID: printTweetId!, trimUser: false, tweetMode: TweetMode.default, success: { json in
                self.retweetOutside = true
                let row = sender.tag
                self.style.backgroundColor = AppConstants.tweeterDarkGreen
                self.changeButton(senderButton: sender, actualButton: self.retweetButton)
                
                ReusableTableView.retweetSelected[row] = true
                self.makeToast("Retweeted. Sharing is caring", duration: 2.0, position: .center, style: self.style)
                
                
            }, failure: failureHandler)
        }else if (self.retweetOutside == true){
            swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: OAUTH_TOKEN, oauthTokenSecret: OAUTH_TOKEN_SECRET)
            swifter?.unretweetTweet(forID: printTweetId!, trimUser: false, tweetMode: TweetMode.default, success: { json in
                self.retweetOutside = false
                let row = sender.tag
                self.style.backgroundColor = AppConstants.tweeterDarkGreen
                self.changeButton(senderButton: sender, actualButton: self.retweetButton)
                
                ReusableTableView.retweetSelected[row] = false
                self.makeToast("Un-Retweeted", duration: 2.0, position: .center, style: self.style)
            }, failure: failureHandler)
        }
    }
    
    
    public func reply() {
        let fTweetId = printTweetId
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.goReplyToTweet(tweetID: fTweetId!)
            print("going to write (not really) with tweetId: ", fTweetId!)
        }
    }
    
    public func quote (){
        if(self.delegate != nil){ //Just to be safe.
            //self.delegate.goQuoteTweet(tweetText: self.cellLatestTweet.text, username: self.cellUsername.text! ) //should also work, havent tested
            self.delegate.goQuoteTweet(tweetText: printTweetText!, username: printUsername!)
            print("values from quote: " + self.cellLatestTweet.text + " " + self.cellUsername.text!)
        }
    }
    
    //https://stackoverflow.com/questions/30483104/presenting-uialertcontroller-from-uitableviewcell
    func alert(title: String, message: String, uivc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aight", style: .default, handler: nil))
        uivc.present(alert, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupMoviePlayer()
        setupMoviePlayerRT()
    }
    
    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer?.volume = 0
        avPlayer?.actionAtItemEnd = .none
        
        //        You need to have different variations
        //        according to the device so as the avplayer fits well
        if UIScreen.main.bounds.width == 375 {
            let widthRequired = self.frame.size.width - 20
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }else if UIScreen.main.bounds.width == 320 {
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
        }else{
            let widthRequired = self.frame.size.width
            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }
        self.backgroundColor = .clear
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPlayerSuperview.layer.insertSublayer(avPlayerLayer!, at: 0)
        
        
        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func setupMoviePlayerRT(){
        self.RTavPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        RTavPlayerLayer = AVPlayerLayer(player: RTavPlayer)
        RTavPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        RTavPlayer?.volume = 0
        RTavPlayer?.actionAtItemEnd = .none
        
        //        You need to have different variations
        //        according to the device so as the avplayer fits well
        if UIScreen.main.bounds.width == 375 {
            let widthRequired = self.frame.size.width - 20
            RTavPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }else if UIScreen.main.bounds.width == 320 {
            RTavPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
        }else{
            let widthRequired = self.frame.size.width
            RTavPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
        }
        self.backgroundColor = .clear
        RTavPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.RTVideoSuperView.layer.insertSublayer(RTavPlayerLayer!, at: 0)
        
        
        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: RTavPlayer?.currentItem)
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        //p.seek(to: kCMTimeZero)
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func RTstopPlayback(){
        self.RTavPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    func RTstartPlayback(){
        self.RTavPlayer?.play()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func copyGif(gifUrl: String){
        if (gifUrl != nil){
            UIPasteboard.general.string = gifUrl
        }
        self.parentViewController?.toastMessage("Copied GIF Link to Clipboard")
    }
    
    func deleteTweet(){
        let failureHandler: (Error) -> Void = { error in
            print("Was unable to delete 😕 because of an error: \(error.localizedDescription)")
            self.alert(title: "Damn son...", message: "Was unable to delete 😕 because of an error: \(error.localizedDescription)", uivc: self.parentViewController!)
        }
        swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: OAUTH_TOKEN, oauthTokenSecret: OAUTH_TOKEN_SECRET)
        swifter?.destroyTweet(forID: printTweetId!, trimUser: false, tweetMode: TweetMode.extended, success: { json in
            // print(json)
            self.parentViewController?.toastMessage("Poof! Gone")
            self.reloadTalbeveiwInsideOfCell()
            self.alpha = 0.1
        },    failure: failureHandler)
    }
    
    func changeButton(senderButton: UIButton, actualButton: UIButton){
        gifStackView.isHidden = true
        cellLatestTweet.isHidden = false
        //        if (latestStatus?.hasGif == false){
        //            gifStackView.isHidden = true
        //        }else {
        //
        //        }
        UIView.transition(with: senderButton, duration: 0.65, options: .transitionFlipFromRight, animations: {
            if ((actualButton == self.likeButton) && (senderButton == self.likeButton)){
                //This is only if it is already liked
                if (self.likeOutside == false){
                    senderButton.setImage(UIImage(named: "icon-heart"), for: .normal)
                    actualButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
                    actualButton.alpha = 0.5
                    //This is only if it has NOT been already liked
                }else{
                    senderButton.setImage(UIImage(named: "icon-heart-teal"), for: .normal)
                    actualButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
                    actualButton.alpha = 1.0
                }
                
            }else if ((actualButton == self.retweetButton) && (senderButton == self.retweetButton)){
                if (self.retweetOutside == false){
                    senderButton.setImage(UIImage(named: "icon-retweet"), for: .normal)
                    actualButton.setTitleColor(AppConstants.tweeterDarkBrown, for: .normal)
                    actualButton.alpha = 0.5
                }else {
                    senderButton.setImage(UIImage(named: "icon-retweet-teal"), for: .normal)
                    actualButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
                    actualButton.alpha = 1.0
                }
            }
        }, completion: nil)
        gifStackView.isHidden = true
        cellLatestTweet.isHidden = false
    }
    
    //this should be done after we
    func reloadTalbeveiwInsideOfCell() {
        customCelldelegate?.updateTableView()
    }
    
}

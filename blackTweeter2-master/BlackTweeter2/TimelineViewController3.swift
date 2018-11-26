//
//  TimelineViewController3.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 8/23/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS
import FirebaseDatabase
import Locksmith
import SafariServices
import AVFoundation
import CollieGallery
//import GoogleMobileAds

class TimelineViewController3: BaseViewController,  UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    // @IBOutlet weak var bannerView: GADBannerView!
    
    
    @IBOutlet weak var thisTableview: UITableView!
    var reusableTableView: ReusableTableView!
    
    //@IBOutlet weak var menuButton: UIBarButtonItem!
    
    var timer: Timer?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //  var versionRef: DatabaseReference!
    var hardVersion: Int = 1
    
    private var tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    
    var universalWasOpen: Bool = false
    
    
    var avPlayerLayer: AVPlayerLayer!
    var firstLoad = true
    
    let TWITTER_CONSUMER_KEY = UserDefaults.standard.object(forKey: "twitterConsumerKey")
    let TWITTER_CONSUMER_SECRET_KEY = UserDefaults.standard.object(forKey: "twitterConsumerSecretKey")
    let CALLBACK_URL = "http://www.google.com"
    var swifter: Swifter?
    static var universalLoadChecker: Bool = false
    private var latestStatuses: [LatestStatus] = []
    var tweetsArray : [JSON] = []
    
    let vw = UIView()
    var twitterWebview : UIWebView?
    var blurEffectView: UIVisualEffectView?
    var backgroundIsBlurred = false
    
    //    static var favoriteSelected:[Bool] = Array(repeating: false, count: 198)
    //    static var retweetSelected:[Bool] = Array(repeating: false, count: 198)
    
    //this is done everytime the reload button is clicked
    func clearOutAndRefresh () {
        tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
        latestStatuses = []
        tweetsArray = []
        if (tokenDictionary != nil) {
            print("token dictionary is not nil")
            brainsForViewDidLoad()
            print("cleared out and refreshed")
        }
    }
    
    
    func callBack (string:String, wordType:wordType){
        print("received string: ", string)
        if wordType == .hashtag {
            print("going to hashtag vc")
        } else {
            print("going to atName vc")
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //myIndex = indexPath.row
        let myTweetId = latestStatuses[indexPath.row].tweetId
        let myTweet = latestStatuses[indexPath.row].textTweet
        print("tweet id is: \(myTweetId!). tweet is: \(myTweet!)")
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //reset the blur scroll effect
        super.viewWillAppear(animated)
        
        thisTableview.isScrollEnabled = true
        backgroundIsBlurred = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayLoadingGIF()
        
        //        let request = GADRequest ()
        //        request.testDevices = [kGADSimulatorID]
        //        bannerView.delegate = self
        //        bannerView.adUnitID = "ca-app-pub-39..." //MAKE SURE TO CHANGE THIS FOR THE PRODUCTION VERSION!!!!
        //        bannerView.rootViewController = self
        //        bannerView.load(request)
        
        brainsForViewDidLoad()
        setUpMenuButton()
        initNavigationItemTitleView()
    }
    
    private func initNavigationItemTitleView() {
        let titleView = UILabel()
        titleView.text = "BlackTweeter ✊🏾"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.init(), size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc private func titleWasTapped() {
        scrollToFirstRow()
    }
    
    //this only happens when we have to load it up for th first time after login
    // if (universalWasOpen &&  tokenDictionary == nil) { //Bool = (self.appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil))!
    //    print("drawer was open AND token is nil now setting the data and reloading ")
    //    tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    //    pureReload()
    
    func brainsForViewDidLoad () {
        //if there the token/secret is incorrect this will cause an error and not allow the user to log in. fix this. access token and oathtoken are the same thing fyi
        
        if (tokenDictionary == nil) {
            tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
        }
        
        if (tokenDictionary != nil){
            //            print("timeline dic accesstokenKey:\(tokenDictionary!["accessTokenKey"] as! String)")
            //            print("timeline dic accesstokenSecret:\(tokenDictionary!["accessTokenSecret"] as! String)")
            
            self.swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY as! String, consumerSecret: TWITTER_CONSUMER_SECRET_KEY as! String, oauthToken: tokenDictionary!["accessTokenKey"] as! String, oauthTokenSecret: tokenDictionary!["accessTokenSecret"] as! String)
            
            if (self.swifter == nil) {
                print("the account is nil!")
            }else{
                print("the account is NOT nil!")
                self.displayLoadingGIF()
                fetchHomeTimeline()
            }
        }else {
            toggleDrawer()
        }
    }
    
    func fetchHomeTimeline() { //how to get more than 200 tweets https://github.com/ttezel/twit/issues/318
        
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with you network 😕. ", error.localizedDescription)
            if (error.localizedDescription.contains("You might be connecting to a server that is pretending")){
                self.alert(title: "Watch your back...", message: "Aight so boom...the network you're on has strict security rules, might be watched and is blocking Twitter 👀")
            } else {
                self.alert(title: "Damn...", message: "Yeaaa...so theres a problem with you network 😕.")
            }
            self.dismissLoadingGIF()
            
        }
        //check is_quote_status true/false AND check if
        
        self.swifter?.getHomeTimeline(count:151, sinceID: nil, maxID: nil, trimUser: false, contributorDetails: true, includeEntities: true, tweetMode: TweetMode.extended,
                                      success: { json in
                                        // Successfully fetched timeline, so lets create and push to the table view
                                        print("ben! succes in getting timeline")
                                        print("json", json)
                                        guard let tweets = json.array else { return }
                                        self.tweetsArray = tweets
                                        
                                        print("number of gotten tweets \(tweets.count)")
                                        
                                        
                                        for var tweet in self.tweetsArray {
                                            
                                            var isARetweet: Bool = false
                                            var isAQuote: Bool = false
                                            var retweetedBy: String?
                                            
                                            //how we are going to handle plain RT's: we ask FIRST "if (tweet["retweeted_status"]["full_text"].string != nil)" then
                                            //then we will make tweet (aka self.tweetsArray) equal tweet["retweeted_status"]...then get all the relevant information (double check if they are their first and then populate. Then only difference will be "retweeted by xyz" at the top. for quoted tweets we will just use the quoted section in freecell and ONLY SHOW username, full name, and time for ouside and ONLY SHOW username, full name, pics and in videos for inside. NOT TIME
                                            
                                            if (tweet["retweeted_status"]["full_text"].string != nil){//getS plain retweeted tweets ONLY
                                                retweetedBy = tweet["user"]["name"].string
                                                isARetweet = true
                                                isAQuote = false
                                                tweet = tweet["retweeted_status"]
                                            }
                                            
                                            var profileImage = tweet["user"]["profile_image_url_https"].string
                                            profileImage =  self.getHighDefPic(lowDefProfileUrl: profileImage!)
                                            var text = tweet["full_text"].string
                                           // text = ("RETWEET \(text!)")
                                            print ("retweetben ", text!)
                                            let username = tweet["user"]["screen_name"].string
                                            let fullname = tweet["user"]["name"].string
                                            let favoriteCount = tweet["favorite_count"].integer
                                            let retweetCount = tweet["retweet_count"].integer
                                            let tweetId = tweet["id_str"].string
                                            let userId = tweet["user"]["id_str"].string
                                            let didFavorite = tweet["favorited"].bool
                                            let didRetweet = tweet["retweeted"].bool
                                            var gifString: String?
                                            var regularString: String?
                                            var hasGif: Bool = false
                                            
                                            var RTUsername: String?
                                            var RTFullName: String?
                                            var RTText: String?
                                            var RTgifString: String?
                                            var RTmediaString0: String?
                                            var RTmediaString1: String?
                                            var RTmediaString2: String?
                                            var RTmediaString3: String?
                                            //var RThasGif: Bool = false
                                            
                                            let tempTimestamp = tweet["created_at"].string
                                            let nsTimestamp = self.parseTweetTimestamp(timestamp: tempTimestamp!)
                                            let dateTimestamp = nsTimestamp! as Date
                                            let timeStamp = dateTimestamp.timeAgoDisplay()
                                            
                                            var mediaString0: String?
                                            var mediaString1: String?
                                            var mediaString2: String?
                                            var mediaString3: String?
                                            
                                            gifString = nil
                                            mediaString0 = nil
                                            mediaString1 = nil
                                            mediaString2 = nil
                                            mediaString3  = nil
                                            RTgifString = nil
                                            RTmediaString0 = nil
                                            RTmediaString1 = nil
                                            RTmediaString2 = nil
                                            RTmediaString3 = nil
                                            
                                            
                                            //check is_quote_status true/false
                                            if (tweet["quoted_status"]["full_text"].string != nil){//getS Quoted tweets ONLY (if tweet["quoted_status"]["full_text"].string != nil)
                                                isARetweet = false
                                                isAQuote = true
                                                RTText = tweet["quoted_status"]["full_text"].string
                                                RTFullName = tweet["quoted_status"]["user"]["name"].string
                                                RTUsername = tweet["quoted_status"]["user"]["screen_name"].string
                                                if let urlString = tweet["quoted_status"]["extended_entities"].object {
                                                    for myEntry in urlString {
                                                        if (myEntry.key == "media") {
                                                            let smallJson = myEntry.value
                                                            
                                                            if (smallJson[0]["type"].string == "photo") {
                                                                if let mediaStringZero = smallJson[0]["media_url_https"].string {
                                                                    RTmediaString0 = ""
                                                                    if (mediaStringZero.count > 10) {
                                                                        RTmediaString0 = mediaStringZero
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                if let mediaStringOne = smallJson[1]["media_url_https"].string {
                                                                    RTmediaString1 = ""
                                                                    if (mediaStringOne.count > 10) {
                                                                       RTmediaString1 = mediaStringOne
                                                                    }
                                                                } else {
                                                                    
                                                                }
                                                                if let mediaStringTwo = smallJson[2]["media_url_https"].string {
                                                                    RTmediaString2 = ""
                                                                    if (mediaStringTwo.count > 10) {
                                                                        RTmediaString2 = mediaStringTwo
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                if let mediaStringThree = smallJson[3]["media_url_https"].string {
                                                                    RTmediaString3 = ""
                                                                    if (mediaStringThree.count > 10) {
                                                                        RTmediaString3 = mediaStringThree
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                
                                                            }else if (smallJson[0]["type"].string == "animated_gif" || smallJson[0]["type"].string == "video"){
                                                                if(smallJson[0]["type"].string == "animated_gif"){
                                                                  //  RThasGif = true
                                                                }
                                                                if let gifStringZero = smallJson[0]["video_info"].object {
                                                                    for gifInfo in gifStringZero {
                                                                        if (gifInfo.key == "variants") {
                                                                            RTgifString = gifInfo.value[0]["url"].string
                                                                            if (hasGif){
                                                                                //print("gifStringZero: ", gifString!)
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if let regularUrlString = tweet["entities"].object {
                                                for myEntry in regularUrlString {
                                                    if (myEntry.key == "urls") {
                                                        let smallJson = myEntry.value
                                                        if let urlStringZero = smallJson[0]["expanded_url"].string {
                                                           // print("urlStringzero: ", urlStringZero)
                                                            regularString = urlStringZero
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //If there is a website, don't show pics or video
                                            if (regularString != nil){
                                                //do nothing
                                            }else{
                                                if let urlString = tweet["extended_entities"].object {
                                                    for myEntry in urlString {
                                                        if (myEntry.key == "media") {
                                                            let smallJson = myEntry.value
                                                            
                                                            if (smallJson[0]["type"].string == "photo") {
                                                                if let mediaStringZero = smallJson[0]["media_url_https"].string {
                                                                    mediaString0 = ""
                                                                    if (mediaStringZero.count > 10) {
                                                                        mediaString0 = mediaStringZero
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                if let mediaStringOne = smallJson[1]["media_url_https"].string {
                                                                    mediaString1 = ""
                                                                    if (mediaStringOne.count > 10) {
                                                                        mediaString1 = mediaStringOne
                                                                    }
                                                                } else {
                                                                    
                                                                }
                                                                if let mediaStringTwo = smallJson[2]["media_url_https"].string {
                                                                    mediaString2 = ""
                                                                    if (mediaStringTwo.count > 10) {
                                                                        mediaString2 = mediaStringTwo
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                if let mediaStringThree = smallJson[3]["media_url_https"].string {
                                                                    mediaString3 = ""
                                                                    if (mediaStringThree.count > 10) {
                                                                        mediaString3 = mediaStringThree
                                                                    }
                                                                }else {
                                                                    
                                                                }
                                                                
                                                            }else if (smallJson[0]["type"].string == "animated_gif" || smallJson[0]["type"].string == "video"){
                                                                if(smallJson[0]["type"].string == "animated_gif"){
                                                                    hasGif = true
                                                                }
                                                                if let gifStringZero = smallJson[0]["video_info"].object {
                                                                    for gifInfo in gifStringZero {
                                                                        if (gifInfo.key == "variants") {
                                                                            gifString = gifInfo.value[0]["url"].string
                                                                            if (hasGif){
                                                                              //print("gifStringZero: ", gifString!)
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if let regularUrlString = tweet["entities"].object {
                                                for myEntry in regularUrlString {
                                                    if (myEntry.key == "urls") {
                                                        let smallJson = myEntry.value
                                                        if let urlStringZero = smallJson[0]["expanded_url"].string {
                                                            regularString = urlStringZero
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            let thisHomestatus = LatestStatus(userId: userId!, textTweet: String (describing: text!), profileImageUrl: profileImage!, gifImageViewUrl: gifString, regularUrl: regularString, hasGif: hasGif, statusImageUrl0: mediaString0, statusImageUrl1: mediaString1, statusImageUrl2: mediaString2, statusImageUrl3: mediaString3, textFullName: fullname!, textUsername: username!, likeCount: String (describing: favoriteCount!), retweetCount: String (describing: retweetCount!), tweetId: tweetId!, didFavorite: didFavorite, didRetweet: didRetweet, timeStamp: timeStamp, retweetedBy: retweetedBy, isARetweet: isARetweet, isAQuote: isAQuote, RTUsername: RTUsername, RTFullName: RTFullName, RTText: RTText, RTgifString: RTgifString, RTmediaString0: RTmediaString0, RTmediaString1: RTmediaString1, RTmediaString2: RTmediaString2, RTmediaString3: RTmediaString3)
                                            
                                            
                                            self.latestStatuses.append(thisHomestatus)
                                            
                                            //we may not need this line
                                            regularString = ""
                                        }
                                        self.refreshUI()
        }, failure: failureHandler)
        
    }
    
    func refreshUI() {
        DispatchQueue.main.async{
            self.reusableTableView = ReusableTableView(self.thisTableview, self.latestStatuses, self)
            //self.reusableTableView.tableView?.reloadData()
            self.thisTableview.reloadData()
            self.scrollToFirstRow()
            self.dismissLoadingGIF()
        }
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.thisTableview.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    
    func toggleDrawer() {
        AuthViewReal.controllerOpenedFrom = self
        universalWasOpen = (self.appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil))!
        // let wasOpen: Bool = (self.appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil))!
        print("was open: \(universalWasOpen)")
        if (universalWasOpen) {
            if (tokenDictionary != nil) {
                clearOutAndRefresh()
                print("drawer WAS open and token is not nil")
            }
        }
    }
    
    func parseTweetTimestamp(timestamp: String) -> NSDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier:"en_US") as Locale?
        dateFormatter.dateStyle = .long
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return dateFormatter.date(from: timestamp) as! NSDate
    }
    
    func getHighDefPic (lowDefProfileUrl: String) -> String {
        var profileImageUrl: String = ""
        if (lowDefProfileUrl != nil){
            profileImageUrl = lowDefProfileUrl
            if (profileImageUrl.hasSuffix(".jpg")){
                if let range = profileImageUrl.range(of: "_normal.jpg") {
                    profileImageUrl.removeSubrange(range)
                    profileImageUrl.append("_bigger.jpg")
                }
            }
        }
        return profileImageUrl
    }
    
    //we need to ad an array of rightBarButtonItems
    func setUpMenuButton(){
        let writeButton = UIButton(type: .custom)
        writeButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        writeButton.setImage(UIImage(named:"realWriteIcon"), for: .normal)
        let tapGestureRecognizerWrite = UITapGestureRecognizer(target: self, action: #selector(goToWrite(tapGestureRecognizer:)))
        writeButton.isUserInteractionEnabled = true
        writeButton.addGestureRecognizer(tapGestureRecognizerWrite)
        let writeBarItem = UIBarButtonItem(customView: writeButton)
        let currWidth = writeBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = writeBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        let blankButton = UIButton(type: .custom)
        blankButton.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 10)
        let blankBarItem = UIBarButtonItem(customView: blankButton)
        let currWidth3 = blankBarItem.customView?.widthAnchor.constraint(equalToConstant: 12)
        currWidth3?.isActive = true
        let currHeight3 = blankBarItem.customView?.heightAnchor.constraint(equalToConstant: 12)
        currHeight3?.isActive = true
        
        let reloadButton = UIButton(type: .custom)
        reloadButton.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        reloadButton.setImage(UIImage(named:"reload"), for: .normal)
        let tapGestureRecognizerReload = UITapGestureRecognizer(target: self, action: #selector(reloadButtonFunc(tapGestureRecognizer:)))
        reloadButton.isUserInteractionEnabled = true
        reloadButton.addGestureRecognizer(tapGestureRecognizerReload)
        let reloadBarItem = UIBarButtonItem(customView: reloadButton)
        let currWidth2 = reloadBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth2?.isActive = true
        let currHeight2 = reloadBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight2?.isActive = true
        self.navigationItem.rightBarButtonItems = [writeBarItem, blankBarItem, reloadBarItem]
        
        let menuButton = UIButton(type: .custom)
        menuButton.frame = CGRect(x: 0.0, y: 0.0, width: 1, height: 1)
        menuButton.setImage(UIImage(named:"menu_icon"), for: .normal)
        let tapGestureRecognizerMenu = UITapGestureRecognizer(target: self, action: #selector(goMenuClick(tapGestureRecognizer:)))
        menuButton.isUserInteractionEnabled = true
        menuButton.addGestureRecognizer(tapGestureRecognizerMenu)
        let menuBarItem = UIBarButtonItem(customView: menuButton)
        let menuWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 36)
        menuWidth?.isActive = true
        let menuHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 36)
        menuHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc private func goToWrite(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let writeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        navigationController?.pushViewController(writeViewController, animated: true)
        print("goin to write")
    }
    
    @objc private func reloadButtonFunc(tapGestureRecognizer: UITapGestureRecognizer)
    {
        clearOutAndRefresh()
    }
    
    @objc private func goMenuClick(tapGestureRecognizer: UITapGestureRecognizer) {
        toggleDrawer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oh Aight", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func webView(webView: UIWebView!, didFailLoadWithError error: Error!) {
        print("Webview fail with error \(error)");
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Webview started Loading")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Webview did finish load")
    }
    
    
}

//
//  RealProfilePage.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 5/2/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import UIKit
import SwifteriOS
import Locksmith
import SDWebImage
import SJFluidSegmentedControl
import CollieGallery
//https://michiganlabs.com/ios/development/2016/05/31/ios-animating-uitableview-header/
class ProfilePage2: BaseViewController, UIScrollViewDelegate,  UIWebViewDelegate, UIGestureRecognizerDelegate, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate, CollieGalleryDelegate, CustomCellUpdater, LatestCellDelegator, EraseCellDelegate {

    
    
    
    enum TimelineEnum {
        case `default`
        case timeline
        case mentions
        case likes
        
        var stringValue: String? {
            switch self {
            case .default:
                return nil
            case .mentions:
                return "mentions"
            case .timeline:
                return "timeline"
            case .likes:
                return "likes"
            }
        }
    }
    
    @IBOutlet weak var fullNameHead: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameHead: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImageHead: UIImageView!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var follow: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var lowerBackground: UIView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var statusesCount: UILabel!
    @IBOutlet weak var fancySegmentedControl: SJFluidSegmentedControl!
    
    var titleView = UILabel()
    
    @IBAction func followAction(_ sender: Any) {
        doFriendRequest()
    }
    
    weak var profileCollieDelegate: CollieGalleryDelegate!
    
    var OneExpandedProfPic = [CollieGalleryPicture]()
    var username: String?
    let maxHeaderHeight: CGFloat = 160;
    let minHeaderHeight: CGFloat = 40;
    var previousScrollOffset: CGFloat = 0
    
    
    let calendar = Calendar.current
    let currentDateTime = Date()
    
    var enteredThePage = false
    var enteredTimeline = false
    var enteredMentions = false
    var enteredLikes = false
    
    
    var userId: String?//for dumb__username: 24218899

    private var tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    var swifter: Swifter?
    
    var functionJson: JSON = [:]
    
    //var tweetsJsonArray : [JSON] = []
    var changeableTweetsArray: [LatestStatus] = []
    
    private let vw = UIView()
    private var twitterWebview : UIWebView?
    private var blurEffectView: UIVisualEffectView?
    private var backgroundIsBlurred = false
    var currentTime = TimeInterval()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 8.2, *) {
            fancySegmentedControl.textFont = .systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        } else {
            fancySegmentedControl.textFont = .boldSystemFont(ofSize: 12)
        }
        fancySegmentedControl.currentSegment = 1
        
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView?.register(UINib(nibName: "FreeCell", bundle: nil), forCellReuseIdentifier: "FreeCell")
        
        profileCollieDelegate = self
        setUpMenuButton()
        
        self.swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY, oauthToken: tokenDictionary!["accessTokenKey"] as! String, oauthTokenSecret: tokenDictionary!["accessTokenSecret"] as! String)
        
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with you network 😕. ", self.username)
            
        }
        
        let viewDidLoadDispatch = DispatchGroup()
        
        viewDidLoadDispatch.enter()
        
        if (username == nil ){
            swifter?.showUser(UserTag.id(userId!), includeEntities: true, success: { json in
                self.hydrateProfView(json: json)
                viewDidLoadDispatch.leave()
            }, failure: failureHandler)
            
        }else {
            swifter?.showUser(UserTag.screenName(username!), includeEntities: true, success: { json in
                //  print("json.array ", json)
                
                self.hydrateProfView(json: json)
                viewDidLoadDispatch.leave()
            }, failure: failureHandler)
        }
        
        viewDidLoadDispatch.notify(queue: .main) {
            self.finishedHead()
        }
        initNavigationItemTitleView()
    }
    
    private func initNavigationItemTitleView() {
        
        titleView.text = "   Straight Up!"
        titleView.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc private func titleWasTapped() {
        scrollToFirstRow()
    }
    
    
    func finishedHead (){
        firstTimeViewDidLoad()
        
        let galleryTapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(profileImageClick(galleryTapGestureRecog:)))
        profileImageHead?.isUserInteractionEnabled = true
        profileImageHead?.addGestureRecognizer(galleryTapGestureRecog)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        currentTime = Date().timeIntervalSinceReferenceDate
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        enteredThePage = false
    }
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 3
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
        if (fromIndex != 0 && toIndex == 0) {
            if (username != nil){
                expandHeader()
                // if viewWillAppearTime - viewDidAppearTime > 30.0 then do the beginAbstractFetch
                beginAbstractFetch(timelineType: TimelineEnum.mentions.stringValue!)
            }
        } else if (fromIndex != 1 && toIndex == 1) {
            expandHeader()
            beginAbstractFetch(timelineType: TimelineEnum.timeline.stringValue!)
        } else if (fromIndex != 2 && toIndex == 2) {
            expandHeader()
            beginAbstractFetch(timelineType: TimelineEnum.likes.stringValue!)
        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "Mentions"
        } else if index == 1 {
            return "Timeline"
        } else if index == 2 {
            return "Likes"
        }
        return "Timeline"
    }
    
    private func firstTimeViewDidLoad () {
        //if there the token/secret is incorrect this will cause an error and not allow the user to log in. fix this. access token and oathtoken are the same thing fyi
        if (tokenDictionary != nil){
            if (self.swifter == nil) {
                print("the account is nil!")
            }else{
                print("the account is NOT nil!")
                //the parameter is the default timeline when you enter the page for the first time
                beginAbstractFetch(timelineType: TimelineEnum.timeline.stringValue!)
            }
            
        }else {
            // toggleDrawer()
        }
    }
    
    func beginAbstractFetch (timelineType: String)  {
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with you network 😕. ", error.localizedDescription)
            if (error.localizedDescription.contains("You might be connecting to a server that is pretending")){
                self.alert(title: "Watch your back...", message: "Aight so boom...the network you're on has strict security rules, might be watched and is blocking Twitter 👀")
            } else {
                self.alert(title: "Damn...", message: "Yeaaa...so theres a problem with you network 😕.")
            }
            self.dismissLoadingGIF()
        }
        
        let abstractDispatch = DispatchGroup()
        
        abstractDispatch.enter()
        self.displayLoadingGIF()
        if (timelineType == TimelineEnum.mentions.stringValue) {
            
            self.swifter?.searchTweet(using: username!, geocode: nil, lang: nil, locale: nil, resultType: nil, count: 50, until: nil, sinceID: nil, maxID: nil, includeEntities: true, callback: "", tweetMode: TweetMode.extended, success: {(mentionsSearchJson: JSON, uselessMeta: JSON?) in
                self.fancySegmentedControl.alpha = 1.0
                self.functionJson = [:]
                self.functionJson = mentionsSearchJson
                
                abstractDispatch.leave()
            }, failure: failureHandler)
            
        }else if (timelineType == TimelineEnum.timeline.stringValue) {
            self.swifter?.getTimeline(for: userId!, count: 60, sinceID: nil, maxID: nil, trimUser: false, contributorDetails: true, includeEntities: true, tweetMode: TweetMode.extended, success: { json in
                self.fancySegmentedControl.alpha = 1.0
                self.functionJson = [:]
                self.functionJson = json
                
                abstractDispatch.leave()
            }, failure: failureHandler)
            
        }else if (timelineType == TimelineEnum.likes.stringValue){
            self.swifter?.getRecentlyFavoritedTweets(for: UserTag.id(userId!), count: 20, sinceID: nil, maxID: nil, tweetMode: TweetMode.extended, success:{ json in
                self.fancySegmentedControl.alpha = 1.0
                self.functionJson = [:]
                self.functionJson = json
                
                abstractDispatch.leave()
            }, failure: failureHandler)
        }
        
        
        abstractDispatch.notify(queue: .main) {
            if (self.functionJson.array?.count != nil && (self.functionJson.array?.count as! Int) > 0){
                
                self.fetchTimelineFunction()
            }else{
                self.changeableTweetsArray.removeAll()
                self.profileTableView.reloadData()
                self.dismissLoadingGIF()
            }
        }
    }
    
    func doFriendRequest (){
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with the network 😕.")
            self.alert(title: "It's not you, it's me...", message: "Network problem, couldn't become friends 😕. \(error.localizedDescription)")
        }
        //swifter?.followUser(UserTag.id(userId!))
        self.swifter?.followUser(UserTag.id(userId!), follow: true, success: { json in
            print("follow user", json)
            self.alert(title: "BFFL", message: "You're now frineds")
            
        }, failure: failureHandler)
    }
    
    func fetchTimelineFunction() {
        
        changeableTweetsArray = []
        guard let tweets = self.functionJson.array else { return }
        // print("abstract: ", tweets)
        
        for var tweet in tweets {
            
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
            
            //print("number of gotten tweets  \(tweets.count)")
            
            var profileImage = tweet["user"]["profile_image_url_https"].string
            profileImage =  self.getHighDefPic(lowDefProfileUrl: profileImage!)
            var text = tweet["full_text"].string
            let username = tweet["user"]["screen_name"].string
            let fullname = tweet["user"]["name"].string
            let favoriteCount = tweet["favorite_count"].integer
            let retweetCount = tweet["retweet_count"].integer
            let tweetId = tweet["id_str"].string
            let userId = tweet["user"]["id_str"].string
            let didFavorite = tweet["favorited"].bool
            let didRetweet = tweet["retweeted"].bool
            var gifString: String? = nil
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
            var RThasGif: Bool = false
            
            let tempTimestamp = tweet["created_at"].string
            var nsTimestamp = self.parseTweetTimestamp(timestamp: tempTimestamp!)
            var dateTimestamp = nsTimestamp! as Date
            let timeStamp = dateTimestamp.timeAgoDisplay()
            
            var mediaString0: String? = nil
            var mediaString1: String? = nil
            var mediaString2: String? = nil
            var mediaString3: String? = nil
            

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
                                    RThasGif = true
                                }
                                if let gifStringZero = smallJson[0]["video_info"].object {
                                    for gifInfo in gifStringZero {
                                        if (gifInfo.key == "variants") {
                                            RTgifString = gifInfo.value[0]["url"].string
                                            //  print("gifStringZero: ", gifString!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                print ("quoteben ", RTText!, "--", RTFullName!, "--", RTUsername!, "--", RTmediaString0, "--", RTmediaString1)
            }
            
            
            if tweet["retweeted_status"].string != nil{
                text = ("RETWEET: \(text!)")
                isARetweet = true
                isAQuote = false
            }
            
            if let regularUrlString = tweet["entities"].object {
                for myEntry in regularUrlString {
                    if (myEntry.key == "urls") {
                        let smallJson = myEntry.value
                        if let urlStringZero = smallJson[0]["expanded_url"].string {
                            print("urlStringzero: ", urlStringZero)
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
                    // print("this is entities: \(urlString)")
                    for myEntry in urlString {
                        if (myEntry.key == "media") {
                            let smallJson = myEntry.value
                            
                            if (smallJson[0]["type"].string == "photo") {
                                if let mediaStringZero = smallJson[0]["media_url_https"].string {
                                    mediaString0 = mediaStringZero
                                    // print("media string0: ", mediaStringZero)
                                }
                                if let mediaStringOne = smallJson[1]["media_url_https"].string {
                                    mediaString1 = mediaStringOne
                                    // print("media string1: ", mediaStringOne)
                                }
                                if let mediaStringTwo = smallJson[2]["media_url_https"].string {
                                    mediaString2 = mediaStringTwo
                                    // print("media string2: ", mediaStringTwo )
                                }
                                if let mediaStringThree = smallJson[3]["media_url_https"].string {
                                    mediaString3 = mediaStringThree
                                    // print("media string3: ", mediaStringThree )
                                }
                                
                            }else if (smallJson[0]["type"].string == "animated_gif" || smallJson[0]["type"].string == "video"){
                                //if let gifStringZero = smallJson[0]["media_url_https"].string {
                                if(smallJson[0]["type"].string == "animated_gif"){
                                    hasGif = true
                                }
                                if let gifStringZero = smallJson[0]["video_info"].object {
                                    // gifString = gifStringZero
                                    for gifInfo in gifStringZero {
                                        if (gifInfo.key == "variants") {
                                            gifString = gifInfo.value[0]["url"].string
                                            //  print("gifStringZero: ", gifString!)
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
            
            //to change the look of a tweet based on its info (retweet, private user etc) make a bool for that info in Homtstatus, then in
            //tweeCell.swift use that bool value to change the look.
            
            let thisHomestatus = LatestStatus(userId: userId!, textTweet: String (describing: text!), profileImageUrl: profileImage!, gifImageViewUrl: gifString, regularUrl: regularString, hasGif: hasGif, statusImageUrl0: mediaString0, statusImageUrl1: mediaString1, statusImageUrl2: mediaString2, statusImageUrl3: mediaString3, textFullName: fullname!, textUsername: username!, likeCount: String (describing: favoriteCount!), retweetCount: String (describing: retweetCount!), tweetId: tweetId!, didFavorite: didFavorite, didRetweet: didRetweet, timeStamp: timeStamp, retweetedBy: retweetedBy, isARetweet: isARetweet, isAQuote: isAQuote, RTUsername: RTUsername, RTFullName: RTFullName, RTText: RTText, RTgifString: RTgifString, RTmediaString0: RTmediaString0, RTmediaString1: RTmediaString1, RTmediaString2: RTmediaString2, RTmediaString3: RTmediaString3)
            
            //smallLatestStatuses.append(thisHomestatus)
            self.changeableTweetsArray.append(thisHomestatus)
            
            gifString = ""
            regularString = ""
            mediaString0 = ""
            mediaString1 = ""
            mediaString2 = ""
            mediaString3  = ""
            
        }
        self.refreshUI()
        self.dismissLoadingGIF()
    }
    
    func hydrateProfView(json: JSON){
        
        if let name = json["name"].string {
            //  print("json.array ", json)
            var newName = name
            if (newName.count > 20){
                newName = newName.substring(to:newName.index(name.startIndex, offsetBy: 20))
                newName = newName + "..."
            }
            fullNameHead.text = name
            //mainFullName.text = newName
        }
        if let screenName = json["screen_name"].string {
            usernameHead.text = "@\(screenName)"
            self.username = usernameHead.text
            //titleView.text = usernameHead.text
        }
        
        if let id = json["id_str"].string{
            print("working id ",id)
            self.userId = id
        }
        
        if let followingCount = json["friends_count"].integer{
            follow.text = "Following \(followingCount)"
        }
        
        if let followersCount = json["followers_count"].integer{
            following.text =  "\(followersCount) Followers"
        }
        
        if let statuses_count = json["statuses_count"].integer{
            statusesCount.text = "\(statuses_count) Tweets"
        }
        
        if let thisBio = json["description"].string {
            bio.text = thisBio
        }
        
        if var profileImageUrl = json["profile_image_url_https"].string {
            var ultraDefUrl: String = ""
            if (profileImageUrl.hasSuffix(".jpg")){
                if let range = profileImageUrl.range(of: "_normal.jpg") {
                    profileImageUrl.removeSubrange(range)
                    ultraDefUrl = profileImageUrl// gets naked version of url
                    profileImageUrl.append("_bigger.jpg")
                }
            }
            profileImageHead.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "default_profile_.png"))
            ultraDefUrl.append(".jpg")
            let picture = CollieGalleryPicture(url: ultraDefUrl)
            OneExpandedProfPic.append(picture)
        }
        
        if let backgroundImageUrl = json["profile_banner_url"].string {
            logoImageView?.contentMode = UIViewContentMode.scaleAspectFill
            // headerImageView.sd_setImage(with: URL(string: backgroundImageUrl), placeholderImage: UIImage(named: "header_bg"))
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: backgroundImageUrl), options: SDWebImageDownloaderOptions.allowInvalidSSLCertificates, progress: { (min, max, url) in
                //   print("loading……")
            }, completed: { (image, data, error, finished) in
                if image != nil {
                    self.logoImageView?.image = image
                    self.logoImageView?.contentMode = UIViewContentMode.scaleAspectFill
                    
                } else {
                    print("did not load image in profileview")
                }
            })
        }
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
    
    @objc func profileImageClick(galleryTapGestureRecog: UITapGestureRecognizer)
    {
        let options = CollieGalleryOptions()
        options.parallaxFactor = 0.8
        options.maximumZoomScale = 2.5
        // options.gapBetweenPages = 20
        let gallery = CollieGallery(pictures: OneExpandedProfPic, options: options)
        if (profileCollieDelegate != nil){
            profileCollieDelegate?.gallery!(gallery, indexChangedTo: 0)
        }
    }
    
    func refreshUI() {
        DispatchQueue.main.async{
            // self.reusableTableView = ReusableTableView(self.profileTableview, self.changeableTweetsArray, self)
            self.profileTableView.reloadData()
            
            let scrollDispatch = DispatchGroup()
            
            for i in 0 ..< 1 {
                scrollDispatch.enter()
                self.expandHeader()
                scrollDispatch.leave()
            }
            
            scrollDispatch.notify(queue: .main) {
                self.scrollToFirstRow()
                self.expandHeader()
                self.dismissLoadingGIF()
            }
        }
        self.dismissLoadingGIF()
    }
    
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        profileTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func gallery(_ gallery: CollieGallery, indexChangedTo index: Int) {
        gallery.presentInViewController(self)
        print("stack this is happening in profilepage view")
    }
    
    func parseTweetTimestamp(timestamp: String) -> NSDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier:"en_US") as Locale!
        dateFormatter.dateStyle = .long
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return dateFormatter.date(from: timestamp) as! NSDate
    }
    
    
    func showTwitterSite(tweetId: String) {
        if (!backgroundIsBlurred) {
            blurBackground()
        }
        twitterWebview = UIWebView(frame: CGRect(origin: CGPoint(x: 0, y : 0), size: CGSize(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.15), height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.3) )))
        twitterWebview?.center =  CGPoint(x: self.view.center.x, y: self.view.center.y)
        twitterWebview?.alpha = 0.9
        //twitterWebview?.layer.cornerRadius = 10
        twitterWebview?.tag = 101
        
        UIApplication.shared.keyWindow?.addSubview(twitterWebview!)
        
        //self.view.addSubview(webV)
        twitterWebview?.delegate = self //as UIWebViewDelegate;
        let subviewUrl = URL (string: "https://twitter.com/blah/status/\(tweetId)")
        let myURLRequest:URLRequest = URLRequest(url: subviewUrl!)
        twitterWebview?.loadRequest(myURLRequest)
        print("show twitter web view: \(tweetId)")
    }
    
    func blurBackground () {
        if (!backgroundIsBlurred) {
            profileTableView?.isScrollEnabled = false
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView?.alpha = 0
            blurEffectView?.tag = 102
            blurEffectView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            UIApplication.shared.keyWindow?.addSubview(blurEffectView!)
            UIView.animate(withDuration: 0.3){
                self.blurEffectView?.alpha = 0.90
            }
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.bigButtonTapped(gestureRecognizer:)))
            gestureRecognizer.delegate = self
            blurEffectView?.addGestureRecognizer(gestureRecognizer)
            backgroundIsBlurred = true
        }
    }
    
    @objc func bigButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("blur tapped")
        if let webviewWithTag = UIApplication.shared.keyWindow?.viewWithTag(101) {
            webviewWithTag.removeFromSuperview()
        }
        
        if let blurWithTag = UIApplication.shared.keyWindow?.viewWithTag(102){
            blurWithTag.removeFromSuperview()
            profileTableView?.isScrollEnabled = true
        }
        
        //        if(twitterWebview?.canGoBack)! {
        //            //Go back in webview history
        //            twitterWebview?.goBack()
        //        } else {
        //            //Pop view controller to preview view controller
        //            self.navigationController?.popViewController(animated: true)
        //        }
        backgroundIsBlurred = false
    }
    
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
        self.navigationItem.rightBarButtonItem = writeBarItem
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oh Aight", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func goToWrite(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let writeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.initUsername = self.username
        navigationController?.pushViewController(writeViewController, animated: true)
        print("goin to write")
    }
    
    func goToProfNaked(userId dataobjectUID: String) {
        //self.performSegueWithIdentifier("showComments", sender:dataobject )
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.username = dataobjectUID
        
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        print("going to profile in prof...naked ")
    }
    
    func goToProfilePage(userID dataobjectUID: String, profileImage dataProfileImage: UIImageView) {
        //self.performSegueWithIdentifier("showComments", sender:dataobject )
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.userId = dataobjectUID
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        print("going to profile in profile..profileimage")
    }
    
    
    func goReplyToTweet(tweetID dataTweetID: String) {
        let writeViewController = storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.tweetID = dataTweetID
        self.navigationController?.pushViewController(writeViewController, animated: true)
        print("empty reply to tweet")
    }
    
    func goQuoteTweet(tweetText dataTweetText: String, username dataUsername: String) {
        let writeViewController = storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.initTweetText = dataTweetText
        writeViewController.initUsername = dataUsername
        
        self.navigationController?.pushViewController(writeViewController, animated: true)
        print("empty reply to tweet")
    }
    
    func linkCallBack (string:String, wordType:wordType, tweetId:String){
        print("received string: ", string)
        if wordType == .hashtag {
            print("going to hashtag vc")
        } else  if wordType == .mention {
            print("going to atName vc")
            goToProfNaked(userId: string)
        } else {
            print("going to plain text: ", tweetId)
            showTwitterSite(tweetId: tweetId)
        }
    }
    
    func updateTableView() {
        profileTableView?.reloadData()
        print("reloading tableview inside of Reusable tableview")
    }
    
    func blockButtonTapped(cell: LatestCell) {
        guard let indexPath = self.profileTableView?.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            print("should not be happening")
            return
        }
        print("Button tapped on row \(indexPath.row)")
        self.changeableTweetsArray.remove(at: indexPath.row)
        self.profileTableView?.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
    }
}



extension ProfilePage2: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.setScrollPosition(position: self.previousScrollOffset)
            }
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    //
    //HELPER FUNCTIONS
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    func setScrollPosition(position: CGFloat) {
        self.profileTableView.contentOffset = CGPoint(x: self.profileTableView.contentOffset.x, y: position)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // scrolling has stopped
        scrollViewDidStopScrolling()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // scrolling has stopped
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            expandHeader()
            self.headerHeightConstraint.constant = self.maxHeaderHeight
        } else {
            // collapse header
            collapseHeader()
            self.headerHeightConstraint.constant = self.minHeaderHeight
        }
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            // Manipulate UI elements within the header here
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            // Manipulate UI elements within the header here
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range//percentage will be zero when the header is collapsed
        
        //self.titleTopConstraint.constant = -openAmount + 10
        self.logoImageView.alpha = max (percentage, 0.8)
        //make most of the header disappear
        self.usernameHead.alpha = percentage
        self.followButton.alpha = percentage
        profileImageHead.alpha = min(percentage , 0.9)
        bio.alpha = percentage
        follow.alpha = percentage
        lowerBackground.alpha = min(percentage , 0.8)
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return changeableTweetsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = changeableTweetsArray[indexPath.row]
        
        let myTweetId = data.tweetId
        let myTweet = data.textTweet
        print("tweet id is: \(myTweetId!). tweet is: \(myTweet!)")
        showTwitterSite(tweetId: myTweetId!)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        let slideTransfrom = CATransform3DTranslate(CATransform3DIdentity, -75, 0, 0)
        cell.layer.transform = slideTransfrom
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
    func tableView(_ tableview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = changeableTweetsArray[indexPath.row]
        
        let cell = profileTableView.dequeueReusableCell(withIdentifier: "FreeCell", for: indexPath) as! LatestCell
        cell.separatorInset = UIEdgeInsets.zero;
        cell.latestStatus = changeableTweetsArray[indexPath.row]
        
        cell.updateButtons()
        cell.likeButton.tag = indexPath.row
        if ReusableTableView.favoriteSelected[indexPath.row] {
            cell.likeButton.setImage(UIImage(named: "icon-heart-teal"), for: .normal)
            cell.likeButton.alpha = 1.0
            cell.likeButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
        }
        cell.retweetButton.tag = indexPath.row
        if ReusableTableView.retweetSelected[indexPath.row] {
            cell.retweetButton.setImage(UIImage(named: "icon-retweet-teal"), for: .normal)
            cell.retweetButton.alpha = 1.0
            cell.retweetButton.setTitleColor(AppConstants.tweeterDarkGreen, for: .normal)
        }
        
        cell.cellLatestTweet.setText(status: (cell.latestStatus)!,
                                     withHashtagColor: AppConstants.tweeterDarkGreen,
                                     andMentionColor: AppConstants.tweeterDarkGreen,
                                     andCallBack: linkCallBack,
                                     normalFont: UIFont.systemFont(ofSize: 15),
                                     hashTagFont: UIFont.systemFont(ofSize: 15),
                                     mentionFont: UIFont.systemFont(ofSize: 15))
        cell.cellLatestTweet.dataDetectorTypes = UIDataDetectorTypes.link
        cell.cellLatestTweet.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: AppConstants.tweeterDarkGreen]
        cell.delegate = self
        cell.collieDelegate = self
        
        cell.update(data)
        return cell
    }
}


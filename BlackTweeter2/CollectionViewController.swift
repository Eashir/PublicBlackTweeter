//
//  CollectionViewController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 4/13/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import UIKit
import SwifteriOS
import FirebaseDatabase
import Locksmith
import SafariServices
import AVFoundation
import CollieGallery
//import GoogleMobileAds

class CollectionViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate {
    
    // @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var labelBackground: UIView!
    @IBOutlet weak var theTableview: UITableView!
    var reusableTableView: ReusableTableView!
    var mainCount: Int = 0
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var mMenuButton: UIBarButtonItem!
    var selectedCell = UICollectionViewCell()
    var statusesForThisCategory: [LatestStatus] = []
    var inTheCollectionView = true
    
    var currentCategory = ""
    var firebaseDictionary = [String: FBCategory]()
    var twitterDictionary = [String: [LatestStatus]]()
    var fBKeyStringArray = [String]()
    var firstFirebaseCategory: String?
    var changingFirebaseCount: Int = 5
    
    let infiniteCount = 6
    var timer: Timer?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref : DatabaseReference!
    var versionRef: DatabaseReference!
    var hardVersion: Int = 1
    
    private var tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
    
    var universalWasOpen: Bool = false
    
    var avPlayerLayer: AVPlayerLayer!
    var firstLoad = true
    var visibleIP : IndexPath?
    
    var swifter: Swifter?
   
    private let reuseIdentifier = "collectionCell"
    var changeableTweetsArray: [LatestStatus]?
    static var allowedToReload = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
        theTableview.isScrollEnabled = true
        print("collection view visible")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (tokenDictionary != nil){
            self.displayLoadingGIF()
        }
        
        self.tabBarController?.delegate = self as UITabBarControllerDelegate
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        //        let request = GADRequest ()
        //        request.testDevices = [kGADSimulatorID]
        //        bannerView.delegate = self
        //        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //MAKE SURE TO CHANGE THIS FOR THE PRODUCTION VERSION!!!!
        //        bannerView.rootViewController = self
        //        bannerView.load(request)
        
        labelBackground.layer.cornerRadius = 16
        
        pureReload()
        
        self.startTimer()
        setUpMenuButton()
        initNavigationItemTitleView()
        //NotificationCenter.default.addObserver(self, selector: #selector(CollectionViewController.objcPureReload), name: NSNotification.Name(rawValue: "collectionReload"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("leaving collection view")
    }
    
    private func initNavigationItemTitleView() {
        let titleView = UILabel()
        titleView.text = "BlackTweeter ✊🏾"
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc private func titleWasTapped() {
        self.scrollToFirstRow()
    }
    
    @objc func objcPureReload () {
        pureReload()
    }
    
    
    func pureReload() {
        if (CollectionViewController.allowedToReload){
            CollectionViewController.allowedToReload = false
            

           // versionRef = Database.database().reference().child("Version")
            versionRef = Database.database().reference().child("VersionApple")
            versionRef.observe(.value, with: {(versionSnap) in
                if (versionSnap.value == nil) {
                    print("no value!")
                    CollectionViewController.allowedToReload = true
                } else if (versionSnap.value as! Int == self.hardVersion){
                    self.ref = Database.database().reference().child("TheLatest")
                    self.ref.observe(.value, with: {(allCategoriesSnap) in
                        self.statusesForThisCategory.removeAll()
                        self.statusesForThisCategory = []
                        self.twitterDictionary.removeAll()
                        self.twitterDictionary = [:]
                        self.firebaseDictionary.removeAll()
                        self.firebaseDictionary = [:]
                        self.brainsForViewDidLoad(theData: allCategoriesSnap.children.allObjects as! [DataSnapshot])
                        //self.refreshUI()
                        self.mainCollectionView.reloadData()
                    })
                } else {
                    self.alert(title: "Out of Date", message: "Aye go to the App Store and get the latest version for me")
                    CollectionViewController.allowedToReload = true
                }
            })
        }
    }
    


    
    //    @objc func tap() {
    //
    //        if (ReusableTableView.profTableviewScrolled == true) {
    //        count = count + 1
    //        print("tap \(count)")
    //        scrollToFirstRow()
    //        ReusableTableView.profTableviewScrolled = false
    //        }
    //    }
    
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
    
    @objc func goToWrite(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let writeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        navigationController?.pushViewController(writeViewController, animated: true)
        print("goin to write")
    }
    
    @objc func reloadButtonFunc(tapGestureRecognizer: UITapGestureRecognizer)
    {
        pureReload()
    }
    
    @objc func goMenuClick(tapGestureRecognizer: UITapGestureRecognizer) {
        toggleDrawer()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (firebaseDictionary.count == 0 ) {
            return 0
        }else{
            return infiniteCount * firebaseDictionary.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
     
        var valueArrayFBC = Array(firebaseDictionary.values)
        
        changingFirebaseCount = firebaseDictionary.count //same as categoryArray.count
        //rearrange data
        valueArrayFBC = valueArrayFBC.sorted(by: { $0.orderNumber! < $1.orderNumber! })
        fBKeyStringArray = []
        
        for firebaseCategory in valueArrayFBC {
            fBKeyStringArray.append(firebaseCategory.name!)
        }
        
        //firebaseCategory can be reused cause they are not the same. they are in different scopes.
        
        firebaseDictionary = [:]
        
        for var firebaseCategory in valueArrayFBC {
            firebaseCategory.tweetArray = firebaseCategory.tweetArray?.sorted(by: { $0.order! < $1.order! })
            firebaseDictionary[firebaseCategory.name!] = firebaseCategory
        }
        
        firstFirebaseCategory = fBKeyStringArray.first
        if (currentCategory == "") {
            currentCategory = firstFirebaseCategory!
            categoryLabel.text = firstFirebaseCategory!
        }
        let itemIndex = indexPath.item % changingFirebaseCount
        //var selectedCategory = categoryArray[indexPath.row % changingFirebaseCount]
        
        //  print("value array ", valueArray[itemIndex].pictureUrl!)
        
        cell.collectionLabel?.text = valueArrayFBC[itemIndex].name//value array has been rearrangned
        cell.categoryPic.sd_setImage(with: URL(string: valueArrayFBC[itemIndex].pictureUrl!), placeholderImage: UIImage(named: "default_profile_.png"))
        
        if (cell.collectionLabel?.text == currentCategory){
            cell.alpha = 1
        }else{
            cell.alpha = 0.7
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(CollectionViewController.allowedToReload){
        var categoryArray = fBKeyStringArray
        let selectedCategory = categoryArray[indexPath.row % changingFirebaseCount]
        categoryLabel.text = selectedCategory
        
        print("selected category: ", selectedCategory)
        
        let test1 = self.firebaseDictionary[selectedCategory]?.tweetArray
        self.changeableTweetsArray = []
        for eachFBtweet in test1! {
            self.changeableTweetsArray?.append(eachFBtweet.status!)
        }
        
        self.reusableTableView = ReusableTableView(theTableview, changeableTweetsArray!, self)
        self.reusableTableView.tableView?.reloadData()
        self.scrollToFirstRow()
        
        let cellForAlpha = self.mainCollectionView.cellForItem(at: indexPath)
        cellForAlpha?.alpha = 1
        //cellForAlpha?.backgroundView = bgColorView// this never deselects
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            cell.alpha = 1.0
        } else {
            cell.alpha = 0.7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cellForAlpha = self.mainCollectionView.cellForItem(at: indexPath)
        cellForAlpha?.alpha = 0.7
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return mainCollectionView.bounds.size
    }
    
    // -------------------------------------------------------------------------------
    //    Infinite Scroll Controls
    // -------------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.centerIfNeeded()
    }
    
     func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        print(tabBarIndex)
        print("this is where 0happens")
        let indexPath = IndexPath(row: 0, section: 0)
        theTableview.scrollToRow(at: indexPath, at: .top, animated: true)
        
//        if tabBarIndex == 0 {
//            //self.theTableview.setContentOffset(CGPoint.zero, animated: true)
//            self.scrollToFirstRow()
//        }
    }

    
    func centerIfNeeded() {
        let currentOffset = mainCollectionView.contentOffset
        let contentWidth = self.totalContentWidth
        let width = contentWidth / CGFloat(infiniteCount)
        
        if 0 > currentOffset.x {
            //left scrolling
            mainCollectionView.contentOffset = CGPoint(x: width - currentOffset.x, y: currentOffset.y)
            
        } else if (currentOffset.x + cellWidth) > contentWidth {
            //right scrolling
            let difference = (currentOffset.x + cellWidth) - contentWidth
            mainCollectionView.contentOffset = CGPoint(x: width - (cellWidth + difference), y: currentOffset.y)
            
        }
    }
    
    var totalContentWidth: CGFloat {
        return CGFloat(changingFirebaseCount * infiniteCount) * cellWidth
    }
    
    var cellWidth: CGFloat {
        return mainCollectionView.frame.width
    }
    
    
    // -------------------------------------------------------------------------------
    //    Timer Controls
    // -------------------------------------------------------------------------------
    func startTimer() {
        if changingFirebaseCount > 1 && timer == nil {
            let timeInterval = 20.0;
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(CollectionViewController.rotate), userInfo: nil, repeats: true)
            timer!.fireDate = NSDate().addingTimeInterval(timeInterval) as Date
        }
    }
    
    func stopTimer() {
        if (timer != nil){
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func rotate() {
        mainCount =  mainCount + 1
        if (mainCount >= 3){
            stopTimer()
        } else {
            let offset = CGPoint(x: mainCollectionView.contentOffset.x + cellWidth, y: mainCollectionView.contentOffset.y)
            mainCollectionView.setContentOffset(offset, animated: true)
        }

    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
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
    
    
    
    func getCompleteNumberOfCategories () -> Int{
        if (firebaseDictionary.count == 0 ) {
            return 0
        }else{
            return infiniteCount * firebaseDictionary.count
        }
    }
    
    func brainsForViewDidLoad (theData: [DataSnapshot]) {
        //this is done when user is logged out and then he closes the drawer, to avoid crashes
        if (universalWasOpen &&  tokenDictionary == nil) {
            //this only happens when we have to load it up for th first time after login
            print("drawer was open AND token is nil now setting the data and reloading ")
            tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
            CollectionViewController.allowedToReload = true
            pureReload()
            return
        }
        if (tokenDictionary == nil){
            //Cmd+Ctrl+Space to add emoji
            self.alert(title: "Hey What's Up", message: "Select 'LOG INTO TWITTER' for me and let's get started")
            toggleDrawer()
        }
        
        let firebaseDispatch = DispatchGroup()
        // https://stackoverflow.com/questions/40980821/firebase-swift-3-xcode-8-iterate-through-observe-results
        
        
        for i in 0 ..< 1 {
            firebaseDispatch.enter()
            //actually start to get viable firebase data
            if (self.tokenDictionary != nil){
                // self.displayLoadingGIF()
            }
            //for category in allCategoriesSnap.children.allObjects as! [DataSnapshot] { //category is ONE entire category, allCategoriesSnap is actually the entire "TheLatest"
            for category in theData {
                
                var fbCategory = FBCategory()
                fbCategory.name = category.key
                print("each category: ", fbCategory.name!)
                
                var fbTweetArray: [FBTweet] = []
                
                for categoryMetaData in category.children.allObjects as! [DataSnapshot] {//for every meta data of this category (picture, order, tweet...)
                    
                    if (categoryMetaData.key.hasPrefix("tweet") ){
                        var fbTweet = FBTweet()
                        for tweetMetaData in categoryMetaData.children.allObjects as! [DataSnapshot] {
                            if (tweetMetaData.key.hasPrefix("url")){
                                if let actualTweet = tweetMetaData.value as? Int {
                                    fbTweet.tweetId = String (actualTweet)
                                }
                                else if let actualTweet = tweetMetaData.value as? String {
                                    fbTweet.tweetId = URL(fileURLWithPath: actualTweet).lastPathComponent//lastPathComponent will get the end of the url aka the tweet id
                                }
                            }
                            if (tweetMetaData.key.hasPrefix("tweet_order")){
                                fbTweet.order = tweetMetaData.value as? Int
                            }
                        }
                        fbTweetArray.append(fbTweet)
                    } else if (categoryMetaData.key.hasPrefix("picture")){
                        fbCategory.pictureUrl = categoryMetaData.value as? String
                    } else if (categoryMetaData.key.hasPrefix("topic_order")){
                        fbCategory.orderNumber = categoryMetaData.value as? Int
                    }
                    fbCategory.tweetArray = fbTweetArray
                }
                self.firebaseDictionary[category.key] = fbCategory//should be in the for loop...this is the same as append, You can use subscript syntax to change the value associated with a particular key
            }
            firebaseDispatch.leave()
        }
        
        if (tokenDictionary != nil) {
            self.swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY, oauthToken: tokenDictionary!["accessTokenKey"] as! String, oauthTokenSecret: tokenDictionary!["accessTokenSecret"] as! String)
            
            
            firebaseDispatch.notify(queue: .main) {
                self.mainCollectionView.reloadData()
                //                print("Finished firebase requests and going into timeline")
                let valueArrayFBC = Array(self.firebaseDictionary.values)
                
                for var firebaseCategory in self.firebaseDictionary.values {
                    
                    firebaseCategory.tweetArray = firebaseCategory.tweetArray?.sorted(by: { $0.order! < $1.order! })
                    
                    self.firebaseDictionary[firebaseCategory.name!] = firebaseCategory
                   // print("arranging ", self.firebaseDictionary[firebaseCategory.name!]?.tweetArray as [FBTweet]? as Any)
                    
                }
                
                self.fetchAllTimelinesFunction()
            }
        }
        
        //if there the token/secret is incorrect this will cause an error and not allow the user to log in. fix this. access token and oathtoken are the same thing fyi
    }
    
    
    
    func fetchAllTimelinesFunction() {//has to be done before other stuff.
        
        let twitterDispatch = DispatchGroup()
        for i in 0 ..< 1 {
            twitterDispatch.enter()
            
            let failureHandler: (Error) -> Void = { error in
                print("Yeaaa...so theres a problem with you network 😕. ", error.localizedDescription)
                if (error.localizedDescription.contains("You might be connecting to a server that is pretending")){
                    self.alert(title: "Watch your back...", message: "Aight so boom...the network you're on has strict security rules, might be watched and is blocking Twitter 👀")
                } else {
                    self.alert(title: "Damn...", message: "Yeaaa...so theres a problem with you network 😕.")
                }
                CollectionViewController.allowedToReload = true
                self.dismissLoadingGIF()
            }
            
            print("test if all dictionary is valid BEFORE fetch: \(firebaseDictionary)")
            
            
            //This is wrong ... the category is the name of the topic and the oneCategoryTweetsStringArray has ALLL the info pertaining to that topic
            var realTweetArray: [String] = []
            var allCategoryTweetsJSONArray : [JSON] = []
            
            
            for (category, tweetsArrayOneCat) in self.firebaseDictionary {
                
                for fbTweet in tweetsArrayOneCat.tweetArray! {
                    
                    // for tweetObject in fbTweet.tweetArray!{
                    realTweetArray.append(fbTweet.tweetId!)
                }
            }
            
            self.swifter?.lookupTweets(for: realTweetArray, includeEntities: true, map: false, tweetMode: TweetMode.extended, success: { json in
                // Successfully fetched timeline, so lets create and push the table view
                guard var tweets = json.array else { return }
                allCategoryTweetsJSONArray = tweets
                
                //print("json", json)
                print("number of gotten tweets \(tweets.count)")
                
                for var tweet in allCategoryTweetsJSONArray {
                    
                    if(tweet["possibly_sensitive"].bool == true && AppDelegate.objContentHasBeenBlocked!){
                        print("this tweet is sensitive so we're leaving.")
                        continue
                    }

                    
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
                    var RThasGif: Bool = false
                    
                    let tempTimestamp = tweet["created_at"].string
                    var nsTimestamp = self.parseTweetTimestamp(timestamp: tempTimestamp!)
                    var dateTimestamp = nsTimestamp! as Date
                    let timeStamp = dateTimestamp.timeAgoDisplay()
                    //print("timestamp: ", timeStamp)
                    
                    var mediaString0: String?
                    var mediaString1: String?
                    var mediaString2: String?
                    var mediaString3: String?
                    
                    
                    gifString = nil
                    regularString = nil
                    mediaString0 = nil
                    mediaString1 = nil
                    mediaString2 = nil
                    mediaString3  = nil
                    
                    
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
                    
                    
                    //check is_quote_status true/false
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
                        if let mediaUrlString = tweet["extended_entities"].object {
                            // print("this is entities: \(urlString)")
                            for myEntry in mediaUrlString {
                                if (myEntry.key == "media") {
                                    let smallJson = myEntry.value
                                    
                                    if (smallJson[0]["type"].string == "photo") {
                                        if let mediaStringZero = smallJson[0]["media_url_https"].string {
                                            mediaString0 = ""
                                            if (mediaStringZero.count > 10) {
                                                mediaString0 = mediaStringZero
                                            }
                                            // print("media string0: ", mediaStringZero)
                                        }else {
                                            
                                        }
                                        if let mediaStringOne = smallJson[1]["media_url_https"].string {
                                            mediaString1 = ""
                                            if (mediaStringOne.count > 10) {
                                                mediaString1 = mediaStringOne
                                            }
                                            // print("media string1: ", mediaStringOne)
                                        } else {
                                            
                                        }
                                        if let mediaStringTwo = smallJson[2]["media_url_https"].string {
                                            mediaString2 = ""
                                            if (mediaStringTwo.count > 10) {
                                                mediaString2 = mediaStringTwo
                                            }
                                            //  print("media string2: ", mediaStringTwo )
                                        }else {
                                            
                                        }
                                        if let mediaStringThree = smallJson[3]["media_url_https"].string {
                                            mediaString3 = ""
                                            if (mediaStringThree.count > 10) {
                                                mediaString3 = mediaStringThree
                                            }
                                            //  print("media string3: ", mediaStringThree )
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
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    //to change the look of a tweet based on its info (retweet, private user etc) make a bool for that info in Homtstatus, then in
                    //tweeCell.swift use that bool value to change the look.
                    
                    let thisHomestatus = LatestStatus(userId: userId!, textTweet: String (describing: text!), profileImageUrl: profileImage!, gifImageViewUrl: gifString, regularUrl: regularString, hasGif: hasGif, statusImageUrl0: mediaString0, statusImageUrl1: mediaString1, statusImageUrl2: mediaString2, statusImageUrl3: mediaString3, textFullName: fullname!, textUsername: username!, likeCount: String (describing: favoriteCount!), retweetCount: String (describing: retweetCount!), tweetId: tweetId!, didFavorite: didFavorite, didRetweet: didRetweet, timeStamp: timeStamp, retweetedBy: retweetedBy, isARetweet: isARetweet, isAQuote: isAQuote, RTUsername: RTUsername, RTFullName: RTFullName, RTText: RTText, RTgifString: RTgifString, RTmediaString0: RTmediaString0, RTmediaString1: RTmediaString1, RTmediaString2: RTmediaString2, RTmediaString3: RTmediaString3)
                    
                    //smallLatestStatuses.append(thisHomestatus)
                    self.statusesForThisCategory.append(thisHomestatus)
                    
                    
                    gifString = nil
                    regularString = nil
                    mediaString0 = nil
                    mediaString1 = nil
                    mediaString2 = nil
                    mediaString3  = nil
                }
                
                print("map for loop")
                
                for (categoryKey, fbCat) in self.firebaseDictionary {
                    var newFBCat: FBCategory
                    var newFBTweetArray: [FBTweet] = []
                    newFBCat = fbCat
                    for tweet in newFBCat.tweetArray! {
                        var newTweet = tweet
                        for status in self.statusesForThisCategory {
                            if (tweet.tweetId == status.tweetId) {
                                newTweet.status = status
                                newFBTweetArray.append(newTweet)
                            }
                        }
                        
                    }
                    newFBCat.tweetArray = []
                    newFBCat.tweetArray = newFBTweetArray
                    self.firebaseDictionary[categoryKey]?.tweetArray = newFBTweetArray
                }
                
                
                twitterDispatch.leave()
            }, failure: failureHandler)
            
            //}
            print("Finished twitter request \(i)")
            
            //twitterDispatch.leave()
            
        }
        
        twitterDispatch.notify(queue: .main) {
            //dispatch is only done once
            if (self.changeableTweetsArray == nil){
                self.changeableTweetsArray = self.twitterDictionary[self.firstFirebaseCategory!]//if this is our first time loading the view, no selection
                let firstTweetArray = self.firebaseDictionary[self.firstFirebaseCategory!]?.tweetArray
                self.changeableTweetsArray = []
                for eachFBtweet in firstTweetArray! {
                    self.changeableTweetsArray?.append(eachFBtweet.status!)
                }
                
            }
            
            self.reusableTableView = ReusableTableView(self.theTableview, self.changeableTweetsArray!, self)
            self.theTableview.reloadData()
            self.scrollToFirstRow()
            self.dismissLoadingGIF()
            CollectionViewController.allowedToReload = true
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
    
    private func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        theTableview.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func toggleDrawer() {
        AuthViewReal.controllerOpenedFrom = self
        universalWasOpen = (self.appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil))!
        print("was open: \(universalWasOpen)")
        if (universalWasOpen) {
            pureReload()
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oh Aight", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func refreshUI() {
        DispatchQueue.main.async{
            self.theTableview.reloadData()
            self.mainCollectionView.reloadData()
            print("reloading tableview")
        }
    }
    
    // THIS IS NOT A SEGUE. YOU JUST PUSHING A NEW INSTANCE OF PROFILE VIEW
    func goToProfilePage(userID dataobjectUID: String, profileImage dataProfileImage: UIImageView) {
        //self.performSegueWithIdentifier("showComments", sender:dataobject )
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.userId = dataobjectUID
        self.navigationController?.pushViewController(profileVC, animated: true)
        print("going to profile in collection view")
    }
    
    func goQuoteTweet(tweetText dataTweetText: String, username dataUsername: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let writeViewController = storyboard.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.initTweetText = dataTweetText
        writeViewController.initUsername = dataUsername
        self.navigationController?.pushViewController(writeViewController, animated: true)
    }
    
}


//correct snap to scrolling https://www.youtube.com/watch?v=_d-xZv0JrRE
extension CollectionViewController: UIScrollViewDelegate{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.mainCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left)/cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    
}

//
//  ReusableTableView.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 4/17/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher
import CollieGallery


class ReusableTableView:  NSObject, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, LatestCellDelegator, CustomCellUpdater, CollieGalleryDelegate, UIGestureRecognizerDelegate, EraseCellDelegate
{

    

    
    public static var profTableviewScrolled: Bool = false
    public static var backgroundIsBlurred = false
    
    var parentCollectionController: UIViewController?
    
    var blurEffectView: UIVisualEffectView?
    var twitterWebview : UIWebView?
    
    public var tableView: UITableView?
    
    var tableViewData: [LatestStatus]?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
   // let transition = TransitionAnimator()
    var selectedCell = UITableViewCell()
    static var favoriteSelected:[Bool] = Array(repeating: false, count: 198)
    static var retweetSelected:[Bool] = Array(repeating: false, count: 198)
    
    init(_ tv: UITableView, _ data: [LatestStatus], _ pcc: UIViewController)
    {
        super.init()
        tableViewData = data
        tableView = tv
        parentCollectionController = pcc
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        // Register all of your cells
        tableView?.register(UINib(nibName: "FreeCell", bundle: nil), forCellReuseIdentifier: "FreeCell")
    }
    

    //everytime reload data is done, this function is re-ran
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tableViewData!.count
    }
    
    //everytime reload data is done, this function is re-ran
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FreeCell", for: indexPath) as! LatestCell
        cell.separatorInset = UIEdgeInsets.zero;
        cell.latestStatus = tableViewData?[indexPath.row]//this is a struct
        
        cell.updateButtons()
        //ensre button state stays the same even after scrolling up and down https://stackoverflow.com/questions/26961203/xcode6-swift-uibutton-sender-not-unique
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
        if (cell.cellLatestTweet.text.hasPrefix("http")){
            
        }
        
        cell.cellLatestTweet.dataDetectorTypes = UIDataDetectorTypes.link
        cell.cellLatestTweet.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: AppConstants.tweeterDarkGreen]
        
        cell.update(data!)
        
        cell.delegate = self
        cell.customCelldelegate = self
        cell.collieDelegate = self
        cell.eraseCellDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewData?[indexPath.row]
        
        let myTweetId = data?.tweetId
        let myTweet = data?.textTweet
        print("tweet id is: \(myTweetId!). tweet is: \(myTweet!)")
        showTwitterSite(tweetId: myTweetId!)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //let cell =  tableView.dequeueReusableCell(withIdentifier: "FreeCell", for: indexPath) as! LatestCell
        cell.alpha = 0
        let slideTransfrom = CATransform3DTranslate(CATransform3DIdentity, -75, 0, 0)
        cell.layer.transform = slideTransfrom
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
     func blockButtonTapped(cell: LatestCell) {
        guard let indexPath = self.tableView?.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            print("should not be happening")
            return
        }
        print("Button tapped on row \(indexPath.row)")
        self.tableViewData?.remove(at: indexPath.row)
        self.tableView?.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
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
    
    func showTwitterSite(tweetId: String) {
        if (!ReusableTableView.backgroundIsBlurred) {
            blurBackground()
        }
        //        else {
        //            clearBackground()
        //        }
        
        
        twitterWebview = UIWebView(frame: CGRect(origin: CGPoint(x: 0, y : 0), size: CGSize(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.15), height: UIScreen.main.bounds.height - (UIScreen.main.bounds.height * 0.3) )))
        twitterWebview?.center =  CGPoint(x: parentCollectionController!.view.center.x, y: parentCollectionController!.view.center.y)
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
        
        if (!ReusableTableView.backgroundIsBlurred) {
            tableView?.isScrollEnabled = false
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView?.alpha = 0
            // blurEffectView?.backgroundColor = UIColor(displayP3Red: 15/255, green: 211/255, blue: 162/255, alpha: 0.05)
            
            blurEffectView?.tag = 102
            //blurEffectView?.frame = view.bounds
            blurEffectView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // view.addSubview(blurEffectView!)
            UIApplication.shared.keyWindow?.addSubview(blurEffectView!)
            
            UIView.animate(withDuration: 0.3){
                self.blurEffectView?.alpha = 0.90
            }
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.bigButtonTapped(gestureRecognizer:)))
            gestureRecognizer.delegate = self
            blurEffectView?.addGestureRecognizer(gestureRecognizer)
            
            ReusableTableView.backgroundIsBlurred = true
        }
    }
    
    @objc func bigButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("blur tapped")
        
        if let webviewWithTag = UIApplication.shared.keyWindow?.viewWithTag(101) {
            webviewWithTag.removeFromSuperview()
        }
        
        if let blurWithTag = UIApplication.shared.keyWindow?.viewWithTag(102){
            blurWithTag.removeFromSuperview()
            tableView?.isScrollEnabled = true
        }
        
        //        if(twitterWebview?.canGoBack)! {
        //            //Go back in webview history
        //            twitterWebview?.goBack()
        //        } else {
        //            //Pop view controller to preview view controller
        //            self.navigationController?.popViewController(animated: true)
        //        }
        ReusableTableView.backgroundIsBlurred = false
    }
    
    //use these in case you have problems in the future
    //https://stackoverflow.com/questions/27676188/how-to-get-parent-controller-from-uiviewcontainers-controller
    //https://stackoverflow.com/questions/36924747/how-to-access-parent-view-controller-from-popover-in-swift-using-storyboard
    func goToProfNaked(userId dataobjectUID: String) {
        //self.performSegueWithIdentifier("showComments", sender:dataobject )
        
        let profileVC = storyboard.instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.username = dataobjectUID
        
        
        parentCollectionController?.navigationController?.pushViewController(profileVC, animated: true)
        
        print("going to profile in reusabletableview")
    }
    
    func goToProfilePage(userID dataobjectUID: String, profileImage dataProfileImage: UIImageView) {
        //self.performSegueWithIdentifier("showComments", sender:dataobject )
        
        let profileVC = storyboard.instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.userId = dataobjectUID
        
        
        parentCollectionController?.navigationController?.pushViewController(profileVC, animated: true)
        
        print("going to profile in reusabletableview")
    }

    func goReplyToTweet(tweetID dataTweetID: String) {
        let writeViewController = storyboard.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.tweetID = dataTweetID
        parentCollectionController?.navigationController?.pushViewController(writeViewController, animated: true)
        print("empty reply to tweet")
    }
    
    func goQuoteTweet(tweetText dataTweetText: String, username dataUsername: String) {
        let writeViewController = storyboard.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        writeViewController.initTweetText = dataTweetText
        writeViewController.initUsername = dataUsername
        
        parentCollectionController?.navigationController?.pushViewController(writeViewController, animated: true)
        print("empty reply to tweet")
    }
    
    func gallery(_ gallery: CollieGallery, indexChangedTo index: Int) {
        gallery.presentInViewController(parentCollectionController!)
        
        print("stack this is happening in reusabletable view")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ReusableTableView.profTableviewScrolled = true
    }
    
    func updateTableView() {
        tableView?.reloadData()
        print("reloading tableview inside of Reusable tableview")
    }
}

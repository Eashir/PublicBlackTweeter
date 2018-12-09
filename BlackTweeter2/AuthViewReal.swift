//  AuthViewReal.swift

import UIKit
import Accounts
import Social
import SwifteriOS
import SafariServices
import Locksmith
import CollieGallery

//convert obj c to xcode https://objectivec2swift.com/#/converter/
//show drawer (fix window heirchy) https://www.youtube.com/watch?v=TdKnImb4SWs
// fix window heirarchy view (may not work) https://github.com/pinterest/ios-pdk/issues/93
//solution? https://github.com/mattdonnelly/Swifter/issues/71
class AuthViewReal: UIViewController, SFSafariViewControllerDelegate, LatestCellDelegator {
    
    public static var controllerOpenedFrom: UIViewController?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var tokenDictionary: [String : Any]?
    var myString: String?
    var cameFromSafari = false
    var mUserId: String?
    
    var swifter: Swifter
    
    @IBOutlet weak var loginButton: TWTButton!
    @IBOutlet weak var logoutButton: TWTButton!
    
    
    @IBAction func deleteTokens(_ sender: Any) {
        print("touched log out")
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: "BlackTweeter")
            print("deleted data")
            self.alert(title: "Logged Out", message: "✌🏾", confirmation: "Peace")
            loginButton.alpha = 1.0
            logoutButton.alpha = 0.3
        } catch {
            //could not delete data. show a warning
            print("did NOT delete data")
            self.alert(title: "Hmmmm", message: "Couldn't Log out, Try Again Later", confirmation: "Got ya")
        }
    }
    
    @IBOutlet weak var menuProfilePic: UIImageView!
    
    @IBAction func goToProfileAction(_ sender: Any) {
        if (mUserId != nil){
            goToProfilePage(userID: mUserId!, profileImage: menuProfilePic)
        }
    }
    
    @IBAction func tutorialAction(_ sender: Any) {
        AppDelegate.onBoardingCompleted = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.buildNavigationDrawerInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET_KEY)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        print("inside viewdidload")
        if (Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter") != nil){
//            print("token dictionary: \(String(describing: Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")!))")
            getProfilePic()
            setUpPicClick()
            loginButton.alpha = 0.3
            logoutButton.alpha = 1.0
        }else {
            loginButton.alpha = 1.0
            logoutButton.alpha = 0.3
        }
    }
    
    @IBAction func doStuff(_ sender: Any) {
        DispatchQueue.main.async {
            //DONT DO SEGUE, JUST SHUT THE DRAWER IF TOKEN is VALID.
            // self.performSegue(withIdentifier: "doStuff", sender: self)
        }
        appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    @IBAction func didTouchUpInsideLoginButtonB(_ sender: AnyObject) {
        if (Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter") == nil) {
            let failureHandler: (Error) -> Void = { error in
                self.alert(title: "Error", message: error.localizedDescription , confirmation: "Aight")
                
            }
            
            
            //solution to auth problems! https://stackoverflow.com/questions/43837137/callback-in-ios-not-returning-for-authentication/48029754#48029754
            //used to be  swifter.authorize(with: URL(string: "BlackTweeter2://sucess")! //New version auto made by twitter smh: http://BlackTweeter2
            let callbackUrl = URL(string: "BlackTweeter2://sucess")!
            swifter.authorize(withCallback: callbackUrl, presentingFrom: self, success: {(accessToken: Credential.OAuthAccessToken?, response: URLResponse?) in //
                
                
//                print("Access Token key \(String(describing: accessToken?.key))")
//                print("Access Token secret \(String(describing: accessToken?.secret))")
                
                // HOW TO GET STATUS RESPONSE (CHECK IF IT WORKS)
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: (\(httpResponse.statusCode))")
                    
                }
                
                print("userId \(String(describing: accessToken?.userID))")
                print("userName \(String(describing: accessToken?.screenName))")
                
                //Save the values that you need in UserDefaults
                do{
                    try Locksmith.updateData(data: ["accessTokenKey": accessToken?.key as! String, "accessTokenSecret": accessToken?.secret as! String, "userId": "nilId", "username": accessToken?.screenName as! String, "realUserId": accessToken?.userID as! String], forUserAccount: "BlackTweeter")
                    
                } catch {
                    print("could not save data...handle. you should delete the keys")
                }
                
                self.tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
                
                self.alert(title: "Success!", message: "Click the menu icon at the top right and let's do this", confirmation: "Sounds Good")
                
                self.loginButton.alpha = 0.3
                self.logoutButton.alpha = 1.0
                
                if (self.tokenDictionary != nil) {
//                    print("dic accesstokenKey:\(self.tokenDictionary!["accessTokenKey"] as! String)")
//                    print("dic accesstokenSecret:\(self.tokenDictionary!["accessTokenSecret"] as! String)")
                }
                
                //if we havent logged in then the latest will open the drawer for us, therefore after we log in we need to close it again.
                // var wasOpen: Bool = (self.appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil))!
                //print(wasOpen)
                
                //if twietterDictionary is valid then go to stream
                //  self.fetchTwitterHomeStream()
                
            },failure: failureHandler)
        } else {
            alert(title: "Huh?", message: "You know you're already logged in right?", confirmation: "Oops My Bad")
        }
    }
    
    
    // 3rd best answer: As this tutorial get token, you can save token in NSUserDefaults, Whenever you close app and launch, check this access token in NSUserDefault, if this token is present that means user has already logged in and you can skip login again. I know its late but it can help others. Thank you
    //2nd best answer: http://www.howtobuildsoftware.com/index.php/how-do/boYs/ios-xcode-swift-twitter-how-to-authorize-twitter-with-swifter
    
    //1st best answer: userHelper will be this class (AuthViewController) https://github.com/mattdonnelly/Swifter/issues/712
    
    func fetchTwitterHomeStream() {
    }
    
    
    func getProfilePic() {
        let failureHandler: (Error) -> Void = { error in
            print("Yeaaa...so theres a problem with you network 😕.")
        }
        var tokenDictionary = Locksmith.loadDataForUserAccount(userAccount: "BlackTweeter")
        mUserId = tokenDictionary!["realUserId"] as? String
        if (mUserId != nil){
        self.swifter.showUser(UserTag.id(mUserId!), includeEntities: true, success: { json in
            if var profileImageUrl = json["profile_image_url_https"].string {
                if (profileImageUrl.hasSuffix(".jpg")){
                    if let range = profileImageUrl.range(of: "_normal.jpg") {
                        profileImageUrl.removeSubrange(range)
                        profileImageUrl.append(".jpg")
                    }
                }
                self.menuProfilePic.sd_setImage(with: URL(string: profileImageUrl), placeholderImage: UIImage(named: "default_profile_.png"))
            }
        }, failure: failureHandler)
        }
    }
    
    
    func alert(title: String, message: String, confirmation: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmation, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        // fetchTwitterHomeStream()
    }
    
    func goToProfilePage(userID dataobjectUID: String, profileImage dataProfileImage: UIImageView) {
        
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RealProfilePage") as! ProfilePage2
        profileVC.userId = dataobjectUID
        
        appDelegate.drawerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
        AuthViewReal.controllerOpenedFrom?.navigationController?.pushViewController(profileVC, animated: true)
        
        print("going to profile in reusabletableview")
    }
    
    func goToProfNaked(userId dataobjectUID: String) {
        //do nothing
    }
    
    @objc func profPicClick(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if (mUserId != nil){
            goToProfilePage(userID: mUserId!, profileImage: menuProfilePic)
        }
    }
    
    func setUpPicClick(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profPicClick(tapGestureRecognizer:)))
        menuProfilePic.isUserInteractionEnabled = true
        menuProfilePic.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func goReplyToTweet(tweetID dataTweetID: String) {
        //do nothing
    }
    func goQuoteTweet(tweetText dataTweetText: String, username dataUsername: String) {
        //do nothing
    }
    
}


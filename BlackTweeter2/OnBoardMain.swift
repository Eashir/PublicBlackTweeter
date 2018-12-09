//
//  OnBoardViewController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 8/28/18.
//  Copyright © 2018 ZumbiilBen. All rights reserved.
//

import UIKit

class OnBoardMain: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {
    
    @IBOutlet weak var startApp: UIButton!
    @IBOutlet weak var onboardingView: OnBoardSubclass!
    
    
    //the solution is to make two different appDelegate.buildNavigationDrawerInterface that are very similar. after the tutorial we will
    //switch the the regular one. We Should make the onboarding a seperate view controller that way we can call it anytime later.
    //use these two video https://www.youtube.com/watch?v=G5UkS4Mrepo&t=42s
    //https://www.youtube.com/watch?v=kecV6xPTTr8
    @IBAction func startAppAction(_ sender: Any) {
        AppDelegate.onBoardingCompleted = true
        let btUserDefaults = UserDefaults.standard
        btUserDefaults.set(AppDelegate.onBoardingCompleted, forKey: "onboardingComplete")
        btUserDefaults.synchronize()
        
        print("onboarding is now: : ", btUserDefaults.bool(forKey: "onboardingComplete"))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.buildNavigationDrawerInterface()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("speed in onboardmain")
        onboardingView.dataSource = self
        onboardingView.delegate = self
    }
    
    func onboardingItemsCount() -> Int {
        return 5}
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let backgroundColorOne =  UIColor(displayP3Red: 0/255, green: 59/255, blue: 53/255, alpha: 1.0)
        let backgroundColorTwo = AppConstants.tweeterDarkGreen
        let backgroundColorThree = UIColor(displayP3Red: 12/255, green: 53/255, blue: 90/255, alpha: 1.0)
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 20)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 14)!
        var imageA6: UIImage? = UIImage(named: "emptyBlankImage")
        
        return [OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "onboard1"), title: "What's Happening!", description: "What's going on. Welcome To BlackTweeter, social media By Us, For All. On the main page, you'll see the 'What's Happening' section. Pick a topic at the top and get into it's content below", pageIcon: #imageLiteral(resourceName: "blank"), color: backgroundColorOne, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "onboard2"), title: "Engaging. Informational.", description: "Topics are new and changing. They can be anything from scholarship info, to hilarious memes and roasts, to nuanced controversial topics 👀, all involving our Black Culture", pageIcon: #imageLiteral(resourceName: "blank"), color: backgroundColorTwo, titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "onboard3"), title: "The Best of Twitter", description: "We still keep almost all everything you love about Twitter. From timeline, friends, followers, likes, retweets, and replies are all in the 'Timeline' section. Click a tweet to go all in.", pageIcon: #imageLiteral(resourceName: "blank"), color: backgroundColorThree, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "onboard4"), title: "That New New", description: "Unique features and options like being able to copy and paste GIF links (finally), to posting tweets in a sarcastic text like my mans Spongebob Squarepants™️", pageIcon: #imageLiteral(resourceName: "blank"), color: backgroundColorTwo, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont),
                OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "onboard5"), title: "Privacy and Respect", description: "We cannot and will not edit tweets. We cannot and will not post private tweets on the 'What's Happening' section. You the user, is what's most to us. So log in and lets go! 🙌🏾", pageIcon: #imageLiteral(resourceName: "blank"), color: backgroundColorOne, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont)][index]
    }
    
    func onboardingConfigurationItem(_: OnboardingContentViewItem, index _: Int) {
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if (index < 4){
            if (self.startApp.alpha == 1) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.startApp.alpha = 0
                })
            }
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if (index == 4){
            UIView.animate(withDuration: 0.3, animations: {
                self.startApp.alpha = 1
            })
        }
    }
    
}

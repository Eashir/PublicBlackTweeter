//
//  TabBarController.swift
//  BlackTweeter2
//
//  Created by Ben Akinlosotu on 1/3/18.
//  Copyright © 2018 Ember Roar Studios. All rights reserved.
//

import Foundation
import UIKit

//to add ads https://www.youtube.com/watch?v=ESg0qgwLmLk&t=6s make sure that it works in the official version this is the test ad.
//how to change icons https://medium.com/@khoanguyenvan/how-to-create-a-custom-tab-bar-icons-in-ios-a9d5738788cc
//and animate them https://medium.com/@werry_paxman/bring-your-uitabbar-to-life-animating-uitabbaritem-images-with-swift-and-coregraphics-d3be75eb8d4d
class TabBarController: UITabBarController, UITabBarControllerDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var mainTabBar: UITabBar!
    var firstItemImageView: UIImageView!
    var secondItemImageView: UIImageView!
    var thirdItemImageView: UIImageView!
    var someTabIndex: Int?
    
    override func viewDidLoad() {
        self.delegate = self
        self.tabBarController?.delegate = self
        
        super.viewDidLoad()
        
        let firstItemView = self.mainTabBar.subviews[0]
        self.firstItemImageView = firstItemView.subviews.first as! UIImageView
        
        let secondItemView = self.mainTabBar.subviews[1]
        self.secondItemImageView = secondItemView.subviews.first as! UIImageView
        
        let thirdItemView = self.mainTabBar.subviews[2]
        self.thirdItemImageView = thirdItemView.subviews.first as! UIImageView
    }
    

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        self.selectedIndex = tabBarIndex
        
        let navigation = viewController as! UINavigationController
        navigation.popToRootViewController(animated: false)
        
        
        if tabBarIndex == 0 {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
                self.firstItemImageView.transform =  CGAffineTransform(rotationAngle: CGFloat.pi)
                UIView.animate(withDuration: 0.5, delay: 0.45, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.firstItemImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                }, completion: nil)
            }, completion: nil)
        } else if tabBarIndex == 1 {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
                self.secondItemImageView.transform =  CGAffineTransform(rotationAngle: CGFloat.pi)
                UIView.animate(withDuration: 0.5, delay: 0.45, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.secondItemImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                }, completion: nil)
            }, completion: nil)
        } else if tabBarIndex == 2 {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
                self.thirdItemImageView.transform =  CGAffineTransform(rotationAngle: CGFloat.pi)
                UIView.animate(withDuration: 0.5, delay: 0.45, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.thirdItemImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                }, completion: nil)
            }, completion: nil)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
           // self.selectedIndex = someTabIndex!
            someTabIndex = self.selectedIndex
            return false
        }

        if fromView == toView {
            let navigation = viewController as! UINavigationController
            navigation.popToRootViewController(animated: false)
            print("going from the same view to the SAME view")
            if (self.selectedIndex == 0){
//                let myViewController = selectedViewController as! CollectionViewController
//                myViewController.scrollToFirstRow()

                 print("im in the collection view controller")
            }
            return false
        }

        UIView.transition(from: fromView, to: toView, duration: 0.4, options: [.transitionCrossDissolve], completion: nil)
         print("going from the same view to A DIFFERENT view")
        return true
    }
}




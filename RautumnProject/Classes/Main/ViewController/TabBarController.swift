//
//  TabBarController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard1 = UIStoryboard(name: "RadiumFriendsCircle", bundle: Bundle.main)
        let storyboard2 = UIStoryboard(name: "RadiumFriendsAddressBooK", bundle: Bundle.main)
        let storyboard3 = UIStoryboard(name: "RadiumParty", bundle: Bundle.main)
        let storyboard4 = UIStoryboard(name: "RadiumVedio", bundle: Bundle.main)
        let storyboard5 = UIStoryboard(name: "Me", bundle: Bundle.main)

        let vc1 = storyboard1.instantiateInitialViewController()
        let vc2 = storyboard2.instantiateInitialViewController()
        let vc3 = storyboard3.instantiateInitialViewController()
        let vc4 = storyboard4.instantiateInitialViewController()
        let vc5 = storyboard5.instantiateInitialViewController()
        vc1?.setUpTabBarItem(imageNamed: "tabBar_normal_leiyouquan", selectedImageNamed: "tabBar_selected_leiyouquan")
        vc2?.setUpTabBarItem(imageNamed: "tabBar_normal_leiyoulv", selectedImageNamed: "tabBar_selected_leiyoulv")
        vc3?.setUpTabBarItem(imageNamed: "tabBar_normal_leiqiuhui", selectedImageNamed: "tabBar_selected_leiqiuhui")
        vc4?.setUpTabBarItem(imageNamed: "tabBar_normal_leishibao", selectedImageNamed: "tabBar_selected_leishibao")
        vc5?.setUpTabBarItem(imageNamed: "tabBar_normal_me", selectedImageNamed: "tabBar_selected_me")
        self.viewControllers = [vc1!,vc2!,vc3!,vc4!,vc5!]
        
        /*
         NSString *userPhone = [DEFAULTS objectForKey:@"userPhone"];
         NSString *password = [DEFAULTS objectForKey:@"userPwd"];
         */
    }
}

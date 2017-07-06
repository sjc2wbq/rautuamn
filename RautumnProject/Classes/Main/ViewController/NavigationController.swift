//
//  NavigationController.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/6/28.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont.systemFont(ofSize: 18)]
//        navigationBar.setBackgroundImage(UIImage(color:UIColor.colorWithHexString("#FF2B66")), for: UIBarMetrics.default)
    
        UINavigationBar.appearance().shadowImage = UIImage()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        navigationItem.backBarButtonItem?.tintColor = UIColor.black
        UINavigationBar.appearance().isTranslucent = false
        let item = UIBarButtonItem()
        item.title = "返回"
        navigationItem.backBarButtonItem = item

        UINavigationBar.appearance().tintColor = UIColor.black

    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = true
        let item = UIBarButtonItem()
        item.title = "返回"
        item.tintColor = UIColor.black
        viewController.navigationItem.backBarButtonItem = item
        
        super.pushViewController(viewController, animated: animated)
    }
    func popVC() {
    popViewController(animated: true)
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
   static func navigationController() -> NavigationController {
        return UIApplication.shared.keyWindow?.rootViewController as! NavigationController
    }

}

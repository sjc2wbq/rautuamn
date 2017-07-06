
//
//  MyActivityViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import YUSegment
import Pages
class MyActivityPageViewController: PagesController,PagesControllerDelegate  {
    var currentPage:UInt = 0

    
    override  init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        let vc1 = MyActivityViewController()
        let vc2 = MyActivityViewController()
        vc1.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc2.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc1.type.value = 1
        vc2.type.value = 2
        add([vc1,vc2])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            pagesDelegate = self
            showPageControl = false
            showBottomLine = false
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func pageViewController(_ pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int){
        currentPage = UInt(page)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MyActivityChangeSelectedIndexNotifation"), object: nil, userInfo: ["selectedIndex":page])
    }
}

//
//  RadiumHotVedioRSVPageViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import YUSegment
import Pages
class RadiumVedioRSVPageViewController: PagesController,PagesControllerDelegate  {
    var currentPage:UInt = 0
    override  init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        let vc1 = RadiumNewVedioRSVViewController()
        let vc2 = RadiumHotVedioRSVViewController()
        vc1.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc2.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        add([vc1,vc2])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        do{
            pagesDelegate = self
            showPageControl = false
            showBottomLine = false
        }
    
    }
    @objc fileprivate func titleSegmentValueChanged(segment:YUSegment){
        if currentPage != segment.selectedIndex{
            goTo(Int(segment.selectedIndex))
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func pageViewController(_ pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int){
        currentPage = UInt(page)
        //        _  =  try? navigationSegmentedControl.set(index : UInt(page), animated: true)
//        titleSegment.selectedIndex = UInt(page)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeSelectedIndexNotifation"), object: nil, userInfo: ["selectedIndex":page])
    }
}

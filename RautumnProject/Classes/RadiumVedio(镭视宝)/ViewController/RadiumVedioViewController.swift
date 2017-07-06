//
//  RadiumVedioViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import YUSegment
import Pages
class RadiumVedioViewController: PagesController,PagesControllerDelegate  {
    var currentPage:UInt = 0

    let titleSegment = YUSegment(titles: ["镭秋RSV","镭秋Live"], style: .line)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            
            let vc1 = RadiumVedioRSVPageContentViewController()
            let vc2 = RadiumVediolLiveiewController()
            add([vc1,vc2])

            
            pagesDelegate = self
            showPageControl = false
            showBottomLine = false
        }
        do{
            
            
            titleSegment.backgroundColor = UIColor.white
            titleSegment.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
            titleSegment.addTarget(self, action: #selector(titleSegmentValueChanged(segment:)), for: .valueChanged)
           self.navigationItem.titleView = titleSegment
        }
    }
    
    
    @objc fileprivate func titleSegmentValueChanged(segment:YUSegment){
        if currentPage != segment.selectedIndex{
            goTo(Int(segment.selectedIndex))
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int){
        currentPage = UInt(page)
//        _  =  try? navigationSegmentedControl.set(index : UInt(page), animated: true)
          titleSegment.selectedIndex = UInt(page)
    }
    

    
}

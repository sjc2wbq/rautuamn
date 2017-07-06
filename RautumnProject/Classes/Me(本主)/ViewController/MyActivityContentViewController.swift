//
//  MyActivityContentViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import YUSegment


class MyActivityContentViewController: UIViewController {
    
    let vc = MyActivityPageViewController()
    var currentPage:UInt = 0
    let titleSegment = YUSegment(titles: ["我参加的活动","我组的局"], style: .line)
    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "我参与的活动"
        do{
            view.backgroundColor = bgColor
            titleSegment.indicator.backgroundColor = UIColor.colorWithHexString("#ff8200")
            titleSegment.selectedTextColor = UIColor.colorWithHexString("#FF8200")
            titleSegment.textColor = UIColor.colorWithHexString("#666666")
            titleSegment.backgroundColor = UIColor.white
            titleSegment.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44)
            titleSegment.addTarget(self, action: #selector(titleSegmentValueChanged(segment:)), for: .valueChanged)
            self.view.addSubview(titleSegment)
        }
        do{
            self.view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: 54, width: view.bounds.size.width, height: view.bounds.size.height - 54)
            self.addChildViewController(vc)
        }
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "MyActivityChangeSelectedIndexNotifation"), object: nil)
                .subscribe(onNext: { (noti) in
                    let page = noti.userInfo!["selectedIndex"] as! Int
                    self.titleSegment.selectedIndex = UInt(page)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc fileprivate func titleSegmentValueChanged(segment:YUSegment){
        if currentPage != segment.selectedIndex{

        }
        vc.goTo(Int(segment.selectedIndex))

    }
}

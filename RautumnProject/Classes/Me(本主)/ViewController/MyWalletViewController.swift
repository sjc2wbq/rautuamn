
//
//  MyWalletTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class MyWalletViewController: YNPageScrollViewController,YNPageScrollViewControllerDataSource,YNPageScrollViewControllerDelegate {
    let friendsCircleHeaderView = MyWalletHeaderView.headerView()

    override func viewDidLoad() {
        /*
         //配置信息
         
         */
        //PostDynamic
        
        let configration = YNPageScrollViewMenuConfigration()
        
        configration.scrollViewBackgroundColor = UIColor.red
        configration.itemLeftAndRightMargin = 30;
        configration.lineColor = UIColor.colorWithHexString("#FF8200")
        configration.lineHeight = 2;
        configration.lineLeftAndRightAddWidth = 10;//线条宽度增加
        configration.itemMaxScale = 1;
        configration.pageScrollViewMenuStyle = .suspension;
        configration.scrollViewBackgroundColor = UIColor.white
        configration.selectedItemColor = UIColor.colorWithHexString("#FF8200")
        configration.normalItemColor = UIColor.black
        configration.itemFont = UIFont.systemFont(ofSize: 15)
        //设置平分不滚动   默认会居中
        configration.aligmentModeCenter = true;
        configration.scrollMenu = true;
        configration.bounces = true;
        configration.itemMargin = (screenW / 2 - "镭世界".width(15, height: 20)) / 2 +  (screenW / 2 - "镭友圈".width(15, height: 20)) / 2
        
        configration.showGradientColor = false;//取消渐变
        self.configration = configration
        
        let vc1 = MyWalletListViewController()
        vc1.type.value = 1
        let vc2 = MyWalletListViewController()
        vc2.type.value = 2
        self.viewControllers = [vc1,vc2]
        self.titleArrayM = ["收入","支出"]
        self.delegate = self
        self.dataSource = self
        friendsCircleHeaderView.frame = CGRect(x: 0, y: 0, width: screenW, height: friendsCircleHeaderView.bounds.size.height)
        
        //        self.scaleBackgroundView = headerView.img_bg
        self.headerView = friendsCircleHeaderView

        
        super.viewDidLoad()
        title = "我的镭秋钱包"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "充值")
        self.navigationItem.rightBarButtonItem!.rx.tap
            .subscribe(onNext: { [unowned self] (_ ) in
                if UserModel.shared.inApp{
                    let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)

    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, scrollViewHeaderScaleState isStart: Bool) {
        let headerView = pageScrollViewController.headerView as! RadiumFriendsCircleHeaderView
        if isStart {
            headerView.img_bg.image = nil
        }else{
            headerView.img_bg.image = UIImage(named:"RadiumFriendsCircleHeaderView_BG")
        }
    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, scrollViewFor index: Int) -> UIScrollView! {
        
        let vc = pageScrollViewController.currentViewController as! UITableViewController
        return vc.tableView
    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, headerViewIsRefreshingFor index: Int) -> Bool {
        
        //        let vc = pageScrollViewController.currentViewController as! UITableViewController
        return true
        
    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, scrollViewHeaderAndFooterEndRefreshFor index: Int) {
        
    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, scrollViewHeaderScaleContentOffset contentOffset: CGFloat) {
        
    }
    func pageScrollViewController(_ pageScrollViewController: YNPageScrollViewController!, tableViewScrollViewContentOffset contentOffset: CGFloat, progress: CGFloat) {
        
    }
}

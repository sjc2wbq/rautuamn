//
//  RadiumFriendsCircleViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import SwiftLocation
import SDWebImage

class RadiumFriendsCircleContentViewController: YNPageScrollViewController,YNPageScrollViewControllerDataSource,YNPageScrollViewControllerDelegate {
    let btn_plus:UIButton = {
        let btn_plus = UIButton(frame: CGRect(x: screenW - 70, y: screenH - 180 , width: 50, height: 50))
        btn_plus.setImage(UIImage(named:"postDynamic"), for: .normal)
    return btn_plus
    }()
    var locationSuccess = Variable(false)
    var isUploadedLocation = Variable(false) //是否已经上传的位置
    var location : (latitude:CLLocationDegrees ,longitude:CLLocationDegrees)?

    let friendsCircleHeaderView = RadiumFriendsCircleHeaderView.headerView()
 
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        if let userModel = DBTool.shared.userModel(){
            friendsCircleHeaderView.userModel = userModel
        }

        getAppImg()
        do {
         NotificationCenter.default.rx.notification(Notification.Name(rawValue: "RCIMConversationTypeSYSTEMNotifation"))
            .subscribe(onNext: { (noti) in
                let message = noti.object as! RCMessage
                log.info("ssssdfaf = \(noti.object)")
                
                if let content = message.content as? RCTextMessage{
                    let systemMessage = SystemMessage()
                    if content.extra != nil{
                        systemMessage.title = content.extra
                    }
                    systemMessage.message = content.content
                    let formart = DateFormatter()
                    formart.dateFormat = "YYYY-MM-dd HH:mm:ss"
                    let time = formart.string(from: Date(timeIntervalSince1970: TimeInterval(Int64(("\(message.receivedTime)" as NSString).substring(to: "\(message.receivedTime)".characters.count - 3))!)))
                    systemMessage.time = time
                    DBTool.shared.addSysTemMessage(message: systemMessage)
                }

            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        }
        do{
            if UserModel.shared.id != 0{
                var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                    self.location = (loc.coordinate.latitude,loc.coordinate.longitude)
                    self.locationSuccess.value = true
                }) { (last, err) in
                    print("err \(err)")
                }
                r.onAuthorizationDidChange = { newStatus in
                    print("New status \(String(describing: newStatus))")
                }
                let request =   locationSuccess.asObservable()
                    .filter{$0  == true}
                    .withLatestFrom(isUploadedLocation.asObservable())
                    .filter{$0 == false}
                    .flatMap{_ in RequestProvider.request(api: ParametersAPI.uploadLocation(longitude: self.location!.1, latitude: self.location!.0)).mapObject(type: EmptyModel.self)}
                request.flatMap{$0.unwarp()}
                    .subscribe(onNext: { (_) in
                        self.isUploadedLocation.value = true
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
                
                request.flatMap{$0.error}
                    .subscribe(onNext: { (_) in
                        self.isUploadedLocation.value = true
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)

            }
            UIApplication.shared.applicationIconBadgeNumber = Int(RCIMClient.shared().getTotalUnreadCount())
            self.tabBarController?.tabBarItem.badgeValue = RCIMClient.shared().getTotalUnreadCount() <= 0 ? nil : "\(RCIMClient.shared().getTotalUnreadCount())"
            self.navigationItem.rightBarButtonItem!.badgeValue = RCIMClient.shared().getTotalUnreadCount() <= 0 ? nil : "\(RCIMClient.shared().getTotalUnreadCount())"
            if  RCIMClient.shared().getTotalUnreadCount() <= 0 {
                self.tabBarController?.tabBar.hideBadge(onItemIndex: 0)
            }else{
                self.tabBarController?.tabBar.showBadge(onItemIndex: 0, badgeValue: RCIMClient.shared().getTotalUnreadCount())
            }
            if let value = UserDefaults.standard.value(forKey: "ConversationType_SYSTEM_Count") as? Int{
                if value == 0 {
                    self.tabBarController?.tabBar.showBadge(onItemIndex: 4, badgeValue: Int32(value))
                }else{
                    self.tabBarController?.tabBar.hideBadge(onItemIndex: 4)
                }
            }else{
                self.tabBarController?.tabBar.hideBadge(onItemIndex: 4)
            }
            
    

        }
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
        configration.itemMaxScale = 1.2;
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


        self.viewControllers = [RadiumFriendsCircleViewController(),MyFriendsCircleViewController()]
        self.titleArrayM = ["镭世界","镭友圈"]
        self.delegate = self
        self.dataSource = self
        friendsCircleHeaderView.frame = CGRect(x: 0, y: 0, width: screenW, height: friendsCircleHeaderView.bounds.size.height)

//        self.scaleBackgroundView = headerView.img_bg
        self.headerView = friendsCircleHeaderView
        
        super.viewDidLoad()
        
        do {
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "GetRautumnAppImg"), object: nil)
                .subscribe(onNext: { (_) in
                    print("刷行了了")
                    self.getAppImg()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
    
        do{
            
            btn_plus.rx.tap.subscribe(onNext: {[unowned self] (_) in
                let vc = UIStoryboard(name: "PostDynamic", bundle: nil).instantiateInitialViewController()
                self.present(vc!, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            view.addSubview(btn_plus)
        
    
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "btn_plusIsHiddenNotifation"))
            .subscribe(onNext: {[unowned self] (noti) in
                let isHidden = noti.object as! Bool
                UIView.animate(withDuration: 0.25, animations: { 
                    if isHidden{
                    self.btn_plus.mj_x = screenW
                        self.btn_plus.alpha = 0
                    }else{
                        self.btn_plus.mj_x = screenW - 70
                        self.btn_plus.alpha = 1
                    }
                })
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
        
        do{
          NotificationCenter.default.rx.notification(Notification.Name(rawValue: "RCIMReceiveMessageNotifation"))
            .subscribe(onNext: {[unowned self] (_) in
                UIApplication.shared.applicationIconBadgeNumber = Int(RCIMClient.shared().getTotalUnreadCount())
               self.tabBarItem.badgeValue = RCIMClient.shared().getTotalUnreadCount() <= 0 ? nil : "\(RCIMClient.shared().getTotalUnreadCount())"
                self.navigationItem.rightBarButtonItem!.badgeValue = RCIMClient.shared().getTotalUnreadCount() <= 0 ? nil : "\(RCIMClient.shared().getTotalUnreadCount())"
                
                if  RCIMClient.shared().getTotalUnreadCount()  <= 0 {
                    self.tabBarController?.tabBar.hideBadge(onItemIndex: 0)
                }else{
                    self.tabBarController?.tabBar.showBadge(onItemIndex: 0, badgeValue: RCIMClient.shared().getTotalUnreadCount())
                }
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        do{
            let request =     NotificationCenter.default.rx.notification(Notification.Name(rawValue: "GetUserInfoNotifation"))
                .flatMap { _ in  RequestProvider.request(api: ParametersAPI.userLogin(phone: UserDefaults.standard.value(forKey: "userPhone") as! String, password: (UserDefaults.standard.value(forKey: "userPwd") as! String).md5())).mapObject(type: UserModel.self)
                }
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                .subscribe(onNext: {[unowned self] (userModel) in
                    UserModel.shared = userModel
                    DBTool.shared.saveUserModel()
                    let userInfo = RCUserInfo()
                    userInfo.name = UserModel.shared.nickName.value
                    userInfo.userId = "\(UserModel.shared.id)"
                    userInfo.portraitUri = UserModel.shared.headPortUrl.value
                    RCIM.shared().currentUserInfo = userInfo
                    RCIMClient.shared().currentUserInfo = userInfo
                    self.friendsCircleHeaderView.userModel = userModel
                    RCDLive.shared().currentUserInfo = userInfo
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
    }
    
    
    func getAppImg() {
        
//        Rautum_GetAppImg
       let urlString = UserDefaults.standard.object(forKey: "Rautum_GetAppImg_urlString") as? String
        if urlString != nil && urlString != "" {
            print("sssssssss")
            
            if SDImageCache.shared().diskImageExists(withKey: urlString ) {
                let image = SDImageCache.shared().imageFromDiskCache(forKey: urlString )
                self.friendsCircleHeaderView.img_bg.image = image
                print("imge = \(image)")
                
            }
        }
        
        let request =  RequestProvider.request(api: ParametersAPI.getAppImg()).mapObject(type: AppImg.self)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
//                self.friendsCircleHeaderView.img_bg.sd_setImage(with: URL(string:model.coverImageUrl), placeholderImage: nil, options: [.retryFailed])
                
                if model.coverImageUrl != "" {
                    UserDefaults.standard.set(model.coverImageUrl, forKey: "Rautum_GetAppImg_urlString")
                    UserDefaults.standard.synchronize()
                    
                    let url = URL.init(string: model.coverImageUrl)
                    SDWebImageManager.shared().downloadImage(with: url, options: .retryFailed, progress: nil, completed: { (image, error, cachetype, finish, aUrl) in
                        self.friendsCircleHeaderView.img_bg.image = image
                        SDImageCache.shared().store(image, forKey: "Rautum_GetAppImg")
                    })
                }
                
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
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

//
//  UserInfoViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import SDAutoLayout
import RxSwift
class UserInfoViewController: UIViewController,MKTagViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var index = Variable(-1)
    var noFriendIndex = Variable(-1)
    var model:FriendInfoModel?
    var tagCellH:CGFloat = 0
    var visitorUserId = 0
    var isFriend = false
    
    // 处理标签所在cell的高度问题
    var isFirst = false
    
    @IBOutlet weak var btn_bottom: UIButton!

    @IBOutlet weak var btn_bottom_h: NSLayoutConstraint!
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(UserInfoViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        initTableView()
        self.btn_bottom.setTitle(nil, for: .normal)
        do{
            if UserModel.shared.id != visitorUserId {
                btn_bottom_h.constant = 50
            }else{
                btn_bottom_h.constant = 0
            }
        }
        fetchUserInfo()
        
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
        
        
        do {//好友
            
               do{ //好友拉黑
            let request =   self.index.asObservable()
                .filter{$0 == 1}
                .flatMap{_ in RequestProvider.request(api: ParametersAPI.blacklist(receiveUserInfoId: self.visitorUserId, type: 1)).mapObject(type: EmptyModel.self)
                    .trackActivity(activityIndicator)
                }
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}
                .subscribe(onNext: {[unowned self] (_) in
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LaHeiUserSuccessNotifation"), object: nil)
                    Drop.down("拉黑成功！", state: .success)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            }
            
            do{ //好友删除
                let request =  self.index.asObservable()
                    .filter{$0 == 2}
                    .flatMap{_ in RequestProvider.request(api: ParametersAPI.friendsAgreeOrDelete(beAddedUserInfoId: self.visitorUserId, type: 2)).mapObject(type: EmptyModel.self)
                        .trackActivity(activityIndicator)
                    }
                    .shareReplay(1)
                
                request.flatMap{$0.unwarp()}
                    .subscribe(onNext: { (_) in
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeleteUserSuccessNotifation"), object: nil)
                        Drop.down("删除好友成功！！", state: .success)
                        RCIMClient.shared().remove(.ConversationType_PRIVATE, targetId: "\(self.visitorUserId)")
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                
                request.flatMap{$0.error}.map{$0.domain}
                    .subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            }

            do{ //投诉
                
                self.index.asObservable()
                    .filter{$0 == 3}
                    .subscribe(onNext: {[unowned self] (_) in
                        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "ComplaintViewController") as! ComplaintViewController
                        vc.appelleeUserInfoId = self.visitorUserId
                        self.navigationController?.pushViewController(vc, animated: true)
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            }
        
        }
        
        do{//非好友
        
            do{ //好友拉黑
                let request =   self.noFriendIndex.asObservable()
                    .filter{$0 == 1}
                    .flatMap{_ in RequestProvider.request(api: ParametersAPI.blacklist(receiveUserInfoId: self.visitorUserId, type: 1)).mapObject(type: EmptyModel.self)
                        .trackActivity(activityIndicator)
                    }
                    .shareReplay(1)
                
                request.flatMap{$0.unwarp()}
                    .subscribe(onNext: {[unowned self] (_) in
                        _ = self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LaHeiUserSuccessNotifation"), object: nil)
                        Drop.down("拉黑成功！", state: .success)

                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                request.flatMap{$0.error}.map{$0.domain}
                    .subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
            }
            do{ //投诉
                
                self.noFriendIndex.asObservable()
                    .filter{$0 == 2}
                    .subscribe(onNext: {[unowned self] (_) in
                        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "ComplaintViewController") as! ComplaintViewController
                        vc.appelleeUserInfoId = self.visitorUserId
                        self.navigationController?.pushViewController(vc, animated: true)
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            }
        }
    }
    @IBAction func leiTaAction(_ sender: UIButton) {
        guard let model = model else {
            return
        }
        if sender.titleLabel?.text == "镭Ta" {
            if UserModel.shared.rank.value == "U"{
                let vc = UIAlertController(title: "温馨提示", message: "开通注册会员后，才能镭Ta，是否去开通？", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                vc.addAction(UIAlertAction(title: "去开通", style: .default, handler: {[unowned self] _ in
                    if UserModel.shared.inApp{
                        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppOpeningMemberTableViewController") as! InAppOpeningMemberTableViewController
                        self.navigationController?.pushViewController(vc, animated: true)

                    }else{
                        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "OpeningMemberTableViewController") as! OpeningMemberTableViewController
                        vc.type = 2
                        self.navigationController?.pushViewController(vc, animated: true)

                    }
                                  }))
                self.present(vc, animated: true, completion: nil)
                return
            }
        }else if sender.titleLabel?.text == "等待好友验证"{
            let vc = UIAlertController(title: "温馨提示", message: "正在等待对方同意您的好友申请！", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
            return
        }
               if model.friend {
            let conversationVC = RCDChatViewController()
            conversationVC.conversationType = .ConversationType_PRIVATE;
            conversationVC.targetId = "\(visitorUserId)"
            conversationVC.title = model.nickName
            conversationVC.displayUserNameInCell = false
            navigationController?.pushViewController(conversationVC, animated: true)
        }else{
            let vc = LeiTaViewController()
            vc.userId = visitorUserId
            vc.title = "镭Ta一下"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension UserInfoViewController:UITableViewDelegate,UITableViewDataSource{
    fileprivate func initTableView(){
        tableView.backgroundColor = bgColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserInfoBaseInfoViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoBaseInfoViewCell")
        tableView.register(UINib(nibName: "UserInfoTagViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoTagViewCell")
        tableView.register(UINib(nibName: "UserOtherInfoViewCell", bundle: nil), forCellReuseIdentifier: "UserOtherInfoViewCell")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoBaseInfoViewCell") as! UserInfoBaseInfoViewCell
            cell.img_playVideo.tag = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
            cell.model = model
            
            cell.img_playVideo.addGestureRecognizer(tap)
            
            let historyTap = UITapGestureRecognizer(target: self, action: #selector(history(tap:)))
            cell.historyView.addGestureRecognizer(historyTap)
            
            return cell
        }else if  indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTagViewCell") as! UserInfoTagViewCell
            cell.model = model
            cell.tagView.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserOtherInfoViewCell") as! UserOtherInfoViewCell
        cell.model = model
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 0{
            if let model = model {
                if model.userPhotos.count == 0 {
//                    return 340 + screenW / 2
                    return 700
                }
            }
//        return 420 + screenW / 2
            return 824
        }else if  indexPath.row == 1{
            if self.tagCellH == 0 {
                return 100
            }
            return self.tagCellH
        }
        return cellHeight(for: indexPath, cellContentViewWidth: screenW, tableView: tableView)
    }
    func mkTagView(_ tagview: MKTagView!, sizeChange newSize: CGRect) {
        self.tagCellH = newSize.height + 50
        if !isFirst {
            tableView.reloadData()
            isFirst = true
        }
    }
    
    @objc fileprivate func history(tap: UITapGestureRecognizer) {
        
        let vc = RadiumFriendsCircleViewController()
        vc.isFriendHistory = true
        vc.friendUid = visitorUserId
        vc.title = "Ta的发布"
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:model!.vcr)
        self.present(vc, animated: true, completion: nil)
    }

}
extension UserInfoViewController{
    func fetchUserInfo()  {
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
   let request = RequestProvider.request(api: ParametersAPI.raufriDetails(visitorUserId: visitorUserId)).mapObject(type: FriendInfoModel.self)
    .trackActivity(activityIndicator)
    .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: {[unowned self] (error) in
            Drop.down(error, state: .error)
            sleep(1)
           _ = self.navigationController?.popViewController(animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
        .subscribe(onNext: {[unowned self] (model) in
            self.model = model
//            self.title = model.nickName
            if UserModel.shared.id != self.visitorUserId{
                self.setNav(isFriend: model.friend)
            }
            if model.friend {
                self.btn_bottom.setTitle("发消息", for: .normal)
            }else{
                if model.friendState == 1{
                    self.btn_bottom.setTitle("等待好友验证", for: .normal)
                }else{
                    self.btn_bottom.setTitle("镭Ta", for: .normal)
                }
            }
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
    }
    fileprivate func setNav(isFriend:Bool){
        let dict1 = ["imageName":"","itemName":"拉黑"]
        let dict2 = ["imageName":"","itemName":"删除"]
        let dict3 = ["imageName":"","itemName":"投诉"]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "more")
        self.navigationItem.rightBarButtonItem!.rx.tap
            .subscribe(onNext: { (_) in
                CommonMenuView.createMenu(withFrame: CGRect.zero, target: self, dataArray: isFriend == true ?  [dict1,dict2,dict3] : [dict1,dict3], itemsClick: { (_, index) in
                    CommonMenuView.hidden()
                    CommonMenuView.clearMenu()
                    self.index.value = -1
                    self.noFriendIndex.value = -1
                    CommonMenuView.clearMenu()
                    if isFriend{
                        self.index.value = index
                        
                    }else{
                        self.noFriendIndex.value = index
                    }
                }, backViewTap: {
                    
                })

                CommonMenuView.updateMenuItems(with: isFriend == true ?  [dict1,dict2,dict3] : [dict1,dict3])
                CommonMenuView.showMenu(at: CGPoint(x: screenW - 30, y: 40))
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    
    }
}

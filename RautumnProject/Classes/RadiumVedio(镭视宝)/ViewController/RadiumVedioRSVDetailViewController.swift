
//
//  RadiumHotVedioRSVDetailViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
import SwiftyDrop
import UIKit
import SDAutoLayout
import  MJRefresh
import SimpleAlert
class RadiumVedioRSVDetailViewController: UITableViewController {
    let headerView = RadiumVedioRSVDetailHeaderView.headerView()
    let sectionHeaderView  = RadiumFriendsCircleDetailSectionHeaderView.sectionHeaderView()
    var page = 1
    fileprivate var alert:AlertController?
    let exceptionalView = ExceptionalView.exceptionalView()
      public var rvUseful:RvUseful!
    var dataSource = [Rautumnfriendscirclecom]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "镭秋RSV详情"
        headerView.rvUseful = rvUseful
        headerView.delegate = self
        do{
            exceptionalView.exceptionalGoldHander = { [unowned self] in
                self.alert?.dismiss(animated: true, completion: { [unowned self] in
                    //国际化
                    let avc = UIAlertController(title: "温馨提示", message: "您的镭秋币不足，无法打赏，是否去充值？", preferredStyle: .alert)
                    
                    avc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                        
                    }))
                    avc.addAction(UIAlertAction(title: "去充值", style: .default, handler: {[unowned self] (_) in
                        if UserModel.shared.inApp{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }                    }))
                    
                    self.present(avc, animated: true, completion: nil)
                })
            }
            exceptionalView.btn_topUp.rx.tap
                .map{_ in self.alert}
                .subscribe(onNext: { (alert) in
                    alert?.dismiss(animated: true, completion: { [unowned self] in
                        if UserModel.shared.inApp{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                    })
                }, onError: nil, onCompleted: nil, onDisposed: nil )
                .addDisposableTo(rx_disposeBag)
        }
        do{
            sectionHeaderView.btn_Comment.rx.tap
                .subscribe(onNext: {[unowned self] (noti) in
                    let vc = CommentViewController()
                    vc.type = 2
                    vc.commentType = 2
                    vc.objId = "\(self.rvUseful.id)"
                    self.present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
                })
                .addDisposableTo(rx_disposeBag)
        }
        
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "PostCommtentNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    self.dataSource.insert(noti.object as! Rautumnfriendscirclecom, at: 0)
                    self.rvUseful.commentCount.value = self.dataSource.count
                    self.tableView.reloadData()
                })
                .addDisposableTo(rx_disposeBag)
        }
        
        do{
            alert = AlertController(view: exceptionalView, style: .actionSheet)
          }
        
        do{
            tableView.backgroundColor = UIColor.white
            headerView.delegate = self
            tableView.sectionFooterHeight = 0
            tableView.sectionHeaderHeight = 0
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "RadiumFriendsCircleDetailViewCell", bundle: nil), forCellReuseIdentifier: "RadiumFriendsCircleDetailViewCell")
            tableView.tableHeaderView = headerView
            tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
                self.page = 1
                self.loadData()
            })
     
            tableView.mj_footer =    footer {[unowned self] in
                self.page += 1
                self.loadData()
            }
            tableView.st_header.beginRefreshing()
        }
    }
}

extension RadiumVedioRSVDetailViewController{
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadiumFriendsCircleDetailViewCell") as! RadiumFriendsCircleDetailViewCell
        let model = dataSource[indexPath.row]
        cell.rauVideoUsefulCom = model
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushUserInfoVC(tap:)))
        cell.img_icon.addGestureRecognizer(tap)
        cell.img_icon.tag = indexPath.row
        return cell
        
    }
    func pushUserInfoVC(tap:UITapGestureRecognizer)  {
        let model = dataSource[tap.view!.tag]
        let vc = UserInfoViewController()
        vc.visitorUserId = model.userId
        vc.title = model.userName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(for: indexPath, cellContentViewWidth: screenW, tableView: tableView)
    }
}
extension RadiumVedioRSVDetailViewController {
    func loadData()  {
        let request =   RequestProvider.request(api: ParametersAPI.rsvComment(rsvId: rvUseful.id, pageIndex: self.page)).mapObject(type: RauVideoUsefulComModel.self)
            .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: {[unowned self] (error) in
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
                if self.page == 1{
                    self.dataSource = model.rauVideoUsefulComs
                    self.tableView.mj_footer.isHidden = self.dataSource.count <= 10
                    self.tableView.st_header.endRefreshing()
                }else{
                    if model.rauVideoUsefulComs.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource += model.rauVideoUsefulComs
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
}

extension RadiumVedioRSVDetailViewController : RadiumVedioRSVDetailHeaderViewDelegate{
    func zanButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView){
        
        if rvUseful.userId == UserModel.shared.id {
            Drop.down("自己不能打赏自己！", state: .info)
            return
        }
        if rvUseful.rank == "U" {
            Drop.down("该用户是注册用户，不能接受打赏！", state: .info)
            return
        }
        exceptionalView.objId = rvUseful.id
        exceptionalView.type = 2
        UserModel.shared.rautumnCurrency.asObservable().map{"您可用的镭秋币：\($0) 个"}.bindTo(exceptionalView.lb_gold.rx.text).addDisposableTo(rx_disposeBag)
        exceptionalView.rvUseful = rvUseful
        present(alert!, animated: true, completion: nil)

    
    }
    func commentButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView){
        let vc = CommentViewController()
        vc.type = 2
        vc.commentType = 2
        vc.objId = "\(rvUseful.id)"
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)

    
    }
    func leitaButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView){
        
        if UserModel.shared.id == rvUseful.userId{
            Drop.down(rvUseful.friend == true ?  "自己不能给自己发消息！" : "自己不能镭自己！", state: .info)
            return
        }
        if  rvUseful.friend {
            let conversationVC = RCDChatViewController()
            conversationVC.conversationType = .ConversationType_PRIVATE;
            conversationVC.targetId = "\(rvUseful.userId)"
            conversationVC.title = rvUseful.nickName
            conversationVC.displayUserNameInCell = false
            self.navigationController?.pushViewController(conversationVC, animated: true)
        }else{
            let vc = UserInfoViewController()
            vc.visitorUserId = rvUseful.userId
            vc.title = rvUseful.nickName
            navigationController?.pushViewController(vc, animated: true)
        }
        
     
    
    }
}

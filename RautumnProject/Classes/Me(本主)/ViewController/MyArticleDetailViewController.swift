
//
//  MyArticleDetailViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import  MJRefresh
import SimpleAlert
class MyArticleDetailViewController: UITableViewController {
    let headerView = MyArticleDetailHeaderView.headerView()
    let sectionHeaderView  = RadiumFriendsCircleDetailSectionHeaderView.sectionHeaderView()
    var page = 1
    var dataSource = [Rautumnfriendscirclecom]()
    var rautumnFriendsCircle : RautumnFriendsCircle!
    fileprivate var alert:AlertController?
    let exceptionalView = ExceptionalView.exceptionalView()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.audioPlayer.endPlay()
        headerView.audioPlayer1.pausePlay()
        headerView.audioButton.isSelected = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            sectionHeaderView.btn_Comment.rx.tap
                .subscribe(onNext: {[unowned self] (noti) in
                    let vc = CommentViewController()
                    vc.type = self.rautumnFriendsCircle.type
                    vc.objId = "\(self.rautumnFriendsCircle.id)"
                    self.present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
                })
                .addDisposableTo(rx_disposeBag)
        }
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "PostCommtentNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    self.dataSource.insert(noti.object as! Rautumnfriendscirclecom, at: 0)
                    self.tableView.reloadData()
                    self.rautumnFriendsCircle.commentCount.value = self.dataSource.count
                })
                .addDisposableTo(rx_disposeBag)
        }
        do{
            alert = AlertController(view: exceptionalView, style: .actionSheet)
        }
        do{
            headerView.rautumnFriendsCircle = rautumnFriendsCircle
            tableView.tableHeaderView = headerView
            tableView.backgroundColor = UIColor.white
            headerView.delegate = self
            tableView.sectionFooterHeight = 0
            tableView.sectionHeaderHeight = 0
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "RadiumFriendsCircleDetailViewCell", bundle: nil), forCellReuseIdentifier: "RadiumFriendsCircleDetailViewCell")
            
    
            self.tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadiumFriendsCircleDetailViewCell") as! RadiumFriendsCircleDetailViewCell
        let model = dataSource[indexPath.row]
        cell.model = model
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushUserInfoVC(tap:)))
        cell.img_icon.addGestureRecognizer(tap)
        cell.img_icon.tag = indexPath.row
        return cell
        
    }
    func pushUserInfoVC(tap:UITapGestureRecognizer)  {
        let model = dataSource[tap.view!.tag]
        let vc = UserInfoViewController()
        vc.visitorUserId = model.userId
//        vc.title = model.userName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        headerView.audioPlayer.endPlay()
        headerView.audioPlayer1.pausePlay()
        headerView.audioButton.isSelected = false
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension MyArticleDetailViewController {
    func loadData()  {
        let request =   RequestProvider.request(api: ParametersAPI.rfcComment(rfcId: "\(rautumnFriendsCircle.id)", pageIndex: self.page)).mapObject(type: RautumnFriendsCircleComment.self)
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
                    self.dataSource = model.rautumnFriendsCircleComs
                    self.tableView.mj_footer.isHidden = self.dataSource.count <= 10
                    self.tableView.st_header.endRefreshing()
                }else{
                    if model.rautumnFriendsCircleComs.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource += model.rautumnFriendsCircleComs
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
}


extension MyArticleDetailViewController : MyArticleDetailHeaderViewDelegate{
    func zanButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView){
        present(alert!, animated: true, completion: nil)
        
    }
    func commentButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView){
        let vc = CommentViewController()
        vc.type = rautumnFriendsCircle.type
        vc.objId = "\(rautumnFriendsCircle.id)"
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
    }
    func leitaButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView){
        let vc = UserInfoViewController()
        vc.visitorUserId = rautumnFriendsCircle.userId
//        vc.title = rautumnFriendsCircle.nickName
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

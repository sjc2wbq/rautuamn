
//
//  MyVideoDetailViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/23.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import  MJRefresh
import SDAutoLayout
import SimpleAlert
class MyVideoDetailViewController: UITableViewController {
    public var rsv : MyRSV!
    let sectionHeaderView  = RadiumFriendsCircleDetailSectionHeaderView.sectionHeaderView()
    var page = 1
    var dataSource = [Rautumnfriendscirclecom]()
    fileprivate var alert:AlertController?
    let exceptionalView = ExceptionalView.exceptionalView()
    let headerView = MyVideoDetailHeaderView.headerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "视频详情"
        do{
            sectionHeaderView.btn_Comment.isHidden = true
            headerView.sd_height =  304 + rsv.title.height(16, wight: screenW - 16)
            headerView.rsv = rsv
            tableView.tableHeaderView = headerView
                        tableView.tableHeaderView = headerView
            tableView.backgroundColor = UIColor.white
            tableView.sectionFooterHeight = 0
            tableView.sectionHeaderHeight = 0
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "RadiumFriendsCircleDetailViewCell", bundle: nil), forCellReuseIdentifier: "RadiumFriendsCircleDetailViewCell")
            
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
        do{
            sectionHeaderView.btn_Comment.rx.tap
                .subscribe(onNext: {[unowned self] (noti) in
                    let vc = CommentViewController()
                    vc.type = 2
                    vc.objId = "\(self.rsv.id)"
                    self.present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
                })
                .addDisposableTo(rx_disposeBag)
        }
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "PostCommtentNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    self.dataSource.insert(noti.object as! Rautumnfriendscirclecom, at: 0)
                    self.tableView.reloadData()
                })
                .addDisposableTo(rx_disposeBag)
        }
        do{
            alert = AlertController(view: exceptionalView, style: .actionSheet)
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
extension MyVideoDetailViewController {
    func loadData()  {
        let request =   RequestProvider.request(api: ParametersAPI.rsvComment(rsvId: rsv.id, pageIndex: self.page)).mapObject(type: RautumnFriendsCircleComment.self)
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


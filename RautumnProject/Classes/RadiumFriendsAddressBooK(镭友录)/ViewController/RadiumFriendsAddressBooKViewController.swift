//
//  RadiumFriendsAddressBooKViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyDrop
import RxDataSources
class RadiumFriendsAddressBooKViewController: UITableViewController {
    var viewModel:RadiumFriendsAddressBooKViewModel!
    var isLoadData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        do{
            Observable.of(NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "RefreshAddressBooksNotifation")),
                          NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "LaHeiSuccessNotifation")),
                          NotificationCenter.default.rx.notification(Notification.Name(rawValue: "DeleteUserSuccessNotifation")))
                .merge()
                .subscribe(onNext: {[unowned self] (_) in
                    if self.isLoadData {
                        self.viewModel.fetchData(finish: nil)
                        self.tableView.reloadData()
                    }
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            
       NotificationCenter.default.rx.notification(Notification.Name(rawValue: "RCIMReceiveFriendRequestCountNotifation"))
            .subscribe(onNext: { (_) in
                if let friendRequestCount = UserDefaults.standard.value(forKey: "friendRequestCount") as? Int{
                    self.tabBarItem.badgeValue = friendRequestCount == 0 ? nil : "\(friendRequestCount)"
                }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        }

    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension RadiumFriendsAddressBooKViewController{
    func initTableView()  {

        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
        tableView.backgroundColor = UIColor.white
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        tableView.tableFooterView = UIView()
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.backgroundColor = bgColor
        tableView.register(UINib(nibName: "FindFriendsViewCell", bundle: nil), forCellReuseIdentifier: "FindFriendsViewCell")
        tableView.register(UINib(nibName: "AddressBookNewFriendViewCell", bundle: nil), forCellReuseIdentifier: "AddressBookNewFriendViewCell")
tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
            
           self.viewModel.fetchData(finish: { _ in
            self.tableView.st_header.endRefreshing()
           })
        })
//
        //您现在有23位镭友，加油哟！
        bindViewModel()
        isLoadData = true
        if let _ = UserDefaults.standard.value(forKey: "friendRequestCount") as? Int{
            self.tabBarController?.tabBar.showBadge(onItemIndex: 1, badgeValue: 0)
        }
    }
    
    func bindViewModel() {
        viewModel = RadiumFriendsAddressBooKViewModel()
        viewModel.fetchData(finish: nil)
        viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, friend) in
            if indexPath.section == 0 || indexPath.section == 1{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookNewFriendViewCell", for: indexPath) as! AddressBookNewFriendViewCell
                if indexPath.section == 1 {
                    cell.aTitleLabel.text = "镭约吧"
                    cell.iconImage.image = UIImage.init(named: "leiyueba")
                    cell.unReadView.image = UIImage.init(named: "ta在哪")
                    return cell
                }
                
                if let friendRequestCount = UserDefaults.standard.value(forKey: "friendRequestCount") as? Int{
                    
                    if friendRequestCount == 0 {
                        cell.unReadView.image =  UIImage.init(named: "ta镭你-灰色")
                    } else {
                        cell.unReadView.image =  UIImage.init(named: "ta镭你-橘色")
                    }
                    
                }else{
                    cell.unReadView.image =  UIImage.init(named: "ta镭你-灰色")
                }
                return cell
            }else if indexPath.section == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsViewCell", for: indexPath) as! FindFriendsViewCell
                cell.btn_lei.rx.tap.subscribe(onNext: {[unowned self] (_) in
                    let conversationVC = RCDChatViewController()
                    conversationVC.conversationType = .ConversationType_PRIVATE;
                    conversationVC.targetId = "\(friend.userId)"
                    conversationVC.title = friend.nickName
                    conversationVC.displayUserNameInCell = false
                    self.navigationController?.pushViewController(conversationVC, animated: true)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(cell.rx_reusableDisposeBag)
                cell.friend = friend
                cell.btn_lei.setTitle("发消息", for: .normal)
                return cell
            
            }
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.frame = cell.bounds
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.gray
            cell.textLabel?.text = self.viewModel.dataSource.sectionModels[indexPath.section].model
            return cell
        }
        viewModel.sections.asObservable()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
            
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.section == 0{
                self.tabBarController?.tabBar.hideBadge(onItemIndex: 1)
                let vc = NewFriendViewController()
                vc.title = "新的朋友"
                self.navigationController?.pushViewController(vc, animated: true)
                UserDefaults.standard.setValue(nil, forKey: "friendRequestCount")
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                
            } else if indexPath.section == 1 {
                let vc = FriendMapViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if indexPath.section == 2 {
               let friend = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.row]
                let vc = UserInfoViewController()
                vc.visitorUserId = Int(friend.userId)
//                vc.title = friend.nickName
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0
        }
        return 10
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 55
        }else if indexPath.section == 2 {
            return 70
        }
    return 50
    }
}

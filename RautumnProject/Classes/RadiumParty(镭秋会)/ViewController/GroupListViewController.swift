//
//  GroupListViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import SwiftyDrop
class GroupListViewController: UITableViewController {
    public var groupId = 0
    public var mainGroUserId = 0
    var mainGroup = false
    typealias TableSectionModel = AnimatableSectionModel<String, Friend>
  fileprivate  let animatedDataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
  public  let sections = Variable([TableSectionModel]())
    var delete = Variable(false)
    var deleteModels = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "群成员列表"
         initTableView()
        fetchData(showHUB: true)
        do { //删除群成员
            let activityIndicator = ActivityIndicator()
        let reqeust = delete.asObservable()
            .filter{$0 == true}
            .flatMap({ (_) -> Observable<Result<ResponseInfo<EmptyModel>>> in
                var userIds = ""
                self.deleteModels.forEach({ (model) in
                  let model = model as! Friend
                    userIds += "\(model.userId),"
                })
              return RequestProvider.request(api:ParametersAPI.deleteRauGroupUser(mainGroUserId: UserModel.shared.id, rgId: self.groupId, userIds: (userIds as NSString).substring(to: (userIds as NSString).length - 1))).mapObject(type: EmptyModel.self)
            })
          .trackActivity(activityIndicator)
          .shareReplay(1)
            reqeust.flatMap{$0.unwarp()}
            .subscribe(onNext: { (_) in
                self.animatedDataSource.sectionModels[0].items.forEach({ (model) in
                    model.isShowCheck.value = false
                })
                self.navigationItem.rightBarButtonItem?.title = "编辑"
               self.fetchData(showHUB: false)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
          
            reqeust.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
        do{
            if mainGroup {
                navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "编辑")
                navigationItem.rightBarButtonItem!.rx.tap
                    .subscribe(onNext: {[unowned self] (_) in
                        if self.navigationItem.rightBarButtonItem?.title == "编辑"{ //编辑
                            self.animatedDataSource.sectionModels[0].items.forEach({ (model) in
                                model.isShowCheck.value = true
                            })
                            self.navigationItem.rightBarButtonItem?.title = "删除"
                        }else{ //删除
                            if self.deleteModels.count == 0 { //退出编辑界面
                                self.animatedDataSource.sectionModels[0].items.forEach({ (model) in
                                    model.isShowCheck.value = false
                                })
                                self.navigationItem.rightBarButtonItem?.title = "编辑"
                            }else{ //删除
                                self.delete.value = true
                            }
                        }
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            }
        }
    }
    fileprivate func fetchData(showHUB:Bool){
        let activityIndicator = ActivityIndicator()
        if showHUB {
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "加载中...", for: view)).addDisposableTo(rx_disposeBag)
        }
        let request =  RequestProvider.request(api: ParametersAPI.getRauGroupUser(groupId: groupId)).mapObject(type: GroupListModel.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.map{$0.result_data?.rauGroupUsers}.unwrap()
            .subscribe(onNext: { (models) in
                self.sections.value = [TableSectionModel(model: "", items: models)]
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    
    }
}
extension GroupListViewController{
    func initTableView()  {
        tableView.backgroundColor = bgColor
        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
        tableView.register(UINib(nibName: "FindFriendsViewCell", bundle: nil), forCellReuseIdentifier: "FindFriendsViewCell")
        
        
        bindViewModel()
    }
    
    func bindViewModel() {
        animatedDataSource.configureCell =  { (ds, tableView, indexPath, friend) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsViewCell", for: indexPath) as! FindFriendsViewCell
            cell.btn_lei.setTitle("发消息", for: .normal)
            cell.btn_lei.rx.tap.subscribe(onNext: {[unowned self] (_) in
                let conversationVC = RCDChatViewController()
                conversationVC.conversationType = .ConversationType_PRIVATE;
                conversationVC.targetId = "\(friend.userId)"
                conversationVC.title = friend.nickName
                conversationVC.displayUserNameInCell = false
                self.navigationController?.pushViewController(conversationVC, animated: true)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
            
            cell.btn_check.rx.tap.subscribe(onNext: {[unowned self] (_) in
                friend.isCheck.value = !friend.isCheck.value
                if friend.isCheck.value {
                    self.deleteModels.add(friend)
                }else{
                    self.deleteModels.remove(friend)
                }
                if self.deleteModels.count == 0 {
                    self.navigationItem.rightBarButtonItem?.title = "删除"
                }else{
                    self.navigationItem.rightBarButtonItem?.title = "删除(\(self.deleteModels.count))"
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
        
            cell.friend = friend
            return cell
             }

        sections.asObservable()
            .bindTo(tableView.rx.items(dataSource: animatedDataSource)).addDisposableTo(rx_disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
            let friend = self.animatedDataSource.sectionModels[indexPath.section].items[indexPath.row]
            let vc = UserInfoViewController()
            vc.visitorUserId = Int(friend.userId)
//            vc.title = friend.nickName
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 70
    }
}

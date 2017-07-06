//
//  NewFriendViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import SwiftyDrop
import UIKit
import RxDataSources
import RxSwift
class NewFriendViewController: UITableViewController {
    typealias TableSectionModel = AnimatableSectionModel<String, NewFriend>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [NewFriend]()
    
    var isGroup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            tableView.backgroundColor = bgColor
            tableView.tableFooterView = UIView()
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
        tableView.register(UINib(nibName: "NewFriendViewCell", bundle: nil), forCellReuseIdentifier: "NewFriendViewCell")
        }
        
        do{
            
            if isGroup {
                
              getApplyJion()
            } else {
                getNewFriend()
            }
            
            sections.asObservable().bindTo(tableView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
            
            dataSource.configureCell =  { (ds, tableView, indexPath, friend) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewFriendViewCell", for: indexPath) as! NewFriendViewCell
                cell.friend = friend
                cell.img_icon.tag = indexPath.row
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImg_icon(tap:)))
                
                cell.img_icon.addGestureRecognizer(tap)
                cell.btn_accept.tag = indexPath.row
                
                if self.isGroup {
                    cell.btn_accept.setTitle("同意", for: .normal)
        
                }
                
                cell.delegate = self
                return cell
            }
            
            dataSource.canEditRowAtIndexPath = { _ in
                return true
            }
            
            let deleteFriendRequest = tableView.rx.itemDeleted.flatMap({ (indexPath) -> Observable<Result<ResponseInfo<EmptyModel>>> in
                self.items.remove(at: indexPath.row)
                let model = self.dataSource.sectionModels[indexPath.section].items[indexPath.row]
                
                //  http://www.rautumn.com:8070/appserver/api?action=delApplyJoinGroup&applyJoinGroupId=11
                
                if self.isGroup{
                    
                    return RequestProvider.request(api: ParametersAPI.delApplyJoinGroup(applyJoinGroupId: model.applyJoinGroupId)).mapObject(type: EmptyModel.self)
                }
                
                return RequestProvider.request(api: ParametersAPI.deleteFShow(fId: model.fId)).mapObject(type:EmptyModel.self)
            })
            .shareReplay(1)
            
            deleteFriendRequest.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
              Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            deleteFriendRequest.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
                self.sections.value = [TableSectionModel(model: "", items: self.items)]
            }, onError: nil, onCompleted: nil, onDisposed: nil)
             .addDisposableTo(rx_disposeBag)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UserInfoViewController()
        
        vc.visitorUserId = self.items[indexPath.row].userId
        //        vc.title = self.friend.nickName
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    fileprivate func getNewFriend() {
        
        let activityIndicator = ActivityIndicator()
        
//        if let model = DBTool.shared.newFriend(){
//            print("本地 = \(model)")
//            self.sections.value = [TableSectionModel(model: "", items: model.friends)]
//        }else{
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
//        }
        
        let request =  RequestProvider.request(api: ParametersAPI.newFriends(pageIndex: 1, pageSize: 10)).mapObject(type: NewFriendModel.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
                //                    self.items = model.friends
                if model.friends.count == 0 {
                    return
                }
                for friend in model.friends {
                    self.items.append(friend)
                }
                
//                DBTool.shared.saveNewFriend(newFriendModel: model)
                self.sections.value = [TableSectionModel(model: "", items: [])]
                self.sections.value = [TableSectionModel(model: "", items: self.items)]
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    
        
    }
    
    fileprivate func getApplyJion() {

                
        let request = RequestProvider.request(api: ParametersAPI.getApplyJoinGroup()
        )
            .mapObject(type: ApplyGroupModel.self)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            
            .subscribe(onNext: {[unowned self] (model) in
                
                log.info("sfjajfkajfkjf = \(model.list)")
                
                for info in model.list {
//                    if info.msg == "test" {
//                        continue
//                    }
                    
                    var friend = NewFriend()
                    friend.userId = info.activeUserInfoId
                    friend.fId = info.beAddGroupId
                    friend.applyJoinGroupId = info.applyJoinGroupId
                    friend.msg = info.msg
                    friend.isGroup = true
                    friend.state.value = 4
                    friend.headPortUrl = info.headPortUrl
                    friend.nickname = info.nickname
                    self.items.append(friend)
                }
                

                self.sections.value = [TableSectionModel(model: "", items: [])]
                self.sections.value = [TableSectionModel(model: "", items: self.items)]
                print("section = \(self.sections.value)")
                
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        
    }
    
    func tapImg_icon(tap:UITapGestureRecognizer){
          let model = self.dataSource.sectionModels[0].items[tap.view!.tag]
        let vc = UserInfoViewController()
        vc.visitorUserId = model.userId
//        vc.title = model.nickname
        navigationController?.pushViewController(vc, animated: true)

    }
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension NewFriendViewController : NewFriendViewCellDelegate{
    func  didClickedAcceptBtn(btn:UIButton,cell:NewFriendViewCell){
        var model = self.dataSource.sectionModels[0].items[btn.tag]
        
        if model.isGroup {
            
            let request = RequestProvider.request(api: ParametersAPI.agrredJoinGroup(userId: model.userId, rgId: model.fId))
            .mapObject(type: EmptyModel.self)
            .shareReplay(1)
            
            request.flatMap{($0.unwarp())}
                .subscribe(onNext: { (_) in
                    print("同意加入")
                    model.state.value = 3
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            return
        }
        
         let request = RequestProvider.request(api: ParametersAPI.friendsAgreeOrDelete(beAddedUserInfoId: model.userId, type: 1)).mapObject(type: EmptyModel.self)
        .shareReplay(1)
        request.flatMap{$0.unwarp()}
        .subscribe(onNext: { (_) in
            model.state.value = 3
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAddressBooksNotifation"), object: nil)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }

}

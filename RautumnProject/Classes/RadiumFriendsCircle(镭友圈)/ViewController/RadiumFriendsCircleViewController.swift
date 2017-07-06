//
//  RadiumFriendsCircleViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import SDAutoLayout
import ObjectMapper
class RadiumFriendsCircleViewController: RadiumFriendsCircleBaseViewController {

    
    var friendUid = 0
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            tableView.tableFooterView = UIView()
          }
        
        if isFriendHistory {
            
            
            loadFriendHistoryCircle()
        } else {
            
            loadData()
            fecthData = {
                self.loadData()
            }
        }
        
        
    }
    
    // 加载
    func loadFriendHistoryCircle() {
        
        
        let request = RequestProvider.request(api: ParametersAPI.getMyFriendsCircleList(friendUid: friendUid, pageIndex: pageIndex)).mapObject(type: CircleDynamicListModel.self)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
                var frames = [RautumnFriendsCircleFrame]()
                model.rautumnFriendsCircleList.forEach({ (rautumnFriendsCircle) in
                    let modelFrame = RautumnFriendsCircleFrame()
                    modelFrame.rautumnFriendsCircle = rautumnFriendsCircle
                    frames.append(modelFrame)
                })
                
                if self.pageIndex == 1{
//                    UserModel.shared.userCount.value = model.userCount
//                    DBTool.shared.saveRadiumFriendsCircle(dict: Mapper<CircleDynamicListModel>().toJSON(model), type: 1)
                    self.dataSource = frames
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.isHidden = self.dataSource.count < 10
                    
                }else{
                    if model.rautumnFriendsCircleList.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource.append(contentsOf: frames)
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()
                //        self.tableView.reloadDataWithExistedHeightCache()
                //        self.tableView.reloadDataWithInsertingData(atTheBeginingOfSection: 0, newDataCount: self.dataSource.count)
                }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                Drop.down(error)
            }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
}

extension RadiumFriendsCircleViewController{
    fileprivate func loadData(){

        
        if self.pageIndex == 1{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetRautumnAppImg"), object: self)
            
            if let json = DBTool.shared.radiumFriendsCircle(type:1){
                let model = Mapper<CircleDynamicListModel>().map(JSON: json)
                UserModel.shared.r.value = model!.r
                UserModel.shared.userCount.value = model!.userCount
                var frames = [RautumnFriendsCircleFrame]()
                model?.rautumnFriendsCircleList.forEach({ (rautumnFriendsCircle) in
                    let modelFrame = RautumnFriendsCircleFrame()
                    modelFrame.rautumnFriendsCircle = rautumnFriendsCircle
                    frames.append(modelFrame)
                })
                self.dataSource = frames
                self.tableView.reloadData()
            }
    
        }
   
        
        self.tableView.reloadDataWithInsertingData(atTheBeginingOfSection: 0, newDataCount: self.dataSource.count)
      let request =   RequestProvider.request(api: ParametersAPI.getRautumnFriendsCircleList(pageIndex: pageIndex, type: 1)).mapObject(type: CircleDynamicListModel.self)
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
      .subscribe(onNext: {[unowned self] (model) in
        var frames = [RautumnFriendsCircleFrame]()
        model.rautumnFriendsCircleList.forEach({ (rautumnFriendsCircle) in
            let modelFrame = RautumnFriendsCircleFrame()
            modelFrame.rautumnFriendsCircle = rautumnFriendsCircle
            frames.append(modelFrame)
        })
    
        if self.pageIndex == 1{
            UserModel.shared.userCount.value = model.userCount
            DBTool.shared.saveRadiumFriendsCircle(dict: Mapper<CircleDynamicListModel>().toJSON(model), type: 1)
            self.dataSource = frames
            self.tableView.st_header.endRefreshing()
            self.tableView.mj_footer.isHidden = self.dataSource.count < 10

        }else{
            if model.rautumnFriendsCircleList.count == 0{
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else{
                self.dataSource.append(contentsOf: frames)
                self.tableView.mj_footer.endRefreshing()
            }
        }
        self.tableView.reloadData()
//        self.tableView.reloadDataWithExistedHeightCache()
//        self.tableView.reloadDataWithInsertingData(atTheBeginingOfSection: 0, newDataCount: self.dataSource.count)
      }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
            self.tableView.st_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            Drop.down(error)
        }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    }
    
}

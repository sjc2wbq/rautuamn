//
//  MyFriendsCircleViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyDrop
class MyFriendsCircleViewController: RadiumFriendsCircleBaseViewController {
var emptyDisplayCondition = false
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "您好没有发布过任何的动态！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        do{
        tableView.tableFooterView = UIView()
        }
        loadData()
        fecthData = {
            self.loadData()
        }
    }
}
extension MyFriendsCircleViewController{
    
   
    
    fileprivate func loadData(){
        
        
        if self.pageIndex == 1{
            
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GetRautumnAppImg"), object: self)
            
            if let json = DBTool.shared.radiumFriendsCircle(type:2){
                let model = Mapper<CircleDynamicListModel>().map(JSON: json)
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
    
        let request =   RequestProvider.request(api: ParametersAPI.getRautumnFriendsCircleList(pageIndex: pageIndex, type: 2)).mapObject(type: CircleDynamicListModel.self)
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
                    DBTool.shared.saveRadiumFriendsCircle(dict: Mapper<CircleDynamicListModel>().toJSON(model), type: 2)
                    self.dataSource = frames
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.isHidden = self.dataSource.count < 10
                    self.emptyDisplayCondition = true
                }else{
                    if model.rautumnFriendsCircleList.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource.append(contentsOf: frames)
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()

                //                self.tableView.reloadDataWithInsertingData(atTheBeginingOfSection: 0, newDataCount: self.dataSource.count)
                }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error)
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
    
}

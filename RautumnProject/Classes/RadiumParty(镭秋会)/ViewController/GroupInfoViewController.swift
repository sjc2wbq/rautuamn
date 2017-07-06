//
//  GroupInfoViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
class GroupInfoViewController: UIViewController {
    let headerView = GroupInfoHeaderView.headerView()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn: UIButton!
  public var groupId = 0
    var raugroup : Raugroup?
    fileprivate var model:GroupDetailsModel?
    var groupType = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(GroupInfoViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "群信息"
        initTableView()
        fecthData()
    }
}
extension GroupInfoViewController:UITableViewDelegate,UITableViewDataSource{
    fileprivate func initTableView(){
        tableView.tableHeaderView = headerView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GroupInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupInfoTableViewCell")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupInfoTableViewCell")  as! GroupInfoTableViewCell
        cell.model = model
        cell.groupId = self.groupId
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let model = model {
        return 300 + model.introduce.height(15, wight: screenW - 16)
        }
        return 0
    }
}

extension GroupInfoViewController : UIAlertViewDelegate{
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            return
        }
        guard let model = model  else {
            return
        }
        let activityIndicator = ActivityIndicator()
        if model.mainGroup{
            let request = RequestProvider.request(api: ParametersAPI.dissolutionGroup(rgId: model.id)).mapObject(type: EmptyModel.self)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            request.flatMap{$0.unwarp()}
                .subscribe(onNext: { (_ ) in
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DissolutionGroupSuccessNotifation"), object: nil)
                    Drop.down("解散群组成功！", state: .success)
                })
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error ) in
                    Drop.down(error, state: .error)
                })
                .addDisposableTo(rx_disposeBag)
            
        }else{
            var type = 1
            
            if model.jion{ //删除并退出
                type = 2
            }else{ //申请加入
                type = 1
            }
            activityIndicator.asObservable().bindTo(isLoading(showTitle: type == 2 ? "" : "正在发送群组请求...", for: view)).addDisposableTo(rx_disposeBag)
            
            
            let request = RequestProvider.request(api: ParametersAPI.joinOutRauGroup(rgId: model.id,type:type))
                .mapObject(type: EmptyModel.self)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}
                .subscribe(onNext: { (_) in
                    if let _ = self.raugroup {
                        self.raugroup!.jion.value = true
                    }
                    self.model!.jion = true
                    self.btn.setTitle(self.model!.jion == true ? "删除并退出" : "申请加入", for: .normal)
                    if type == 2{
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        let conversationVC = RCDChatViewController()
                        conversationVC.groupId = model.id;
                        conversationVC.conversationType = .ConversationType_GROUP;
                        conversationVC.targetId = "\(model.id)"
                        conversationVC.title = model.name
                        conversationVC.displayUserNameInCell = false
                        self.navigationController?.pushViewController(conversationVC, animated: true)
                    }
                })
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error ) in
                    Drop.down(error, state: .error)
                })
                .addDisposableTo(rx_disposeBag)
            
        }
        

    }
    //删除并退出或者申请加入
    @IBAction func btnAction(_ sender: UIButton) {
        guard let model = model  else {
            return
        }
        var message = ""
        if model.mainGroup {
            message = "您确定要解散该群组？"
            let av = UIAlertView(title: "温馨提示", message: message, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            av.show()
        }else{
            if model.jion{ //删除并退出
                message = "您确定要退出该群？"
                let av = UIAlertView(title: "温馨提示", message: message, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                av.show()
            }else{
                
                let type = 1
                
                
                // 特殊群需要群组同意
                
                print("ssssss = \(Int(groupType))")
                
                
                if Int(groupType) > 0 {
                    
                    let vc = LeiTaViewController()
                    vc.userId = model.id
                    vc.isGroup = true
                    vc.sendMessage = "申请加入\(model.name)"
                    vc.title = "申请加群"
                    navigationController?.pushViewController(vc, animated: true)
                    
                    return
                }
                
                let activityIndicator = ActivityIndicator()
                activityIndicator.asObservable().bindTo(isLoading(showTitle: type == 1 ? "" : "正在发送群组请求...", for: view)).addDisposableTo(rx_disposeBag)
            
                // 普通群直接进入
                
                let request = RequestProvider.request(api: ParametersAPI.joinOutRauGroup(rgId: model.id,type:type))
                    .mapObject(type: EmptyModel.self)
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                request.flatMap{$0.unwarp()}
                    .subscribe(onNext: { (_) in
                        if let _ = self.raugroup {
                            self.raugroup!.jion.value = true
                        }
                        self.model!.jion = true
                        self.btn.setTitle(self.model!.jion == true ? "删除并退出" : "申请加入", for: .normal)
                        if type == 2{
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }else{
                            let conversationVC = RCDChatViewController()
                            conversationVC.groupId = model.id;
                            conversationVC.conversationType = .ConversationType_GROUP;
                            conversationVC.targetId = "\(model.id)"
                            conversationVC.title = model.name
                            conversationVC.displayUserNameInCell = false
                            self.navigationController?.pushViewController(conversationVC, animated: true)
                        }
                    })
                    .addDisposableTo(rx_disposeBag)
                
                request.flatMap{$0.error}.map{$0.domain}
                    .subscribe(onNext: { (error ) in
                        Drop.down(error, state: .error)
                    })
                    .addDisposableTo(rx_disposeBag)

            }
        }

 
    }
    fileprivate func fecthData(){
        let activityIndicator = ActivityIndicator()
        
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)

   let request = RequestProvider.request(api: ParametersAPI.groupDetails(groupId: groupId)).mapObject(type: GroupDetailsModel.self)
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
        .subscribe(onNext: { (model) in
            self.model = model
            self.headerView.model = model
            if model.mainGroup {
                self.btn.setTitle("解散群组", for: .normal)
            }else{
                self.btn.setTitle(model.jion == true ? "删除并退出" : "申请加入", for: .normal)

            }
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    
    }
}

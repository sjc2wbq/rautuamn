//
//  NearGroupViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//附近群组

import UIKit
import RxSwift
import SwiftyDrop
import RxDataSources
class NearGroupViewViewModel: RefreshViewModel {
    
    typealias TableSectionModel = AnimatableSectionModel<String, Raugroup>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Raugroup]()
    
    override init() {
        super.init()
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>)) {
        self.init()
        
        if let model = DBTool.shared.nearGroup(){
            self.sections.value = [TableSectionModel(model: "查看申请加入群信息", items:  [Raugroup()]),
                                   TableSectionModel(model: "", items:  model.rauGroups)]
        }
        
        let headerResponse  =  input.headerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyGroupModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.nearbyGroup(pageIndex: self.page.value)).mapObject(type: NearbyGroupModel.self)
            }
            .shareReplay(1)
        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .subscribe(onNext: { [unowned self] (info ) in
                DBTool.shared.saveNearGroup(group: info)
                let datas = info.rauGroups
                self.items = datas
                
                self.sections.value = [TableSectionModel(model: "查看申请加入群信息", items: [Raugroup()]),
                                       TableSectionModel(model: "", items: [])]
                self.sections.value = [TableSectionModel(model: "查看申请加入群信息", items:  [Raugroup()]),
                                       TableSectionModel(model: "", items:  self.items)]
        
                self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        let footerResponse  =  input.footerRefresh
            
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyGroupModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.nearbyGroup( pageIndex: self.page.value)).mapObject(type: NearbyGroupModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info.result_data?.rauGroups
            if let datas = datas{
                if datas.count == 0{
                    self.refreshState.value = .noHasNextPage
                    
                }else{
                    self.items += datas
                    self.refreshState.value = .hasNextPage
                    
                }
            }
            self.sections.value = [TableSectionModel(model: "查看申请加入群信息", items:  [Raugroup()]),
                                   TableSectionModel(model: "", items:  self.items)]
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        footerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
    }
}
class NearGroupViewController: UITableViewController {
    var viewModel : NearGroupViewViewModel!
    var emptyDisplayCondition = false
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "附近暂无群组！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
    
        
        do{
          NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "DissolutionGroupSuccessNotifation"))
            .subscribe(onNext: {[unowned self] (_) in
                self.tableView.st_header.beginRefreshing()
            })
            .addDisposableTo(rx_disposeBag)
        
        }
        do{
            tableView.register(UINib(nibName: "NearGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "NearGroupTableViewCell")
            tableView.register(UINib(nibName: "AddressBookNewFriendViewCell", bundle: nil), forCellReuseIdentifier: "AddressBookNewFriendViewCell")
            
            tableView.delegate = nil
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 114, right: 0)
            tableView.dataSource = nil
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            tableView.st_header = STRefreshHeader()
            tableView.st_header.beginRefreshing()
            tableView.addFooterRefresh()
//            tableView.mj_footer.isHidden = true
            tableView.tableFooterView = UIView()

        }
        
        
        
        do{
         NotificationCenter.default.rx.notification(Notification.Name(rawValue: "createGroupSuccessNotifation"))
            .subscribe(onNext: {[unowned self] (noti) in
                 let model = noti.object as! Raugroup
            self.viewModel.items.insert(model, at: 0)
                self.viewModel.sections.value = [TableSectionModel(model: "查看申请加入群信息", items:  [Raugroup()]),
                                                TableSectionModel(model: "", items:  self.viewModel.items)]
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        do{
            viewModel = NearGroupViewViewModel(input:(headerRefresh: tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh))
            

            viewModel.dataSource.configureCell =  {[unowned self] (ds, tableView, indexPath, raugroup) in 

                print("sfafads = \(self.viewModel.sections.value.count)/n index = \(indexPath.section) row = \(indexPath.row)")
                
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookNewFriendViewCell", for: indexPath) as! AddressBookNewFriendViewCell
                    cell.aTitleLabel.text = "查看申请加入群信息"
                    cell.iconImage.image = UIImage.init(named: "申请群组")
                    cell.unReadView.isHidden = true
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NearGroupTableViewCell", for: indexPath) as! NearGroupTableViewCell
                cell.btn_chat.tag = indexPath.row
                cell.btn_chat.addTarget(self, action: #selector(NearGroupViewController.chatGroupAction(btn:)), for: .touchUpInside)
                cell.raugroup = raugroup
                return cell
            }
            
           
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
  
            
            tableView.rx.itemSelected
                .subscribe(onNext: {[unowned self] (indexPath) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    
                    if indexPath.section == 0 {
                        let vc = NewFriendViewController()
                        vc.title = "申请加群"
                        vc.isGroup = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                    
                    let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                    if model.jion.value == true {
                        self.enterGroupChatVC(model: model)
                    }else{
                    let vc = GroupInfoViewController()
                        vc.groupId = model.id
                        vc.raugroup = model
                        vc.groupType = Int(model.groupType)!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            
        }
        do  {
            viewModel.refreshState.asObservable().subscribe(onNext: {[unowned self] (status) in
                switch status{
                case .loadDataFailure,.headerRefreshFinish:
                    self.tableView.mj_footer.resetNoMoreData()
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                    self.emptyDisplayCondition = true
                case .noHasNextPage:
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                default:
                    self.tableView.mj_footer.endRefreshing()
                }
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        

        if section == 1 {
            
            return 0
        }
        

        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.section == 0 {
            
            return 55
        }
        
        return 100
    }

    @objc fileprivate func chatGroupAction(btn:UIButton){
        let model = viewModel.dataSource.sectionModels[1].items[btn.tag]
        enterGroupChatVC(model: model)
        
    }
    fileprivate func enterGroupChatVC(model:Raugroup){
        if model.jion.value{ //进入群聊
            let conversationVC = RCDChatViewController()
            conversationVC.groupId = model.id;
            conversationVC.conversationType = .ConversationType_GROUP;
            conversationVC.targetId = "\(model.id)"
            conversationVC.title = model.name
            conversationVC.displayUserNameInCell = false
            self.navigationController?.pushViewController(conversationVC, animated: true)
        }else{ //加入群组
            
            
            
            // 特殊群需要群组同意
            
            print("ssssss = \(Int(model.groupType)!)")
            
            if Int(model.groupType)! > 0 {
                
                let vc = LeiTaViewController()
                vc.userId = model.id
                vc.isGroup = true
                vc.sendMessage = "申请加入\(model.name)"
                vc.title = "申请加群"
                navigationController?.pushViewController(vc, animated: true)
                
                return
            }
            
            // 普通群直接进入
            let activityIndicator = ActivityIndicator()
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在发送群组请求...", for: view)).addDisposableTo(rx_disposeBag)
            
            let request = RequestProvider.request(api: ParametersAPI.joinOutRauGroup(rgId: model.id,type:1))
                .mapObject(type: EmptyModel.self)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}
                .subscribe(onNext: { (_) in
                    //                let av = UIAlertController(title: "温馨提示", message: "加群请求已发出！", preferredStyle: .alert)
                    //                av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                    //
                    //                }))
                    //                self.present(av, animated: true, completion: nil)
                    model.jion.value = true
                    let conversationVC = RCDChatViewController()
                    conversationVC.conversationType = .ConversationType_GROUP;
                    conversationVC.targetId = "\(model.id)"
                    conversationVC.title = model.name
                    conversationVC.groupId = model.id;
                    conversationVC.displayUserNameInCell = false
                    self.navigationController?.pushViewController(conversationVC, animated: true)
                    
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

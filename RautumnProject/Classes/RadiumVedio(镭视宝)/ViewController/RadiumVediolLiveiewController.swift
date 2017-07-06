
//
//  RadiumVediolLiveiewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import SwiftyDrop
class RadiumVediolLiveViewModel: RefreshViewModel {
    //Friend
    typealias TableSectionModel = AnimatableSectionModel<String, RvUseful>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [RvUseful]()
    override  init() {
        super.init()
    }
    convenience  init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>)) {
        self.init()
        
        if let model = DBTool.shared.live(){
            self.sections.value = [TableSectionModel(model: "", items:  [])]
            self.sections.value = [TableSectionModel(model: "", items:  model.data)]
        }
        
        let headerResponse  = input.headerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<RvUsefulModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.rvUseful(type: 2, newOrHot: 1, pageIndex: self.page.value)).mapObject(type: RvUsefulModel.self)
            }.shareReplay(1)
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { [unowned self] (model ) in
            self.items = model.data
            DBTool.shared.saveLIVE(model: model)
            self.sections.value = [TableSectionModel(model: "", items:  [])]
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        let footerResponse  =  input.footerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<RvUsefulModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.rvUseful(type: 2, newOrHot: 1, pageIndex: self.page.value)).mapObject(type: RvUsefulModel.self)
            }.shareReplay(1)
        
        footerResponse.flatMap{$0.unwarp()}.map{$0.result_data?.data}.unwrap().subscribe(onNext: { [unowned self] (friends ) in
            if friends.count == 0{
                self.refreshState.value = .noHasNextPage
            }else{
                self.items += friends
                self.sections.value = [TableSectionModel(model: "", items:  self.items)]
                self.refreshState.value = .hasNextPage
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        footerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
}
class RadiumVediolLiveiewController: UITableViewController {
    var viewModel : RadiumVediolLiveViewModel!
    var joinChatRoomSuccess = Variable(false)
    var useful : RvUseful!
    var emptyDisplayCondition = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        joinChatRoomSuccess.value = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  bgColor
        initTableView()
        
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "暂无RSV视频"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
    }
}
extension RadiumVediolLiveiewController{
    func initTableView()  {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.addFooterRefresh()
        tableView.st_header = STRefreshHeader()
        tableView.st_header.beginRefreshing()
        tableView.mj_footer.isHidden = true
        tableView.backgroundColor = bgColor
        tableView.contentInset = UIEdgeInsetsMake(0, 0,100, 0)
        tableView.tableFooterView = UIView()
        tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
        tableView.register(UINib(nibName: "RadiumVediolLiveViewCell", bundle: nil), forCellReuseIdentifier: "RadiumVediolLiveViewCell")
        bindViewModel()
    }
    func bindViewModel() {
        do{
            let activityIndicator = ActivityIndicator()
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在进入直播间...", for: UIApplication.shared.keyWindow!)).addDisposableTo(rx_disposeBag)
            
            let request = joinChatRoomSuccess.asObservable()
                .filter{$0 == true}
                .flatMap{_ in RequestProvider.request(api: ParametersAPI.chatroomQueryUser(rsvId: self.useful.id))
                    .mapObject(type: UserListModel.self)
                    .trackActivity(activityIndicator)
                }
                .shareReplay(1)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.unwarp()}.map{$0.result_data?.userList}.unwrap()
                .subscribe(onNext: { [unowned self] (userList) in
                    let vc = LiveViewController()
                    vc.conversationType = .ConversationType_CHATROOM
                    vc.targetId = "\(self.useful.id)"
                    vc.setMoiveSource(URL(string:self.useful.videoUrl))
                    vc.userList.addObjects(from: userList.map({ (userList) -> RCUserInfo in
                        let userInfo = UserInfo()
                        userInfo.name = userList.nickName
                        userInfo.portraitUri = userList.headPortUrl
                        userInfo.userId = userList.userId
                        return userInfo
                    }))
                    vc.title = self.useful.title
                    self.navigationController?.pushViewController(vc, animated: true)
                    }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)

        
        }
        
        viewModel = RadiumVediolLiveViewModel(input:(headerRefresh:tableView.st_header.rx.refresh,
                                         footerRefresh:tableView.mj_footer.rx.refresh))
        
        viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, rvUseful) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadiumVediolLiveViewCell", for: indexPath) as! RadiumVediolLiveViewCell
            cell.rvUseful = rvUseful
            return cell
        }
        viewModel.sections.asObservable()
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
        
        do {
            viewModel.refreshState.asObservable().subscribe(onNext: {[unowned self] (status) in
                switch status{
                case .loadDataFailure,.headerRefreshFinish:
                    self.tableView.mj_footer.resetNoMoreData()
                    self.tableView.mj_footer.endRefreshing()
                    self.tableView.st_header.endRefreshing()
                    self.emptyDisplayCondition = true
                case .noHasNextPage:
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                default:
                    self.tableView.mj_footer.endRefreshing()
                }
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        }

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.joinChatRoomSuccess.value {
            
            return
        }
        
        let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.row]
        RCIMClient.shared().joinChatRoom("\(model.id)", messageCount: 10, success: {[unowned self] in
            self.useful = model
            self.joinChatRoomSuccess.value = true
        }) { (_) in
            Drop.down("进入直播间失败！", state: .error)
        }
     
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.mj_footer.isHidden = self.viewModel.dataSource.sectionModels[indexPath.section].items.count < 10
        return 270
    }

}

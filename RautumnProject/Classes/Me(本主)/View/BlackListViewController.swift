//
//  BlackListViewController.swift
//  ObjectsProject
//
//  Created by Raychen on 2016/10/20.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import MBProgressHUD
import ObjectMapper
struct BlacklistModel {
    var blacklists: [BlackList] = []
    
    init?(map: Map) {}
}

extension BlacklistModel: Mappable {
    mutating func mapping(map: Map) {
        blacklists <- map["blacklists"]
    }
}

// MARK: - Blacklist

struct BlackList {
    var headPortrait = ""
    var date = ""
    var userId = 0
    var nickName = ""
    
    init?(map: Map) {}
}

extension BlackList: Mappable {
    mutating func mapping(map: Map) {
        headPortrait <- map["headPortrait"]
        date <- map["date"]
        userId <- map["userId"]
        nickName <- map["nickName"]
    }
}
extension BlackList: IdentifiableType,Equatable {
    var identity: Int {
        return userId
    }
}
func ==(lhs: BlackList, rhs: BlackList) -> Bool {
    return lhs.userId == rhs.userId
}

class BlackListViewModel: RefreshViewModel {
    
    typealias TableSectionModel = AnimatableSectionModel<String, BlackList>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    var sections = Variable([TableSectionModel]())
    var items = [BlackList]()
    override  init() {
        super.init()
    }
    
    convenience  init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>,itemDeleted:Observable<IndexPath>)) {
    self.init()
   
    
        input.itemDeleted.subscribe(onNext: {[unowned self] (indexPath) in
            
            var items = self.dataSource.sectionModels[indexPath.section].items
            let item = items[indexPath.row]
            RCIMClient.shared().remove(fromBlacklist: "\(item.userId)", success: nil, error: nil)
            self.items.remove(at: indexPath.row)
            self.sections.value = [TableSectionModel(model: "", items: self.items)]
            let response =  RequestProvider.request(api: ParametersAPI.blacklist(receiveUserInfoId: item.userId, type: 2)).mapObject(type: EmptyModel.self)
                .shareReplay(1)
            
            response.flatMap{$0.error}.map{$0.domain}.subscribe(onNext: { (error) in
                MBProgressHUD.bwm_showTitle(error, to: UIApplication.shared.keyWindow!, hideAfter: 2, msgType: .error)
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(self.disposeBag)
            response.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(self.disposeBag)

            
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        
        let headerResponse  =  input.headerRefresh
            .debug()
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<BlacklistModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.getPullTheBlack(pageIndex: self.page.value)).mapObject(type: BlacklistModel.self)
            }
            .shareReplay(1)
        

        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info?.blacklists
            if let datas = datas{
                self.items = datas
  
            }
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
            }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        let footerResponse  =  input.footerRefresh
            .debug()
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<BlacklistModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.getPullTheBlack(pageIndex: self.page.value)).mapObject(type: BlacklistModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info.result_data?.blacklists
            if let datas = datas{
                if datas.count == 0{
                    self.refreshState.value = .noHasNextPage
                    
                }else{
                    self.items += datas
                    self.refreshState.value = .hasNextPage
                    
                }
            }
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        footerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
            }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
    }
}
class BlackListViewController: UITableViewController {
    
    var emptyDisplayCondition = false
    var viewModel:BlackListViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "黑名单"
        initTableView()
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "暂时没有黑名单数据！"
//                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
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
}
extension BlackListViewController{
    func initTableView()  {
        tableView.addFooterRefresh()
        tableView.st_header = STRefreshHeader()
        self.tableView.st_header.beginRefreshing()
        self.tableView.mj_footer.isHidden = true
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
        tableView.backgroundColor = bgColor
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "BlackListViewCell", bundle: nil), forCellReuseIdentifier: "BlackListViewCell")
        bindViewModel()
    }
    func bindViewModel() {
        viewModel = BlackListViewModel(input: (headerRefresh:tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh,itemDeleted:tableView.rx.itemDeleted.asObservable()))

        viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlackListViewCell", for: indexPath) as! BlackListViewCell
            cell.model = model

            return cell
        }
        viewModel.sections.asObservable()
            .do(onNext: { (models) in
//                self.tableView.reloadEmptyDataSet()
            })
            .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
        
        tableView.rx.itemSelected
            .map { ($0, animated: true) }
            .subscribe(onNext: tableView.deselectRow)
            .addDisposableTo(rx_disposeBag)
        
        viewModel.dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.mj_footer.isHidden = self.viewModel.dataSource.sectionModels[indexPath.section].items.count < 10
        return 60
    }
}


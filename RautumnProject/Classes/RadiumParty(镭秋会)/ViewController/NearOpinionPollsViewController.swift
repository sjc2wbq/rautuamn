//
//  NearOpinionPollsViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//镭友民调

import UIKit
import RxSwift
import SwiftyDrop
import RxDataSources
class NearOpinionPollsViewModel: RefreshViewModel {
    typealias TableSectionModel = AnimatableSectionModel<String, Raufricivilmediation>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Raufricivilmediation]()
    
    override init() {
        super.init()
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>)) {
        self.init()
        
        if let model = DBTool.shared.nearOpinionPolls(){
            self.sections.value = [TableSectionModel(model: "", items:  model.rauFriCivilMediations)]
        }
        
        let headerResponse  =  input.headerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<RauFriCivilMediationModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.rauFriCivilMediation(pageIndex: self.page.value)).mapObject(type: RauFriCivilMediationModel.self)
            }
            .shareReplay(1)
        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .subscribe(onNext: { [unowned self] (info ) in
            DBTool.shared.saveNearOpinionPolls(model: info)
            let datas = info.rauFriCivilMediations
            self.items = datas

            self.sections.value = [TableSectionModel(model: "", items: [])]
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        let footerResponse  =  input.footerRefresh
            
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<RauFriCivilMediationModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.rauFriCivilMediation( pageIndex: self.page.value)).mapObject(type: RauFriCivilMediationModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info.result_data?.rauFriCivilMediations
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
class NearOpinionPollsViewController: UITableViewController {
    var viewModel : NearOpinionPollsViewModel!
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "附近暂无民调！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 114, right: 0)
        do{
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "publishRFCMSuccessNotifation"))
            .subscribe(onNext: { (_) in
        self.tableView.st_header.beginRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        
        do{
            tableView.register(UINib(nibName: "NearOpinionPollsTableViewCell", bundle: nil), forCellReuseIdentifier: "NearOpinionPollsTableViewCell")
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            tableView.st_header = STRefreshHeader()
            tableView.st_header.beginRefreshing()
            tableView.addFooterRefresh()
//            tableView.mj_footer.isHidden = true
            tableView.tableFooterView = UIView()
        }
        
        do{
            viewModel = NearOpinionPollsViewModel(input:(headerRefresh: tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh))
            
            viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, raufricivilmediation) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "NearOpinionPollsTableViewCell", for: indexPath) as! NearOpinionPollsTableViewCell
                cell.raufricivilmediation = raufricivilmediation
                return cell
            }
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
            
            tableView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
                let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                let vc = NearOpinionPollsDetailViewController(nibName: "NearOpinionPollsDetailViewController", bundle: nil)
                vc.rfcmId = model.id
                self.navigationController?.pushViewController(vc, animated: true)
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        self.tableView.mj_footer.isHidden =
        return 50
    }
}

//
//  NearActivityViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//附近活动

import UIKit
import RxSwift
import RxDataSources
class NearActivityViewModel:  RefreshViewModel{
    typealias TableSectionModel = AnimatableSectionModel<String, Rauactivitie>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Rauactivitie]()
    
    override init() {
        super.init()
        do{
            NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "publishActivitySuccessNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    let model = noti.object as! Rauactivitie
                    self.items.insert(model, at: 0)
                    self.sections.value = [TableSectionModel(model: "", items: self.items)]
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(disposeBag)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>)) {
        self.init()
        
        if let model = DBTool.shared.nearActivity(){
            self.sections.value = [TableSectionModel(model: "", items:  model.rauActivities)]
        }
        let headerResponse  =  input.headerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyActivityModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.nearbyActivity(pageIndex: self.page.value)).mapObject(type: NearbyActivityModel.self)
            }
            .shareReplay(1)
        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .subscribe(onNext: { [unowned self] (info ) in
                DBTool.shared.saveNearActivity(activity: info)

            let datas = info.rauActivities
                
                self.items = datas

            self.sections.value = [TableSectionModel(model: "", items:  [])]
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        let footerResponse  =  input.footerRefresh
            
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyActivityModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.nearbyActivity( pageIndex: self.page.value)).mapObject(type: NearbyActivityModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info.result_data?.rauActivities
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
class NearActivityViewController: UITableViewController {

    var viewModel : NearActivityViewModel!
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "RefreshActivityDataNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    self.tableView.st_header.beginRefreshing()
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)

        //publishActivitySuccessNotifation
        
        }
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "附近暂无活动！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
    
        do{
            tableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
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
            viewModel = NearActivityViewModel(input:(headerRefresh: tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh))
            
            viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, rauactivitie) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
                cell.rauactivitie = rauactivitie
                return cell
            }
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
            
            tableView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
                let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                let vc = NearActivityDetailViewController()
                vc.raId = model.id
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        self.tableView.mj_footer.isHidden = 
        return 124
    }

}

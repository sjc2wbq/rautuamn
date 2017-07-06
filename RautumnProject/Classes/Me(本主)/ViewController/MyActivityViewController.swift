//
//  MyActivityViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
class MyActivityViewModel:  RefreshViewModel{
    typealias TableSectionModel = AnimatableSectionModel<String, Rauactivitie>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Rauactivitie]()
    
    override init() {
        super.init()
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>,type:Observable<Int>)) {
        self.init()
        
        let headerResponse  =  input.headerRefresh
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<NearbyActivityModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.iJoinedTheActivity(type:type,pageIndex: self.page.value)).mapObject(type: NearbyActivityModel.self)
            }
            .shareReplay(1)
        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info?.rauActivities
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
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<NearbyActivityModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.iJoinedTheActivity(type:type,pageIndex: self.page.value)).mapObject(type: NearbyActivityModel.self)
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
extension UIViewController  {


}
class MyActivityViewController: UITableViewController {
    var viewModel : MyActivityViewModel!
    var type = Variable(1)
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()

        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = self.type.value == 1 ? "您还没有参加过任何活动！" : "您好没有组建过任何局！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        
        title = "活动详情"
        do{
            tableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
            tableView.backgroundColor = bgColor
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            tableView.addFooterRefresh()
            tableView.st_header = STRefreshHeader()
            tableView.st_header.beginRefreshing()
            tableView.mj_footer.isHidden = true
            tableView.tableFooterView = UIView()
        }

        do{
            viewModel = MyActivityViewModel(input:(headerRefresh: tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh,type:type.asObservable()))
            
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        self.tableView.mj_footer.isHidden =
        return 134
    }
}

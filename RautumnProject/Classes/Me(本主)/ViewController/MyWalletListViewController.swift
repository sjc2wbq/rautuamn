//
//  MyWalletBaseViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
class MyWalletListViewModel: RefreshViewModel {
    //Friend
    typealias TableSectionModel = AnimatableSectionModel<String, Wallet>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Wallet]()
    override  init() {
        super.init()
    }
    convenience  init(input:(footerRefresh:Observable<Void>,type:Observable<Int>)) {
        self.init()

        
        let headerResponse  = input.type.flatMap { (type) -> Observable<Result<ResponseInfo<MyWalletModel>>> in
                return RequestProvider.request(api: ParametersAPI.myWallet(type : type,pageIndex: 1)).mapObject(type: MyWalletModel.self)
                }
                .shareReplay(1)

            headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { [unowned self] (model ) in
            UserModel.shared.rautumnCurrency.value = model.rautumnCurrency
            self.items = model.countDate
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
                        self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
             headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
                let footerResponse  =  input.footerRefresh
                    .withLatestFrom(input.type)
                    .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<MyWalletModel>>> in
                        self.page.value += 1
                        return RequestProvider.request(api: ParametersAPI.myWallet(type : type,pageIndex: self.page.value)).mapObject(type: MyWalletModel.self)
                    }.shareReplay(1)
        
                footerResponse.flatMap{$0.unwarp()}.map{$0.result_data?.countDate}.unwrap().subscribe(onNext: { [unowned self] (friends ) in
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
class MyWalletListViewController: UITableViewController {
    var type = Variable(1)
    var viewModel : MyWalletListViewModel!
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = self.type.value == 1 ? "暂无收入记录！" : "暂无支出记录"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        do {
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.backgroundColor = bgColor
            //   tableView.tableHeaderView = headerView
            tableView.tableFooterView = UIView()
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            tableView.register(UINib(nibName: "MyWalletViewCell", bundle: nil), forCellReuseIdentifier: "MyWalletViewCell")

            tableView.addFooterRefresh()
            self.tableView.mj_footer.isHidden = true
            viewModel = MyWalletListViewModel(input:(footerRefresh:tableView.mj_footer.rx.refresh,
                                             type:type.asObservable()))
        }
    
        do {
            viewModel.refreshState.asObservable().subscribe(onNext: {[unowned self] (status) in
                switch status{
                case .loadDataFailure,.headerRefreshFinish:
                    self.tableView.mj_footer.resetNoMoreData()
                    self.tableView.mj_footer.endRefreshing()
                    self.emptyDisplayCondition = true
                case .noHasNextPage:
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                default:
                    self.tableView.mj_footer.endRefreshing()
                }
            },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            
        }
        
        do {
            viewModel.dataSource.configureCell =  {[unowned self] (ds, tableView, indexPath, wallet) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyWalletViewCell", for: indexPath) as! MyWalletViewCell
               cell.wallet = wallet
                
                return cell
            }
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
        
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.mj_footer.isHidden = self.viewModel.dataSource.sectionModels[indexPath.section].items.count < 10
        return 60
    }
}

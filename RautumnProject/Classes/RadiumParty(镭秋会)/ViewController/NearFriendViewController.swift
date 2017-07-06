//
//  NearFriendViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
// 附近镭友

import UIKit
import RxSwift
import RxDataSources
class NearFriendViewModel: RefreshViewModel {
    typealias TableSectionModel = AnimatableSectionModel<String, Friend>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Friend]()
    
    override init() {
        super.init()
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>)) {
        self.init()

        if let model = DBTool.shared.nearFriend(){
            self.sections.value = [TableSectionModel(model: "", items:  model.userInfos)]
        }
        //头部刷新
        let headerResponse  =  input.headerRefresh
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyRauFriendModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.nearbyRauFriend(pageIndex: self.page.value)).mapObject(type: NearbyRauFriendModel.self)
            }
            .shareReplay(1)
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .subscribe(onNext: { [unowned self] (info ) in
                DBTool.shared.saveNearFriend(friend: info)
            let datas = info.userInfos
                self.items = datas

            
            self.sections.value = [TableSectionModel(model: "", items:  [])]
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        //尾部刷新
        let footerResponse  =  input.footerRefresh
            
            .flatMapLatest {[unowned self] (_) -> Observable<Result<ResponseInfo<NearbyRauFriendModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.nearbyRauFriend( pageIndex: self.page.value)).mapObject(type: NearbyRauFriendModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info.result_data?.userInfos
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
class NearFriendViewController: UITableViewController {
    var viewModel : NearFriendViewModel!
var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()

        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "附近暂无镭友！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        do{
            tableView.register(UINib(nibName: "FindFriendsViewCell", bundle: nil), forCellReuseIdentifier: "FindFriendsViewCell")
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            tableView.st_header = STRefreshHeader()
            tableView.st_header.beginRefreshing()
            tableView.addFooterRefresh()
//            tableView.mj_footer.isHidden = true
            tableView.tableFooterView = UIView()
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 154, right: 0)

        }
     
        do{
            viewModel = NearFriendViewModel(input:(headerRefresh: tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh))
            viewModel.dataSource.configureCell =  { (ds, tableView, indexPath, friend) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsViewCell", for: indexPath) as! FindFriendsViewCell
                cell.btn_lei.tag = indexPath.row
                cell.btn_lei.addTarget(self, action: #selector(NearFriendViewController.leiTaAction(btn:)), for: .touchUpInside)
                cell.friend = friend
                return cell
            }
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)
            
            tableView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
                let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                let vc = UserInfoViewController()
                vc.visitorUserId = Int(model.userId)
//                vc.title = model.nickName
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
        return 70
    }
    func leiTaAction(btn:UIButton){
        let model = viewModel.dataSource.sectionModels[0].items[btn.tag]
        if model.friend {
            let conversationVC = RCDChatViewController()
            conversationVC.conversationType = .ConversationType_PRIVATE;
            conversationVC.targetId = "\(model.userId)"
            conversationVC.title = model.nickName
            conversationVC.displayUserNameInCell = false
            self.navigationController?.pushViewController(conversationVC, animated: true)
        }else{
            let vc = UserInfoViewController()
            vc.visitorUserId = Int(model.userId)
//            vc.title = model.nickName
            navigationController?.pushViewController(vc, animated: true)
        }

    }
}

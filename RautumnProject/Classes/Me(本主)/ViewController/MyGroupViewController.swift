//
//  MyGroupViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyDrop
import RxDataSources
import YUSegment
import Pages
typealias TableSectionModel = AnimatableSectionModel<String, Raugroup>

class MyGroupViewModel : RefreshViewModel {
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Raugroup]()

    override init() {
        super.init()
    }
    convenience init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>,type:Observable<Int>)) {
        self.init()
        
        let headerResponse  =  input.headerRefresh
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<MyGroupModel>>> in
                self.page.value = 1
                return RequestProvider.request(api: ParametersAPI.iCreatedTheGroup(pageIndex: self.page.value,type:type)).mapObject(type: MyGroupModel.self)
            }
            .shareReplay(1)

        
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.subscribe(onNext: { [unowned self] (info ) in
            let datas = info?.rauGroups
            if let datas = datas{
                self.items = datas
            }
            self.sections.value = [TableSectionModel(model: "", items: [])]
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        let footerResponse  =  input.footerRefresh
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<MyGroupModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.iCreatedTheGroup(pageIndex: self.page.value,type:type)).mapObject(type: MyGroupModel.self)
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
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        footerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    
    }
}
class MyGroupViewController: UITableViewController {
    var dissolutionGroup = Variable(false)
//    var viewModel : MyGroupViewModel!
    var dataSource = [Raugroup]()
    var page = 1
    var type = Variable(1)
    var reqeust = Variable(false)
var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            
            let request =  reqeust.asObservable()
                .filter{$0 == true}
                .flatMap{_ in RequestProvider.request(api: ParametersAPI.iCreatedTheGroup(pageIndex: self.page,type:self.type.value)).mapObject(type: MyGroupModel.self)}
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: { (model ) in
                self.reqeust.value = false
                if self.page == 1{
                    self.dataSource = model.rauGroups
                    self.tableView.st_header.endRefreshing()
                    self.emptyDisplayCondition = true
                }else{
                    if model.rauGroups.count == 0 {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource += model.rauGroups
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()

            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        
            request.flatMap{$0.error}
            .subscribe(onNext: {[unowned self] (_) in
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()

            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)

        }
        do {
           NotificationCenter.default.rx.notification(Notification.Name(rawValue: "UpdateGroupSuccessNotifation"))
            .subscribe(onNext: {[unowned self] (_) in
                self.tableView.st_header.beginRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = self.type.value == 1 ? "您还没有创建过任何群！" : "您还没有参加过任何群！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
    
        do{
            tableView.backgroundColor = bgColor
            tableView.tableFooterView = UIView()
            tableView.register(UINib(nibName: "NearGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "NearGroupTableViewCell")
            tableView.register(UINib(nibName: "MyGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGroupTableViewCell")
            tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (_) in
                self.page = 1
                self.reqeust.value = true
            })
    
            tableView.st_header.beginRefreshing()
            tableView.mj_footer = footer { [unowned self] in
                self.page += 1
            self.reqeust.value = true
            }
            tableView.mj_footer.isHidden = true
        }

         do{
            tableView.rx.itemSelected
            .subscribe(onNext: {[unowned self] (indexPath) in
                let model = self.dataSource[indexPath.row]
                let conversationVC = RCDChatViewController()
                conversationVC.groupId = model.id;
                conversationVC.conversationType = .ConversationType_GROUP;
                conversationVC.targetId = "\(model.id)"
                conversationVC.title = model.name
                conversationVC.displayUserNameInCell = false
                self.navigationController?.pushViewController(conversationVC, animated: true)
                
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)

        }
        

        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let raugroup = dataSource[indexPath.row]
        if self.type.value == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupTableViewCell", for: indexPath) as! MyGroupTableViewCell
            cell.btn_jiesao.addTarget(self, action: #selector(self.jiesan(btn:)), for: .touchUpInside)
            cell.btn_jiesao.tag = indexPath.row
            cell.raugroup = raugroup
            cell.btn_edit.rx.tap
                .subscribe(onNext: {[unowned self] (_) in
                    let vc = UIStoryboard(name: "RadiumParty", bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
                    vc.groupId = raugroup.id
                    self.navigationController?.pushViewController(vc, animated: true)
                    },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(cell.rx_reusableDisposeBag)
            
            return cell
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearGroupTableViewCell", for: indexPath) as! NearGroupTableViewCell
        cell.btn_chat.tag = indexPath.row
        cell.btn_chat.addTarget(self, action: #selector(MyGroupViewController.chatGroupAction(btn:)), for: .touchUpInside)
        cell.raugroup = raugroup
        cell.btn_chat.setTitle("进入群聊", for: .normal)
        return cell
        
        }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
   @objc func jiesan(btn:UIButton) {
    let raugroup = dataSource[btn.tag]
    let vc = UIAlertController(title: "解散群组", message: "您确定要解散该群组吗？", preferredStyle: .actionSheet)
    vc.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
        self.dissolutionGroup.value = true
    }))
    vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
    self.present(vc, animated: true, completion: nil)

    
    let activityIndicator = ActivityIndicator()
    
    let request = self.dissolutionGroup.asObservable().filter{$0 == true}
        .flatMap{_ in RequestProvider.request(api: ParametersAPI.dissolutionGroup(rgId: raugroup.id)).mapObject(type: EmptyModel.self)
            .trackActivity(activityIndicator)
        }
        .shareReplay(1)
    
    request.flatMap{$0.unwarp()}
        .subscribe {[unowned self] (_) in
            self.dissolutionGroup.value = false
            self.page = 1
//            self.dataSource.remove(at: btn.tag)
            self.reqeust.value = true
            self.tableView.reloadData()
            Drop.down("您已解散该群", state: .success)
        }
        .addDisposableTo(self.rx_disposeBag)
    
    request.flatMap{$0.error}.map{$0.domain}
    .subscribe(onNext: { (error) in
        self.dissolutionGroup.value = false
        Drop.down(error, state: .error)
    }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(self.rx_disposeBag)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
        
    @objc fileprivate func chatGroupAction(btn:UIButton){
        let model = dataSource[btn.tag]
        let conversationVC = RCDChatViewController()
        conversationVC.groupId = model.id;
        conversationVC.conversationType = .ConversationType_GROUP;
        conversationVC.targetId = "\(model.id)"
        conversationVC.title = model.name
        conversationVC.displayUserNameInCell = false
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }

}
class MyGroupContentViewController: UIViewController {
    let vc = MyGroupPageViewController()
    var currentPage:UInt = 0
    let titleSegment = YUSegment(titles: ["我创建的群","我加入的群"], style: .line)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的群组"
        do{
            view.backgroundColor = bgColor
            titleSegment.indicator.backgroundColor = UIColor.colorWithHexString("#ff8200")
            titleSegment.selectedTextColor = UIColor.colorWithHexString("#FF8200")
            titleSegment.textColor = UIColor.colorWithHexString("#666666")
            titleSegment.backgroundColor = UIColor.white
            titleSegment.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44)
            titleSegment.addTarget(self, action: #selector(titleSegmentValueChanged(segment:)), for: .valueChanged)
            self.view.addSubview(titleSegment)
        }
        do{
            self.view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: 54, width: view.bounds.size.width, height: view.bounds.size.height - 54)
            self.addChildViewController(vc)
        }
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "MyGroupChangeSelectedIndexNotifation"), object: nil)
                .subscribe(onNext: { (noti) in
                    let page = noti.userInfo!["selectedIndex"] as! Int
                    self.titleSegment.selectedIndex = UInt(page)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }

    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc fileprivate func titleSegmentValueChanged(segment:YUSegment){
        if currentPage != segment.selectedIndex{
            
        }
        vc.goTo(Int(segment.selectedIndex))
        
    }
}
class MyGroupPageViewController: PagesController,PagesControllerDelegate {
    var currentPage:UInt = 0

    override  init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        let vc1 = MyGroupViewController()
        let vc2 = MyGroupViewController()
        vc1.type.value = 1
        vc2.type.value = 2
        vc1.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc2.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        add([vc1,vc2])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            pagesDelegate = self
            showPageControl = false
            showBottomLine = false
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func pageViewController(_ pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int){
        currentPage = UInt(page)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MyGroupChangeSelectedIndexNotifation"), object: nil, userInfo: ["selectedIndex":page])
    }
    
}

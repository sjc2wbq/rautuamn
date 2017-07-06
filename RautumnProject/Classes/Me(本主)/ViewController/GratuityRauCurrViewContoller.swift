//
//  GratuityRauCurrViewContoller.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import Pages
import YUSegment
import ARSLineProgress
import ObjectMapper
import SwiftyDrop

struct GratuityRauCurrModel {
    var gratuityRauCurr: [Gratuityraucurr] = []
    
    init?( map: Map) {}
}

extension GratuityRauCurrModel: Mappable {
    mutating func mapping(map: Map) {
        gratuityRauCurr <- map["gratuityRauCurr"]
    }
}

// MARK: - Gratuityraucurr

struct Gratuityraucurr {
    var rauCurr = ""
    var date = ""
    var userId = 0
    var headPortUrl = ""
    var nickName = ""
    var recordId = 0
    
    init?(map: Map) {}
}

extension Gratuityraucurr: Mappable {
    mutating func mapping(map: Map) {
        rauCurr <- map["rauCurr"]
        date <- map["date"]
        userId <- map["userId"]
        headPortUrl <- map["headPortUrl"]
        nickName <- map["nickName"]
        recordId <- map["gratuityRauCurrRecordId"]
    }
}

extension Gratuityraucurr: IdentifiableType,Equatable {
    var identity: Int {
        return userId
    }
}
func ==(lhs: Gratuityraucurr, rhs: Gratuityraucurr) -> Bool {
    return lhs.userId == rhs.userId
}

class GratuityRauCurrViewModel: RefreshViewModel {
    //Friend
    typealias TableSectionModel = AnimatableSectionModel<String, Gratuityraucurr>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Gratuityraucurr]()
    override  init() {
        super.init()
    }
    convenience  init(input:(headerRefresh:Observable<Void>,footerRefresh:Observable<Void>,type:Observable<Int>)) {
        self.init()
        
        
        let headerResponse  = input.headerRefresh
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<GratuityRauCurrModel>>> in
            self.page.value = 1
            return RequestProvider.request(api: ParametersAPI.getGratuityRauCurr(type : type,pageIndex: self.page.value)).mapObject(type: GratuityRauCurrModel.self)
            }.shareReplay(1)
        
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { [unowned self] (model ) in
            self.items = model.gratuityRauCurr
            self.sections.value = [TableSectionModel(model: "", items:  self.items)]
            self.refreshState.value = .headerRefreshFinish
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            self.refreshState.value = .loadDataFailure
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        let footerResponse  =  input.footerRefresh
            .withLatestFrom(input.type)
            .flatMapLatest {[unowned self] (type) -> Observable<Result<ResponseInfo<GratuityRauCurrModel>>> in
                self.page.value += 1
                return RequestProvider.request(api: ParametersAPI.getGratuityRauCurr(type : type,pageIndex: self.page.value)).mapObject(type: GratuityRauCurrModel.self)
            }.shareReplay(1)
        
        
        footerResponse.flatMap{$0.unwarp()}.map{$0.result_data?.gratuityRauCurr}.unwrap().subscribe(onNext: { [unowned self] (friends ) in
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


class GratuityRauCurrViewContoller: UITableViewController {
    
    typealias TableSectionModel = AnimatableSectionModel<String, Gratuityraucurr>
    
    var type = Variable(1)
    var isDelete = Variable(false)
    var viewModel : GratuityRauCurrViewModel!
    var emptyDisplayCondition = false
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "暂无数据"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        
        do {
            tableView.backgroundColor = bgColor
            tableView.delegate = nil
            tableView.dataSource = nil
            tableView.backgroundColor = bgColor
            //   tableView.tableHeaderView = headerView
            tableView.tableFooterView = UIView()
            tableView.rx.setDelegate(self).addDisposableTo(rx_disposeBag)
            
            tableView.register(UINib(nibName: "GratuityRauCurrViewCell", bundle: nil), forCellReuseIdentifier: "GratuityRauCurrViewCell")
            tableView.st_header = STRefreshHeader()
            tableView.addFooterRefresh()
            self.tableView.mj_footer.isHidden = true
            
            viewModel = GratuityRauCurrViewModel(input:(headerRefresh:tableView.st_header.rx.refresh,footerRefresh:tableView.mj_footer.rx.refresh,type:type.asObservable()))
        }
        
        do {
            viewModel.refreshState.asObservable().subscribe(onNext: {[unowned self] (status) in
                switch status{
                case .loadDataFailure,.headerRefreshFinish:
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.resetNoMoreData()
                    self.tableView.mj_footer.endRefreshing()
                    self.emptyDisplayCondition = true
                case .noHasNextPage:
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                default:
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                }
                },  onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        }
        do {
            viewModel.dataSource.configureCell =  {(ds, tableView, indexPath, model) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "GratuityRauCurrViewCell", for: indexPath) as! GratuityRauCurrViewCell
                
                cell.deleteThisCell(closure: { 
                    self.deleteGratuity(indexPath: indexPath)
                })
                
                cell.model = model
                return cell
            }
            viewModel.sections.asObservable()
                .bindTo(tableView.rx.items(dataSource: viewModel.dataSource)).addDisposableTo(rx_disposeBag)

        }
        
    }
    
    // delete
    func deleteGratuity(indexPath: IndexPath) {
        
       
        let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.row]

        
        let activityIndicator = ActivityIndicator()
        
        let vc = UIAlertController(title: "删除打赏", message: "您确定要删除这条打赏吗？", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (_) in
            self.isDelete.value = true
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
        
        let  request =  isDelete.asObservable().filter{$0 == true}
            .do(onNext: { (_) in
                ARSLineProgress.ars_showOnView(self.view)
            })
            .flatMap{_ in
                RequestProvider.request(api: ParametersAPI.deleteGratuityRau(recordId: model.recordId))
                    .mapObject(type: Gratuityraucurr.self)
                    .trackActivity(activityIndicator)
            }
            .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                self.isDelete.value =  false
                ARSLineProgress.hide()
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}
            .subscribe(onNext: { (_) in
                ARSLineProgress.hide()
                
                if self.isDelete.value == true {
                    print("section = \(indexPath.section), row = \(indexPath.row)")
                    self.viewModel.items.remove(at: indexPath.row)
                    self.viewModel.sections.value = [TableSectionModel(model: "", items: self.viewModel.items)]
                }
            
                self.isDelete.value =  false
                Drop.down("删除成功！", state: .success)

            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableView.mj_footer.isHidden = self.viewModel.dataSource.sectionModels[indexPath.section].items.count < 10
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        let model = self.viewModel.dataSource.sectionModels[indexPath.section].items[indexPath.row]
        let vc = UserInfoViewController()
        vc.visitorUserId = model.userId
//        vc.title = model.nickName
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
}


class GratuityRauCurrContentViewContoller: UIViewController {

    let vc = GratuityRauCurrPageViewContoller()
    var currentPage:UInt = 0
    let titleSegment = YUSegment(titles: ["打赏我的","我打赏的"], style: .line)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "打赏全记录"
    
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
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "GratuityRauCurrChangeSelectedIndexNotifation"), object: nil)
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

class GratuityRauCurrPageViewContoller: PagesController,PagesControllerDelegate {
    var currentPage:UInt = 0
    
    let vc1 = GratuityRauCurrViewContoller()
    let vc2 = GratuityRauCurrViewContoller()
    
    override  init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
        // 2.确定所有的子控制器
//        let vc1 = GratuityRauCurrViewContoller()
        vc1.type.value = 1
//        let vc2 = GratuityRauCurrViewContoller()
        vc2.type.value = 2
        vc1.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc2.view.frame = CGRect(x: 0, y: 54, width: vc1.view.bounds.size.width, height: vc1.view.bounds.size.height - 54)
        vc1.type.value = 1
        vc2.type.value = 2
        add([vc1,vc2])
//        add([vc1])
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
        
        vc1.tableView.setEditing(false, animated: true)
        vc2.tableView.setEditing(false, animated: true)
        currentPage = UInt(page)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GratuityRauCurrChangeSelectedIndexNotifation"), object: nil, userInfo: ["selectedIndex":page])
    }

}


//
//  MyVideoViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import RxSwift
import ARSLineProgress
import SwiftyDrop
class MyVideoViewController: UITableViewController {
    fileprivate var currentIndexPath : IndexPath?
    var isDelete = Variable(false)
    var dataSource = [MyRSV]()
    var page = 1
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的视频"
        initTableView()

        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "您还没有发布过视频！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        
         NotificationCenter.default.rx.notification(Notification.Name(rawValue: "PublishRSVSucccessNotifation"))
        .subscribe(onNext: {[] (noti) in
            let rsv = noti.userInfo?["rsv"] as! MyRSV
            self.dataSource.insert(rsv, at: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            self.tableView.endUpdates()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension MyVideoViewController{
    func initTableView()  {
        tableView.backgroundColor = bgColor
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "MyVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "MyVideoTableViewCell")

        do{
        navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "findFrinedPlus")
            navigationItem.rightBarButtonItem!.rx.tap
                .subscribe(onNext: {[unowned self] (_) in
                    if UserModel.shared.rank.value == "U"{
                        let vc = UIAlertController(title: "温馨提示", message: "开通注册会员后，才能发布RSV视频，是否去开通？", preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                        vc.addAction(UIAlertAction(title: "去开通", style: .default, handler: {[unowned self] _ in
                            if UserModel.shared.inApp{
                                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppOpeningMemberTableViewController") as! InAppOpeningMemberTableViewController
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            }else{
                                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "OpeningMemberTableViewController") as! OpeningMemberTableViewController
                                vc.type = 2
                                self.navigationController?.pushViewController(vc, animated: true)
                                
                            }
                            
                        }))
                        self.present(vc, animated: true, completion: nil)
                        return
                    }

            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "UploadRSVViewController")
            self.navigationController?.pushViewController(vc, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
            self.page = 1
            self.fetchData()
        })
    
        tableView.mj_footer = footer { [unowned self] in
            self.page += 1
            self.fetchData()
        }
        tableView.st_header.beginRefreshing()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyVideoTableViewCell") as! MyVideoTableViewCell
        cell.rsv = dataSource[indexPath.row]
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        cell.img_paly.addGestureRecognizer(tap)
        cell.btn_delete.tag = indexPath.row
        cell.btn_delete.addTarget(self, action: #selector(deleteVideoAvtion(btn:)), for: .touchUpInside)
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dataSource[indexPath.row]
        return 304 + model.title.height(16, wight: screenW - 16)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rsv = dataSource[indexPath.row]
        let vc = MyVideoDetailViewController()
            vc.rsv = rsv
            navigationController?.pushViewController(vc, animated: true)
    }
    func deleteVideoAvtion(btn:UIButton){
        let cell = tableView.cellForRow(at: IndexPath(row: btn.tag, section: 0))
        let rsv = dataSource[btn.tag]
        let activityIndicator = ActivityIndicator()
        
        let vc = UIAlertController(title: "删除视频", message: "您确定要删除视频吗？", preferredStyle: .actionSheet)
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
                RequestProvider.request(api: ParametersAPI.deleteMyRSV(rsvIds:"\(rsv.id)")).mapObject(type: EmptyModel.self)
                    .trackActivity(activityIndicator)
            }
            .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                self.isDelete.value =  false
                ARSLineProgress.hide()
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(cell!.rx_reusableDisposeBag)
        
        request.flatMap{$0.unwarp()}
            .subscribe(onNext: { (_) in
                ARSLineProgress.hide()
                self.isDelete.value =  false
                Drop.down("删除成功！", state: .success)
                self.dataSource.remove(at: btn.tag)
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(cell!.rx_reusableDisposeBag)
        

        
        
    }
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        let view = tap.view
        let rsv = dataSource[view!.tag]
        
//        currentIndexPath = IndexPath(row: view!.tag, section: 0)
//        guard let currentIndexPath = currentIndexPath else{
//            return
//        }
//        
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:rsv.videoUrl.replacingOccurrences(of: "%2F", with: "/"))
        self.present(vc, animated: true, completion: nil)
        
        let request = RequestProvider.request(api: ParametersAPI.rsvPlayTimes(rsvId: "\(rsv.id)"))
            .mapObject(type: EmptyModel.self)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            rsv.playTimes.value = rsv.playTimes.value + 1
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.subscribe(onNext: { (_) in
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        
    }
}
extension MyVideoViewController{
    fileprivate func fetchData(){
       let request = RequestProvider.request(api: ParametersAPI.myRSV(pageIndex: page)).mapObject(type: MyRSVModel.self)
        .shareReplay(1)
        request.flatMap{$0.unwarp()}
            .map{$0.result_data?.rauVideoUsefuls}
        .unwrap()
        .subscribe(onNext: {[unowned self ] (rsvs) in
            if self.page == 1{
                self.dataSource = rsvs
                self.tableView.st_header.endRefreshing()
                self.emptyDisplayCondition = true
            }else{
                if rsvs.count == 0 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    self.dataSource += rsvs
                    self.tableView.mj_footer.endRefreshing()
                }
            }
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
    
        
        request.flatMap{$0.error}
            .map{$0.domain}
            .subscribe(onNext: { (error) in
              Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
}

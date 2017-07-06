
//
//  MyArticleViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/16.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import  MJRefresh
import SimpleAlert
import ARSLineProgress
import RxSwift
import SwiftyDrop
import AVFoundation
class MyArticleViewController: UITableViewController {
    var currentId = -1
    var refreshHeader:SDTimeLineRefreshHeader?
    fileprivate var alert:AlertController?
    let exceptionalView = ExceptionalView.exceptionalView()
    var isDelete = Variable(false)
    fileprivate var currentIndexPath : IndexPath?
    public var pageIndex = 1
    public var dataSource = [MyArticleFrame]()
    var emptyDisplayCondition = false
    
    var audioPlayer = HKPlayerAudio()
    var audioPlayer1 = HKPlayer.instance
    var currentButton:UIButton?
    
    var currentPlayIndex = -1
    var isEndPlay  = false
    var isDisplay = true
    
    var lastPlayCell: MyArticleViewCell?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer.endPlay()
        audioPlayer1.pausePlay()
        self.currentPlayIndex = -1
        currentButton?.isSelected = false
        tableView.reloadData()
        self.lastPlayCell = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的发布"
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "您还没有发布过文章！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = bgColor
        

        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "publishRFCSuccessNotifation"))
                .subscribe(onNext: {[unowned self] (noti) in
                    let model = noti.object as! RautumnFriendsCircle
                    let frame = MyArticleFrame()
                    frame.rautumnFriendsCircle = model
                    self.dataSource.insert(frame, at: 0)
                    self.tableView.reloadData()
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
        
        do{
            exceptionalView.exceptionalGoldHander = { [unowned self] in
                self.alert?.dismiss(animated: true, completion: { [unowned self] in
                    //国际化
                    let avc = UIAlertController(title: "温馨提示", message: "您的镭秋币不足，无法打赏，是否去充值？", preferredStyle: .alert)
                    
                    avc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                        
                    }))
                    avc.addAction(UIAlertAction(title: "去充值", style: .default, handler: {[unowned self] (_) in
                        if UserModel.shared.inApp{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        
                        }
    
                    }))
                    
                    self.present(avc, animated: true, completion: nil)
                })
            }
            exceptionalView.btn_topUp.rx.tap
                .map{_ in self.alert}
                .subscribe(onNext: { (alert) in
                    alert?.dismiss(animated: true, completion: { [unowned self] in
                        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                }, onError: nil, onCompleted: nil, onDisposed: nil )
                .addDisposableTo(rx_disposeBag)
        }
        
        
        do{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "edit")
            self.navigationItem.rightBarButtonItem!.rx.tap
                .subscribe(onNext: {[unowned self] (noti) in
                    let vc = UIStoryboard(name: "PostDynamic", bundle: nil).instantiateInitialViewController()
                    self.present(vc!, animated: true, completion: nil)
                })
                .addDisposableTo(rx_disposeBag)
        }
        do{
            automaticallyAdjustsScrollViewInsets = false
            alert = AlertController(view: exceptionalView, style: .actionSheet)
        }
        tableView.register(UINib(nibName: "MyArticleViewCell", bundle: nil), forCellReuseIdentifier: "MyArticleViewCell")
        tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
            self.pageIndex = 1
            self.fetchData()
        })
        
        tableView.mj_footer = footer {[unowned self] in
            self.pageIndex += 1
            self.fetchData()
        }
        tableView.st_header.beginRefreshing()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        refreshHeader?.removeFromSuperview()
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyArticleViewCell") as! MyArticleViewCell
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.vedioContainerView.tag = indexPath.row
        cell.btn_delete.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        cell.vedioContainerView.addGestureRecognizer(tap)
        cell.moreButtonClickedBlock = {indexPath in
            if let indexPath = indexPath{
                let rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
                rautumnFriendsCircle!.isOpening.value = !rautumnFriendsCircle!.isOpening.value
//                tableView.reloadRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                rautumnFriendsCircleFrame.rautumnFriendsCircle = rautumnFriendsCircle
            }
        }
        
        // 播放音频
        weak var weakSelf = self
        
        cell.audioBttonClickedBlock = {[unowned self] (sender,timeLabel,index) in
            
            sender.isSelected = !sender.isSelected
            
            self.currentButton = sender
            
            let url = (rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url})!
           let audioTime = rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length}
    
            
            weakSelf?.audioPlayer.endPlay()
            weakSelf?.audioPlayer1.stopPlay()
            timeLabel.text = "\(audioTime!)'"
            
            if sender.isSelected {
                
                
                weakSelf?.isDisplay = true
                self.isEndPlay = false
                
                if  weakSelf?.lastPlayCell != nil {
   
                    weakSelf?.lastPlayCell?.audioButton.isSelected = false
                    weakSelf?.lastPlayCell?.audioTimeLabel.text = "\((self.dataSource[(weakSelf?.lastPlayCell?.indexPath?.row)!].rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length})!)'"
                   
                }
                
                weakSelf?.currentPlayIndex = indexPath.row
                weakSelf?.lastPlayCell = cell
                
                if (url.hasSuffix(".aac")) {
                    
                    weakSelf?.audioPlayer1.playMusic(urlString: url)
                    weakSelf?.audioPlayer1.playScale = {(currentTime) in
                        
                        print("ssafafafa")
                        if !(weakSelf?.isEndPlay)! && (weakSelf?.isDisplay)! {
                            timeLabel.text = "\(currentTime)'"
                        }
                    }
                    weakSelf?.audioPlayer1.playEnd = {_ in
                        weakSelf?.currentPlayIndex = -1
                        timeLabel.text = "\(audioTime!)'"
                        sender.isSelected = false
                    }
    
                } else {
                    
                    weakSelf?.audioPlayer1.stopPlay()
                    weakSelf?.audioPlayer.startPlay(withUrlString: url, updateMeters: { (time) in
                        
                        
                        if !(weakSelf?.isEndPlay)! && (weakSelf?.isDisplay)! {
                            timeLabel.text = "\(time)'"
                        }
                    }, success: {
                        weakSelf?.currentPlayIndex = -1
                        sender.isSelected = false
                        
                        timeLabel.text = "\(audioTime!)'"
                    }, failed: { (error) in
                        weakSelf?.currentPlayIndex = -1
                        print("playError = \(error)")
                        timeLabel.text = "\(audioTime!)'"
                    })
                }
                
            } else {
                 timeLabel.text = "\(audioTime!)'"
                weakSelf?.currentPlayIndex = -1
                weakSelf?.lastPlayCell = nil
                weakSelf?.isEndPlay = true
                weakSelf?.isDisplay = false
                weakSelf?.audioPlayer.endPlay()
                weakSelf?.audioPlayer1.stopPlay()
            }

        }
        
        if self.currentPlayIndex != indexPath.row {
            cell.audioButton.isSelected = false
        } else {
            cell.audioButton.isSelected = true
        }
        
        cell.rautumnFriendsCircleFrame = rautumnFriendsCircleFrame
        
        do{ //删除我的文章
            cell.btn_delete.addTarget(self, action: #selector(deleteWZAction(btn:)), for: .touchUpInside)
        }

        return cell
    }
   @objc func deleteWZAction(btn:UIButton) {
    let cell = tableView.cellForRow(at: IndexPath(row: btn.tag, section: 0))
    let rautumnFriendsCircleFrame = dataSource[btn.tag]
//    let activityIndicator = ActivityIndicator()
//    activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(cell!.rx_reusableDisposeBag)
    
    let vc = UIAlertController(title: "删除文章", message: "您确定要删除该文章吗？", preferredStyle: .actionSheet)
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
            RequestProvider.request(api: ParametersAPI.deleteArticle(rfcId:rautumnFriendsCircleFrame.rautumnFriendsCircle.id)).mapObject(type: EmptyModel.self)
//                .trackActivity(activityIndicator)
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
//            self.tableView.deleteRows(at: [IndexPath(row: btn.tag, section: 0)], with: .none)
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(cell!.rx_reusableDisposeBag)

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPlayIndex == indexPath.row {
            isDisplay = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPlayIndex == indexPath.row {
            isDisplay = false
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
        return rautumnFriendsCircleFrame.cellHeight
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
        let vc = MyArticleDetailViewController()
        switch rautumnFriendsCircleFrame.rautumnFriendsCircle.type {
        case 0:
            vc.title = "文章详情"
        case 1:
            vc.title = "图文详情"
        case 2:
            vc.title = "视频详情"
        default:
            vc.title = "音频详情"
        }
        vc.rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
//        player?.destroy()
        let view = tap.view
        let rautumnFriendsCircleFrame = dataSource[view!.tag]
        
        currentIndexPath = IndexPath(row: view!.tag, section: 0)
        guard let currentIndexPath = currentIndexPath else{
            return
        }
        let cell = tableView.cellForRow(at: currentIndexPath) as! MyArticleViewCell
        
        let vc = PlayVideoViewController()
        vc.placeholderImage = cell.vedioContainerView.image
        vc.videoUrl = URL(string:rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url}!)
        self.present(vc, animated: true, completion: nil)

    }

//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        self.audioPlayer.endPlay()
//        self.audioPlayer1.pausePlay()
//        self.currentButton?.isSelected = false
//    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.audioPlayer.endPlay()
//        self.currentButton?.isSelected = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "btn_plusIsHiddenNotifation"), object: true)
        
    }
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "btn_plusIsHiddenNotifation"), object: false)
        
    }
    
}
extension MyArticleViewController : MyArticleViewCellDelegate{

    func huluClickedOperationWithCell(cell:MyArticleViewCell){
        
        dataSource.forEach { (frame) in
            let rautumnFriendsCircle = frame.rautumnFriendsCircle
            rautumnFriendsCircle?.isShowMenu.value = false
        }
        let indexPath = tableView.indexPath(for: cell)
        let rautumnFriendsCircleFrame = dataSource[indexPath!.row]
        let rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        
        if currentId == rautumnFriendsCircle!.id {
            rautumnFriendsCircle?.isShowMenu.value = false
            self.currentId = -1
        }else{
            rautumnFriendsCircle?.isShowMenu.value = true
            self.currentId = rautumnFriendsCircle!.id
        }
    }
    func zanButtonClickedOperationWithCell(cell:MyArticleViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let rautumnFriendsCircleFrame = dataSource[indexPath!.row]
        UserModel.shared.rautumnCurrency.asObservable().map{"您可用的镭秋币：\($0) 个"}.bindTo(exceptionalView.lb_gold.rx.text).addDisposableTo(rx_disposeBag)

        exceptionalView.rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        exceptionalView.objId = rautumnFriendsCircleFrame.rautumnFriendsCircle.id
        present(alert!, animated: true, completion: nil)
    }
    func commentButtonClickedOperationWithCell(cell:MyArticleViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let rautumnFriendsCircleFrame = dataSource[indexPath!.row]
        let vc1 = RadiumFriendsCircleDetailViewController()
        switch rautumnFriendsCircleFrame.rautumnFriendsCircle.type {
        case 0:
            vc1.title = "文章详情"
        case 1:
            vc1.title = "图文详情"
        default:
            vc1.title = "视频详情"
        }
        vc1.rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        navigationController?.pushViewController(vc1, animated: false)
        
        let vc = CommentViewController()
        vc.objId = "\(rautumnFriendsCircleFrame.rautumnFriendsCircle.id)"
        vc.type = rautumnFriendsCircleFrame.rautumnFriendsCircle.type
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dataSource.forEach { (frame) in
            let rautumnFriendsCircle = frame.rautumnFriendsCircle
            rautumnFriendsCircle?.isShowMenu.value = false
        }
    }
    
}
extension MyArticleViewController{
    fileprivate func fetchData(){
        self.tableView.reloadDataWithInsertingData(atTheBeginingOfSection: 0, newDataCount: self.dataSource.count)
        let request =   RequestProvider.request(api: ParametersAPI.getMyRautumnFriendsCircleList(pageIndex: pageIndex)).mapObject(type: CircleDynamicListModel.self)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
                var frames = [MyArticleFrame]()
                model.rautumnFriendsCircleList.forEach({ (rautumnFriendsCircle) in
                    let modelFrame = MyArticleFrame()
                    modelFrame.rautumnFriendsCircle = rautumnFriendsCircle
                    frames.append(modelFrame)
                })
                if self.pageIndex == 1{
                    self.dataSource = frames
                    self.tableView.st_header.endRefreshing()
                    self.tableView.mj_footer.isHidden = self.dataSource.count < 10
                    self.emptyDisplayCondition = true
                    
                }else{
                    if model.rautumnFriendsCircleList.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.dataSource.append(contentsOf: frames)
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()
                }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error)
            }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
}

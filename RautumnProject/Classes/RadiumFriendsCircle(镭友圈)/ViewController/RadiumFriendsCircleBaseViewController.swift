//
//  RadiumFriendsCircleBaseViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import RxSwift
import  MJRefresh
import SwiftyDrop
import ObjectMapper
import SimpleAlert
import AVFoundation
class RadiumFriendsCircleBaseViewController: UITableViewController {
    var currentId = -1
    var refreshHeader:SDTimeLineRefreshHeader?
    fileprivate var alert:AlertController?
  let exceptionalView = ExceptionalView.exceptionalView()

    fileprivate var currentIndexPath : IndexPath?
    var fecthData:(() -> ())?
    public var pageIndex = 1
    public var dataSource = [RautumnFriendsCircleFrame]()
    
    var audioPlayer = HKPlayerAudio()
    var audioPlayer1 = HKPlayer.instance
    var currentButton:UIButton?
    
    var currentPlayIndex = -1
    var lastPlayCell: RadiumFriendsCircleViewCell?
    
    var isFriendHistory = false
    
    var isEndPlay  = false
    var isDisplay = true
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioPlayer.endPlay()
        self.audioPlayer1.stopPlay()
        self.currentPlayIndex = -1
        currentButton?.isSelected = false
        tableView.reloadData()
        self.lastPlayCell = nil
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        if UserModel.shared.inApp{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }                    })
                }, onError: nil, onCompleted: nil, onDisposed: nil )
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
                        if UserModel.shared.inApp{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppRechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }                        })
                    }, onError: nil, onCompleted: nil, onDisposed: nil )
            .addDisposableTo(rx_disposeBag)
        }
        do {
//
           Observable.of(NotificationCenter.default.rx.notification(Notification.Name(rawValue: "LaHeiUserSuccessNotifation")),NotificationCenter.default.rx.notification(Notification.Name(rawValue: "DeleteUserSuccessNotifation")))
            .merge()
            .subscribe(onNext: {[unowned self] (_) in
                  self.tableView.st_header.beginRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        do{
            tableView.separatorStyle = .none
            self.automaticallyAdjustsScrollViewInsets = false
           alert = AlertController(view: exceptionalView, style: .actionSheet)
        }
       tableView.backgroundColor = bgColor
        tableView.register(UINib(nibName: "RadiumFriendsCircleViewCell", bundle: nil), forCellReuseIdentifier: "RadiumFriendsCircleViewCell")
        
        self.tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
            self.pageIndex = 1
            self.tableView.mj_footer.resetNoMoreData()
            self.fecthData?()
        })
        
        self.tableView.mj_footer = footer {[unowned self] in
            self.pageIndex += 1
            self.fecthData?()
        }
 
        do{
          NotificationCenter.default.rx.notification(Notification.Name(rawValue: "publishRFCSuccessNotifation"))
            .subscribe(onNext: {[unowned self] (noti) in
               
                let model = noti.object as! RautumnFriendsCircle
                log.info("sdfajgjagja = \(model.coverUrl.value)")
                let frame = RautumnFriendsCircleFrame()
                frame.rautumnFriendsCircle = model
                self.dataSource.insert(frame, at: 0)
                self.tableView.reloadData()

            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadiumFriendsCircleViewCell") as! RadiumFriendsCircleViewCell
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.vedioContainerView.tag = indexPath.row
        cell.img_icon.tag = indexPath.row
        if isFriendHistory {
            cell.btn_lei.isHidden = true
        } else {
            cell.btn_lei.isHidden = false

        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        cell.vedioContainerView.addGestureRecognizer(tap)

        weak var weakSelf = self
        cell.audionButtonClickedClosure = { (sender,timeLabel,index) in
        
        
            weakSelf?.currentButton = sender
            sender.isSelected = !sender.isSelected
            
            let url = rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url}
            let audioTime = rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length}
            
//            weakSelf?.audioPlayer1.stopPlay()
//            weakSelf?.audioPlayer.endPlay()
            timeLabel.text = "\(audioTime!)'"
            
            if sender.isSelected {
                weakSelf?.isDisplay = true
                self.isEndPlay = false
                
                if   weakSelf?.lastPlayCell != nil {
                    //
                    weakSelf?.lastPlayCell?.audioButton.isSelected = false
                    weakSelf?.lastPlayCell?.audioTimeLabel.text = "\((weakSelf?.dataSource[(weakSelf?.lastPlayCell?.indexPath?.row)!].rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length})!)'"
                    
                }
                
                weakSelf?.currentPlayIndex = (index?.row)!
                weakSelf?.lastPlayCell = cell
                
                if (url?.hasSuffix(".aac"))! {
                    
                    weakSelf?.audioPlayer.endPlay()
                    weakSelf?.audioPlayer1.playMusic(urlString: url)
                    weakSelf?.audioPlayer1.playScale = {(currentTime) in
                       
                        print("aaaaaaaaaa = \(index?.row)--- ainaahfas = \(indexPath.row)")
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
                    weakSelf?.audioPlayer.startPlay(withUrlString: url!, updateMeters: { (time) in
                        if !(weakSelf?.isEndPlay)! && (weakSelf?.isDisplay)! {
                            timeLabel.text = "\(time)'"
                        }
                        
                    }, success: {
                        sender.isSelected = false
                        timeLabel.text = "\(audioTime!)'"
                        weakSelf?.currentPlayIndex = -1
                    }, failed: { (error) in
                        print("playError = \(error)")
                        sender.isSelected = false
                        timeLabel.text = "\(audioTime!)'"
                        weakSelf?.currentPlayIndex = -1
                    })
                }
                
            } else {
               
                weakSelf?.lastPlayCell = nil
                weakSelf?.currentPlayIndex = -1
                weakSelf?.audioPlayer.endPlay()
                weakSelf?.audioPlayer1.stopPlay()
                weakSelf?.isEndPlay = true
                weakSelf?.isDisplay = false
                 timeLabel.text = "\(audioTime!)'"
            }
            
        }
        
        cell.moreButtonClickedBlock = {_ in

            
            let rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
            rautumnFriendsCircle!.isOpening.value = !rautumnFriendsCircle!.isOpening.value
            tableView.reloadData()
            
            rautumnFriendsCircleFrame.rautumnFriendsCircle = rautumnFriendsCircle
        }
        
      
        if self.currentPlayIndex != indexPath.row {
            cell.audioButton.isSelected = false
        } else {
            cell.audioButton.isSelected = true
        }
        
        cell.rautumnFriendsCircleFrame = rautumnFriendsCircleFrame
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.mj_footer.isHidden = dataSource.count < 10
        return dataSource.count
    }
    

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
    return rautumnFriendsCircleFrame.cellHeight
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rautumnFriendsCircleFrame = dataSource[indexPath.row]
            let vc = RadiumFriendsCircleDetailViewController()
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
        let view = tap.view
        let rautumnFriendsCircleFrame = dataSource[view!.tag]
        
        currentIndexPath = IndexPath(row: view!.tag, section: 0)
        guard let currentIndexPath = currentIndexPath else{
            return
        }
        let cell = tableView.cellForRow(at: currentIndexPath) as! RadiumFriendsCircleViewCell
        
        let vc = PlayVideoViewController()
        vc.placeholderImage = cell.vedioContainerView.image
        vc.videoUrl = URL(string:(rautumnFriendsCircleFrame.rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url.replacingOccurrences(of: "%2F", with: "/")})!)
        self.present(vc, animated: true, completion: nil)

    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.currentPlayIndex == indexPath.row {
            print("----------------------------")
            self.isDisplay = false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.currentPlayIndex == indexPath.row {
            print("++++++++++++++++++++++++++")
            self.isDisplay = true
        }

    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "btn_plusIsHiddenNotifation"), object: false)

    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "btn_plusIsHiddenNotifation"), object: false)

    }
  
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "btn_plusIsHiddenNotifation"), object: true)

        dataSource.forEach { (frame) in
            let rautumnFriendsCircle = frame.rautumnFriendsCircle
            rautumnFriendsCircle?.isShowMenu.value = false
        }
    }
}
extension RadiumFriendsCircleBaseViewController : RadiumFriendsCircleViewCellDelegate{
    
    
    func complaintsClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell) {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "ComplaintViewController") as! ComplaintViewController
        print("appelleeUserInfoId = \(cell.rautumnFriendsCircleFrame.rautumnFriendsCircle.userId)")
        vc.appelleeUserInfoId = cell.rautumnFriendsCircleFrame.rautumnFriendsCircle.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func huluClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell){

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
    func zanButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let rautumnFriendsCircleFrame = dataSource[indexPath!.row]
        if rautumnFriendsCircleFrame.rautumnFriendsCircle.userId == UserModel.shared.id {
            Drop.down("自己不能打赏自己！", state: .info)
            return
        }
        if rautumnFriendsCircleFrame.rautumnFriendsCircle.rank == "U" {
            Drop.down("该用户是注册用户，不能接受打赏！", state: .info)
            return
        }
   
        UserModel.shared.rautumnCurrency.asObservable().map{"您可用的镭秋币：\($0) 个"}.bindTo(exceptionalView.lb_gold.rx.text).addDisposableTo(rx_disposeBag)
        exceptionalView.rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        exceptionalView.objId = rautumnFriendsCircleFrame.rautumnFriendsCircle.id
        present(alert!, animated: true, completion: nil)
    }
    func commentButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let rautumnFriendsCircleFrame = dataSource[indexPath!.row]
        let vc1 = RadiumFriendsCircleDetailViewController()
        switch rautumnFriendsCircleFrame.rautumnFriendsCircle.type {
        case 0:
            vc1.title = "文章详情"
        case 1:
            vc1.title = "图文详情"
        case 2:
            vc1.title = "视频详情"
        default:
            vc1.title = "音频详情"
        }
        vc1.rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle
        navigationController?.pushViewController(vc1, animated: false)
        let vc = CommentViewController()
        vc.objId = "\(rautumnFriendsCircleFrame.rautumnFriendsCircle.id)"
        vc.type = rautumnFriendsCircleFrame.rautumnFriendsCircle.type
        present(UINavigationController(rootViewController:vc), animated: true, completion: nil)
    }

   func leitaButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell){
    let indexPath = tableView.indexPath(for: cell)
    pushUserinfoVC(index: indexPath!.row)
    }
   @objc fileprivate func showUserInfoVC(tap:UITapGestureRecognizer) {
        let view = tap.view
        currentIndexPath = IndexPath(row: view!.tag, section: 0)
        guard let currentIndexPath = currentIndexPath else{
            return
        }
        pushUserinfoVC(index: currentIndexPath.row)
    }
   fileprivate func pushUserinfoVC(index:Int)  {
        let rautumnFriendsCircleFrame = dataSource[index]
    if UserModel.shared.id == rautumnFriendsCircleFrame.rautumnFriendsCircle.userId{
        Drop.down(rautumnFriendsCircleFrame.rautumnFriendsCircle.friend == true ?  "自己不能给自己发消息！" : "自己不能镭自己！", state: .info)
        return
    }
   if  rautumnFriendsCircleFrame.rautumnFriendsCircle.friend {
        let conversationVC = RCDChatViewController()
        conversationVC.conversationType = .ConversationType_PRIVATE;
        conversationVC.targetId = "\(rautumnFriendsCircleFrame.rautumnFriendsCircle.userId)"
        conversationVC.title = rautumnFriendsCircleFrame.rautumnFriendsCircle.nickName
        conversationVC.displayUserNameInCell = false
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }else{
        let vc = UserInfoViewController()
        vc.visitorUserId = rautumnFriendsCircleFrame.rautumnFriendsCircle.userId
//        vc.title = rautumnFriendsCircleFrame.rautumnFriendsCircle.nickName
        navigationController?.pushViewController(vc, animated: true)
    }
}
}

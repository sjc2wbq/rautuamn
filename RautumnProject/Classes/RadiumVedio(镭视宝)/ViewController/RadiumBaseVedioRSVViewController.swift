
//
//  RadiumBaseVedioRSVViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
import SimpleAlert
import AVFoundation
import UIKit
import SwiftyDrop
class RadiumBaseVedioRSVViewController: UITableViewController {
    let exceptionalView = ExceptionalView.exceptionalView()
var currentId = -1
    var page = 1
    fileprivate var alert:AlertController?
    
    fileprivate var currentIndexPath : IndexPath?
    var emptyDisplayCondition = false
    var fecthData:(() -> ())?
    var dataSource = [RvUsefulFrame]()
    override func viewDidLoad() {
        
        
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "暂无RSV视频"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
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
        
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
        alert = AlertController(view: exceptionalView, style: .actionSheet)
        initTableView()
    }
}
extension RadiumBaseVedioRSVViewController{
    fileprivate func initTableView(){

        tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
            self.page = 1
            self.fecthData?()
        })
        
        self.tableView.mj_footer = footer {[unowned self] in
            self.page += 1
            self.fecthData?()
        }
     
        tableView.st_header.beginRefreshing()

        tableView.register(UINib(nibName: "RadiumVedioRSVViewCell", bundle: nil), forCellReuseIdentifier: "RadiumVedioRSVViewCell")
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadiumVedioRSVViewCell") as! RadiumVedioRSVViewCell
        cell.delegate = self
        let frame = dataSource[indexPath.row]
            cell.rvUsefulFrame = frame
        cell.img_vedio.tag = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        cell.img_vedio.addGestureRecognizer(tap)
            return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rvUsefulFrame = dataSource[indexPath.row]
        return rvUsefulFrame.cellHeight
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RadiumVedioRSVDetailViewController()
        vc.rvUseful = dataSource[indexPath.row].rvUseful
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        let view = tap.view
        let frame = dataSource[view!.tag]
        currentIndexPath = IndexPath(row: view!.tag, section: 0)
        guard let currentIndexPath = currentIndexPath else{
            return
        }
        let cell = tableView.cellForRow(at: currentIndexPath) as! RadiumVedioRSVViewCell
        
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:frame.rvUseful.videoUrl)
        self.present(vc, animated: true, completion: nil)
        
       let request = RequestProvider.request(api: ParametersAPI.rsvPlayTimes(rsvId: "\(frame.rvUseful.id)"))
        .mapObject(type: EmptyModel.self)
        .shareReplay(1)
        request.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            frame.rvUseful.playTimes.value = frame.rvUseful.playTimes.value + 1
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.subscribe(onNext: { (_) in
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dataSource.forEach { (frame) in
            let rvUseful = frame.rvUseful
            rvUseful?.isShowMenu.value = false
        }
    }
    
    
}
extension RadiumBaseVedioRSVViewController : RadiumVedioRSVViewCellDelegate{
    func zanButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let frame = dataSource[indexPath!.row]
        if frame.rvUseful.userId == UserModel.shared.id {
            Drop.down("自己不能打赏自己！", state: .info)
            return
        }
        if frame.rvUseful.rank == "U" {
            Drop.down("该用户是注册用户，不能接受打赏！", state: .info)

            return
        }
        exceptionalView.rvUseful = frame.rvUseful
        exceptionalView.objId = frame.rvUseful.id
        exceptionalView.type = 2
        UserModel.shared.rautumnCurrency.asObservable().map{"您可用的镭秋币：\($0) 个"}.bindTo(exceptionalView.lb_gold.rx.text).addDisposableTo(rx_disposeBag)

        present(alert!, animated: true, completion: nil)

    }
    func commentButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell){
        let frame = dataSource[view!.tag]
        let vc = CommentViewController()
        vc.type = 2
        vc.commentType = 2
        vc.objId = "\(frame.rvUseful.id)"
        present(UINavigationController(rootViewController:vc), animated: true, completion: { [unowned self] in
            let vc = RadiumVedioRSVDetailViewController()
            vc.rvUseful = frame.rvUseful
            self.navigationController?.pushViewController(vc, animated: true)
        })

    }
    func leitaButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell){
        let indexPath = tableView.indexPath(for: cell)
        let frame = dataSource[indexPath!.row]
        if UserModel.shared.id == frame.rvUseful.userId{
            Drop.down(frame.rvUseful.friend == true ?  "自己不能给自己发消息！" : "自己不能镭自己！", state: .info)
            return
        }
        if  frame.rvUseful.friend {
            let conversationVC = RCDChatViewController()
            conversationVC.conversationType = .ConversationType_PRIVATE;
            conversationVC.targetId = "\(frame.rvUseful.userId)"
            conversationVC.title = frame.rvUseful.nickName
            conversationVC.displayUserNameInCell = false
            self.navigationController?.pushViewController(conversationVC, animated: true)
        }else{
            let vc = UserInfoViewController()
            vc.visitorUserId = frame.rvUseful.userId
//            vc.title = frame.rvUseful.nickName
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func huluClickedOperationWithCell(cell:RadiumVedioRSVViewCell){
        dataSource.forEach { (frame) in
            let rvUseful = frame.rvUseful
            rvUseful?.isShowMenu.value = false
        }
        let indexPath = tableView.indexPath(for: cell)
        let frame = dataSource[indexPath!.row]
        let rvUseful = frame.rvUseful
        if currentId == rvUseful!.id {
            rvUseful?.isShowMenu.value = false
            self.currentId = -1
        }else{
            rvUseful?.isShowMenu.value = true
            self.currentId = rvUseful!.id
        }
    }
}

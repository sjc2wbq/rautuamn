//
//  NearActivityDetailViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//活动详情

import UIKit
import SDWebImage
import SwiftyDrop
import SDAutoLayout
import Then
import IBAnimatable
import RxSwift
class NearActivityDetailViewController: UIViewController {
    let imageHeigt:CGFloat = 370
    @IBOutlet weak var btn_bottom: AnimatableButton!

    @IBOutlet weak var btn_bottom_h: NSLayoutConstraint!
    let headerView = NearActivityHeaderView.headerView()
    let footerView = NearActivityFooterView.footerView()
    @IBOutlet weak var tableView: UITableView!
    var exitActivity = Variable(false)
    var raId = 0
    fileprivate var model:NearActivityDetailModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(NearActivityDetailViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_bottom_h.constant = 0
        self.btn_bottom.isHidden = true
        initTableView()
        title = "活动详情"
//        initBarManager()
        do{ //退出活动
            let activityIndicator = ActivityIndicator()
           let request =  self.exitActivity.asObservable()
                .filter{$0 == true}
                .flatMap{_ in RequestProvider.request(api: ParametersAPI.exitActivity(raId: self.raId)).mapObject(type: EmptyModel.self)
                .trackActivity(activityIndicator)
                }
            .shareReplay(1)
        
            request.flatMap{$0.unwarp()}
                .subscribe {[unowned self] (_) in
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshActivityDataNotifation"), object: nil)
                _ = self.navigationController?.popViewController(animated: true)
                Drop.down("退出活动成功！", state: .success)
                }
                .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)

        }
    
        do{
            rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
                .subscribe(onNext: { (_) in
                    MXNavigationBarManager.reStoreToSystemNavigationBar()
                    }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        }
        fecthData()
    }
    func initBarManager()  {
        self.title = "活动详情"
        MXNavigationBarManager.manager(with: self)
        MXNavigationBarManager.setBarColor(UIColor.white)
        MXNavigationBarManager.setTintColor(UIColor.black)
        MXNavigationBarManager.setStatusBarStyle(UIStatusBarStyle.default)
        MXNavigationBarManager.setZeroAlphaOffset(64)
        MXNavigationBarManager.setFullAlphaOffset(Float(imageHeigt - 64))
        MXNavigationBarManager.setFullAlphaTintColor(UIColor.black)
        MXNavigationBarManager.setFullAlphaBarStyle(UIStatusBarStyle.default)
    }
    ///我要参加
    @IBAction func btnAction(_ sender: UIButton) {
    
        if let model = model {
            if model.enroll {
                let alertController = UIAlertController(title: "提示", message: "您确定要退出该活动？", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler:nil))
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {[unowned self] (_) in
                    self.exitActivity.value = true
                }))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if model.raeCount >= model.enrollmentCeiling {
                let alertController = UIAlertController(title: "提示", message: "此活动报名人数已满！", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler:nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            if model.publishUserNickName == UserModel.shared.nickName.value{
                let alertController = UIAlertController(title: "提示", message: "自己不能参加自己组的局！", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler:nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
        
        }
        
        if UserModel.shared.rank.value == "U"{
            let vc = UIAlertController(title: "温馨提示", message: "开通注册会员后，才能参加此活动，是否去开通？", preferredStyle: .alert)
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
        
      let request =  RequestProvider.request(api: ParametersAPI.activityEnroll(raId: raId)).mapObject(type: EmptyModel.self)
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}
        .subscribe {[unowned self] (_) in
         let alertController = UIAlertController(title: "提示", message: "您已报名成功，请按时参加！", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "确定", style: .default, handler:{[unowned self] _ in
         _ =  self.navigationController?.popViewController(animated: true)
            
                }
            ))
        self.present(alertController, animated: true, completion: nil)
        }
        .addDisposableTo(rx_disposeBag)
        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
            Drop.down(error, state: .error)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
}
extension NearActivityDetailViewController : UITableViewDelegate,UITableViewDataSource{
    fileprivate func initTableView(){
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        tableView.tableFooterView = footerView
        tableView.tableHeaderView = headerView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = bgColor
        tableView.register(UINib(nibName: "NearActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "NearActivityTableViewCell")
        tableView.register(UINib(nibName: "NearActivity2TableViewCell", bundle: nil), forCellReuseIdentifier: "NearActivity2TableViewCell")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NearActivity2TableViewCell") as! NearActivity2TableViewCell
            if let model = self.model{
                cell.lb_title.text = "局长：\(model.publishUserNickName)"
                cell.lb_subTitle.text = "局长电话：\(model.userPhone)"
                cell.img_icon.sd_setImage(with: URL(string:model.publishUserHpu), placeholderImage: placeHolderImage)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearActivityTableViewCell") as! NearActivityTableViewCell
        var title  = ""
        var subTitle  = ""
        if let model = self.model{
            if indexPath.row == 0 {
                title = "时间"
                subTitle = model.activityDateTime
            }else  if indexPath.row == 1 {
                title = "地点"
                subTitle = model.place
            }else  if indexPath.row == 2 {
                title = "人数限制"
                subTitle = "\(model.enrollmentCeiling)人"
            }else  if indexPath.row == 3 {
                title = "预收金额"
                subTitle = "\(model.expense)元（费用说明：男女不限，费用均摊，适当管理费除外，余额返还）"
            }
            cell.lb_title.text = title
            cell.lb_subTitle.text = subTitle
        
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4{
        return 164
        }
        return cellHeight(for: indexPath, cellContentViewWidth: screenW , tableView: tableView)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  contentOfSetY = scrollView.contentOffset.y
       MXNavigationBarManager.changeAlpha(withCurrentOffset: contentOfSetY)
    }
}
extension NearActivityDetailViewController{
    fileprivate func fecthData(){
     let request = RequestProvider.request(api: ParametersAPI.activityDetails(raId: raId)).mapObject(type: NearActivityDetailModel.self)
        .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
            Drop.down(error, state: .error)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
                self.model = model
                self.headerView.model = model
                self.footerView.model = model
                if UserModel.shared.id == model.rauActivityUserId{
                self.btn_bottom_h.constant = 0
                    self.btn_bottom.isHidden = true
                }else{
                    self.btn_bottom_h.constant = 30
                    self.btn_bottom.isHidden = false

                }
                self.btn_bottom.setTitle(model.enroll == true ? " 退出活动" : " 我要参加", for: .normal)
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
}

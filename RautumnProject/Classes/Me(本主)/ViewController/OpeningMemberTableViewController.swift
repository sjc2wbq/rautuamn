//
//  OpeningMemberTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper
import SwiftyDrop
class OpeningMemberTableViewController: UITableViewController {
    var objId = 0
    var payName = ""
    var payDesc = ""
    var type = 1
    var price : Float = 0
    var dataSource = [Vipsetting]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
          navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "wenhao")
      navigationItem.rightBarButtonItem!.rx.tap
        .subscribe(onNext: {[unowned self] (error) in
       let vc = MembershipPrivilegesViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)

            
        }
        title = "开通注册会员"
        do{
            let request =  RequestProvider.request(api: ParametersAPI.getVIPOrderSettingList(type:type)).mapObject(type: VIPOrderSettingListModel.self)
            .shareReplay(1)
            request.flatMap{$0.unwarp()}
                .map{$0.result_data?.vipSettings}.unwrap()
            .subscribe(onNext: { (models) in
                self.dataSource = models
                if let model = models.first{
                    self.objId = model.id
                    let dateF = DateFormatter()
                    dateF.dateFormat = "YYYY年MM月dd日"
                    let timeInterval = dateF.date(from: model.discountEndDate)!.timeIntervalSince1970
                    log.info("Date().timeIntervalSince1970 =----- \(Date().timeIntervalSince1970) --- timeInterval === \(timeInterval)")
                    if Date().timeIntervalSince1970 >= timeInterval{
                            self.price = model.price
                    }else{
                        self.price = Float(String(format:"%.2f",model.price - model.preferentialQuota))!
                    }
                    self.payDesc = "1个月会员费用：￥\(self.price) ,\(model.discountEndDate)前优惠季"
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                zfbPay()
            }else{
                weChatPay()
            }
        }else{
          let model = dataSource[indexPath.row]
            dataSource.forEach({ (setting) in
                setting.selected.value = false
            })
            model.selected.value = true
            objId = model.id
            let dateF = DateFormatter()
            dateF.dateFormat = "YYYY年MM月dd日"
             let timeInterval = dateF.date(from: model.discountEndDate)!.timeIntervalSince1970
            log.info("Date().timeIntervalSince1970 =----- \(Date().timeIntervalSince1970) --- timeInterval === \(timeInterval)")
            if Date().timeIntervalSince1970 >= timeInterval{
                self.price = model.price
            }else{
                self.price = Float(String(format:"%.2f",model.price - model.preferentialQuota))!
            }
            payDesc = "\(model.month)个月会员费用：￥\(model.price) ,\(model.discountEndDate)前优惠季"
        }
    }
    
    fileprivate func zfbPay(){
        let activityIndicator = ActivityIndicator()
        let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: objId, type: 2, payType: 1))
            .trackActivity(activityIndicator)
            .mapObject(type: OrderInfo.self)
            .shareReplay(1)
        
        let request = getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .flatMap{RequestProvider.request(api: ParametersAPI.payDemoActivity(subject: "镭秋币充值", body: self.payDesc, price: "\(self.price)", out_trade_no: $0.number, type: "2"))
            }
            .mapObject(type: ZHBPayInfo.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        let pay =   request.flatMap{$0.unwarp()}.map{$0.result_data?.payInfo}.unwrap().flatMap { (payInfo ) -> Observable<(Bool,String)> in
            Observable.create({ (observer ) -> Disposable in
                AISharedPay.handleAlipay(payInfo, paymentBlock: { (success, object, msg) in
                    observer.onNext((success,msg!))
                    observer.onCompleted()
                })
                return Disposables.create()
                
            })
        }
        
        pay.subscribe(onNext: { (result:(success:Bool,msg:String)) in
            if  result.success {
                self.paySuccessCallBack()
            }else{
                self.show(error:result.msg)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        
        getOrderIdRequest.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (_) in
                Drop.down("获取订单信息失败！", state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (_) in
                Drop.down("获取支付信息失败！", state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
    
    fileprivate func weChatPay(){
        let activityIndicator = ActivityIndicator()
        let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: objId, type: 2, payType: 2))
            .trackActivity(activityIndicator)
            .mapObject(type: OrderInfo.self)
            .shareReplay(1)
        
        
        getOrderIdRequest.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (_) in
                Drop.down("获取订单信息失败！", state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        //¥
        getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .flatMap{RequestProvider.request(api: ParametersAPI.payDemoActivity(subject: "镭秋币充值", body: self.payDesc, price: (self.payDesc as NSString).substring(from: 1), out_trade_no: $0.number, type: "1"))
            }
            .trackActivity(activityIndicator)
            
            .shareReplay(1)
        
        
        let request = getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .flatMap{RequestProvider.request(api: ParametersAPI.wxPayCreateOrder(out_trade_no: $0.number, body: self.payDesc, total_fee: self.price * Float(100), type: 2))
            }
            .mapObject(type: WXPayInfo.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        let pay =   request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().flatMap { (payInfo ) -> Observable<(Bool,String)> in
            Observable.create({ (observer ) -> Disposable in
                AISharedPay.handleWeixinPayment(Mapper<WXPayInfo>().toJSON(payInfo), paymentBlock: { (success, object, msg) in
                    observer.onNext((success,msg!))
                    observer.onCompleted()
                })
                return Disposables.create()
                
            })
        }
        pay.subscribe(onNext: { (result:(success:Bool,msg:String)) in
            if  result.success {
                self.paySuccessCallBack()
            }else{
                self.show(error:result.msg)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        getOrderIdRequest.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (_) in
                Drop.down("获取订单信息失败！", state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (_) in
                Drop.down("获取支付信息失败！", state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    fileprivate func paySuccessCallBack(){
        let av = UIAlertController(title: "提示", message: "恭喜您支付成功！", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "确定", style: .default, handler: {[unowned self] (_) in
            UserModel.shared.rank.value = "M"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUserInfoSuccessNotifation"), object: nil)
            _ =  self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(av, animated: true, completion: nil)
    }

    
}
extension OpeningMemberTableViewController{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                //OpeningMemberWeChatTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningMemberZFBTableViewCell") as! OpeningMemberZFBTableViewCell

                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningMemberWeChatTableViewCell") as! OpeningMemberWeChatTableViewCell
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningMemberRankTableViewCell") as! OpeningMemberRankTableViewCell
        let  model = dataSource[indexPath.row]
        model.selected.value = indexPath.row == 0
        cell.vipsetting = dataSource[indexPath.row]
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataSource.count
        }
        return 2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "选择充值会员"
        }
        return "选择充值方式"
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
        return 60
        }
        return 80
    }
}


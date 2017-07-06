

//
//  RechargeViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//充值

import UIKit
import ObjectMapper
import RxSwift
import SwiftyDrop

struct WXPayInfo {
    /*
     
     "timeStamp": "",
     "package": "",
     "appid": "",
     "sign": "",
     "partnerId": "",
     "prepayId": "",
     "nonceStr": ""
     */
    var timeStamp:String = ""
    var package:String = ""
    var appid:String = ""
    var sign:String = ""
    var partnerId:String = ""
    var prepayId:String = ""
    var nonceStr:String = ""
    
    init?( map: Map) {}
    
}

extension WXPayInfo: Mappable {
    mutating func mapping(map: Map) {
        timeStamp <- map["timeStamp"]
        package <- map["package"]
        appid <- map["appid"]
        sign <- map["sign"]
        partnerId <- map["partnerId"]
        prepayId <- map["prepayId"]
        nonceStr <- map["nonceStr"]
    }
}
struct ZHBPayInfo {
    
    var payInfo:String = ""
    init?( map: Map) {}
    
}

extension ZHBPayInfo: Mappable {
    mutating func mapping(map: Map) {
        payInfo <- map["payInfo"]
    }
}


struct OrderInfo : Mappable {
    var number = ""
    init?( map: Map) {}
    mutating func mapping(map: Map) {
        number <- map["number"]
    }
    
}
class RechargeViewController: UITableViewController {
    @IBOutlet weak var btn1: UIButton!
    var btn_selected : UIButton?
    var objId = 1
    var payName = ""
    var payDesc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = bgColor
        title = "充值"
        priceBtnAction(btn1)
        
    }
    @IBAction func priceBtnAction(_ sender: UIButton) {
        btn_selected?.isSelected = false
        sender.isSelected = true
        btn_selected = sender
        payDesc = sender.titleLabel!.text!
        if sender.tag == 10{
            objId = 1
        }else if sender.tag == 11{
            objId = 2
        }else if sender.tag == 12{
            objId = 3
        }else if sender.tag == 13{
            objId = 4
        }else if sender.tag == 14{
            objId = 5
        }else if sender.tag == 15{
            objId = 6
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
        }
    }
    
    fileprivate func zfbPay(){
        let activityIndicator = ActivityIndicator()
        let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: objId, type: 1, payType: 1))
            .trackActivity(activityIndicator)
            .mapObject(type: OrderInfo.self)
            .shareReplay(1)

       let request = getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .flatMap{RequestProvider.request(api: ParametersAPI.payDemoActivity(subject: "镭秋币充值", body: self.payDesc, price: (self.payDesc as NSString).substring(from: 1), out_trade_no: $0.number, type: "1"))
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
        let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: objId, type: 1, payType: 2))
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
            .flatMap{RequestProvider.request(api: ParametersAPI.wxPayCreateOrder(out_trade_no: $0.number, body: self.payDesc, total_fee: Float((self.payDesc as NSString).substring(from: 1))! * Float(100), type: 1))
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
            UserModel.shared.rautumnCurrency.value = Float((self.payDesc as NSString).substring(from: 1))! +  UserModel.shared.rautumnCurrency.value
         _ =  self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(av, animated: true, completion: nil)
    }
}

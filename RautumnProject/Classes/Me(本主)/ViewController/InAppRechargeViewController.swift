//
//  InApRechargeViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/15.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit
import SwiftyStoreKit
import ARSLineProgress
import SwiftyDrop
class InAppRechargeViewController: UITableViewController {
    var purchase : RegisteredPurchase = .gold1

    @IBOutlet weak var btn1: UIButton!
    var btn_selected : UIButton?
    var objId = 1
    var payName = ""
    var payDesc = ""
    var paymoney : Float = 0
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
            payName = "50镭秋币"
            purchase = .gold1
            paymoney = 50
        }else if sender.tag == 11{
            objId = 2
            payName = "100镭秋币"
            purchase = .gold2
            paymoney = 100

        }else if sender.tag == 12{
            objId = 3
            purchase = .gold3
            payName = "200镭秋币"
            paymoney = 200

        }else if sender.tag == 13{
            objId = 4
            purchase = .gold4
            payName = "400镭秋币"
            paymoney = 400

        }else if sender.tag == 14{
            objId = 5
            purchase = .gold5
            payName = "800镭秋币"
            paymoney = 800

        }else if sender.tag == 15{
            objId = 6
            payName = "1000镭秋币"
            purchase = .gold6
            paymoney = 1000

        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
               applePayBuy()
            }else{
reStoreBug()
            }
        }
    }

    func applePayBuy()  {
        ARSLineProgress.show()
        //        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
            //            NetworkActivityIndicatorManager.networkOperationFinished()
            ARSLineProgress.hide()
            if let product = result.retrievedProducts.first {
                //                let priceString = product.localizedPrice!
                let total_fee : Float = self.paymoney
                
                //                return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
                let message = "确实以￥\(total_fee)的价格购买一个APP内购项目 *\(self.payName)"
                
                let alert = UIAlertController(title: product.localizedTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "购买", style: .default, handler: {_ in
                    ARSLineProgress.show()
                    //                    NetworkActivityIndicatorManager.networkOperationStarted()
                    SwiftyStoreKit.purchaseProduct(AppBundleId + "." + self.purchase.rawValue, atomically: true) { result in
                        //                        NetworkActivityIndicatorManager.networkOperationFinished()
                        ARSLineProgress.hide()
                        if case .success(let product) = result {
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                            
                            let activityIndicator = ActivityIndicator()
                            
                            
                            let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: self.objId, type: 1, payType: 3))
                                .trackActivity(activityIndicator)
                                .mapObject(type: OrderInfo.self)
                                .shareReplay(1)
                            
                            
                            let request =  getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
                                .unwrap()
                                .flatMap{RequestProvider.request(api: ParametersAPI.rautumnCurrencyOrder(out_trade_no: $0.number, trade_no: $0.number, total_fee: "\(total_fee)")).mapObject(type: EmptyModel.self)}
                                .shareReplay(1)
                            
                            Observable.from([getOrderIdRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}])
                                .merge()
                                .subscribe(onNext: { (_) in
//                                    Drop.down("获取订单信息失败！", state: .error)
                                    
                                }, onError: nil, onCompleted: nil, onDisposed: nil)
                                .addDisposableTo(self.rx_disposeBag)
                            
                            request.flatMap{$0.unwarp()}
                                .subscribe(onNext: { (_) in
                                    UserModel.shared.rautumnCurrency.value = self.paymoney +  UserModel.shared.rautumnCurrency.value
                                    self.showAlert(self.alertWithTitle("提示", message: "购买成功！"))
                                }, onError: nil, onCompleted: nil, onDisposed: nil)
                                .addDisposableTo(self.rx_disposeBag)
                            
                            
                            
                        }else{
                            self.showAlert(self.alertForPurchaseResult(result))
                        }
                        
                    }
                    
                }))
                self.showAlert(alert)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                self.showAlert(self.alertWithTitle("无法检索产品信息", message: "无效的产品标识符: \(invalidProductId)！"))
            }
            else {
                let errorString = result.error?.localizedDescription ?? "未知的错误。请联系支持！"
                self.showAlert(self.alertWithTitle("无法检索产品信息", message: errorString))
                
            }
            
        }
    }
    func reStoreBug()  {
        ARSLineProgress.show()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            ARSLineProgress.hide()
            if results.restoreFailedProducts.count > 0 {
                self.showAlert(self.alertWithTitle("提示", message: "恢复购买该商品失败！"))
            }
            else if results.restoredProducts.count > 0 {
                self.showAlert(self.alertWithTitle("提示", message: "恢复购买成功！"))
            }
            else {
                self.showAlert(self.alertWithTitle("提示", message: "没有可以恢复购买的商品！"))                
            }
        }
        
    }
    func showAlert(_ alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertWithTitle(_ title: String, message: String,hander:((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: hander))
        return alert
    }
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController {
        switch result {
        case .success(let _):
            return alertWithTitle("感谢您的购买", message: "购买完成！", hander: {[unowned self] (_) in
                _ =  self.navigationController?.popViewController(animated: true)
            })
            
        case .error(let error):
            print("购买失败: \(error)")
            switch error {
            case .failed(let error):
                if (error as NSError).domain == SKErrorDomain {
                    return alertWithTitle("购买失败", message: "请检查您的网络连接或者稍后重试！")
                }
                return alertWithTitle("购买失败", message: "未知的错误。请联系支持！")
            case .invalidProductId(let productId):
                return alertWithTitle("购买失败", message: "\(productId) 不是一个有效的产品标识符")
            case .paymentNotAllowed:
                return alertWithTitle("支付未启用", message: "当前不允许支付！")
            }
        }
    }
}

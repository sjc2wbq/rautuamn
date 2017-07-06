//
//  InAppOpeningMemberTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/15.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import StoreKit
import RxSwift
import ARSLineProgress
import SwiftyStoreKit
import SwiftyDrop
enum RegisteredPurchase : String {
    case gold1 = "gold1"
    case gold2 = "gold2"
    case gold3 = "gold3"
    case gold4 = "gold4"
    case gold5 = "gold5"
    case gold6 = "gold6"
    case vip1 = "vip4"
    case vip2 = "vip5"
    case vip3 = "vip6"
}
let AppBundleId = "com.rautumn.rautumn"


class InAppOpeningMemberTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! InAppOpeningMemberPayTableViewController
        if segue.identifier == "pushInApp1" {
            vc.purchase = .vip1
            vc.paymoney = 18
            vc.payName = "1个月会员"
        }else if segue.identifier == "pushInApp2" {
            vc.purchase = .vip2
            vc.paymoney = 48
            vc.payName = "3个月会员"
        }else if segue.identifier == "pushInApp3" {
            vc.purchase = .vip3
            vc.paymoney = 188
            vc.payName = "1年会员"

        }
        
    }
}
class InAppOpeningMemberPayTableViewController: UITableViewController {
    var purchase : RegisteredPurchase = .gold1

    var paymoney : Double = 0
    var objId = 1
    var payName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        title = "立即购买"
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            applePayBuy()
        }else{
            reStoreBug()
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
                let total_fee : Double = self.paymoney
        
                //                return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
               let message = "确实以￥\(total_fee)的价格购买一个APP内购项目 *\(self.payName)"

                let alert = UIAlertController(title: product.localizedTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "购买", style: .default, handler: {_ in
//                    NetworkActivityIndicatorManager.networkOperationStarted()
                    ARSLineProgress.show()
                    SwiftyStoreKit.purchaseProduct(AppBundleId + "." + self.purchase.rawValue, atomically: true) { result in
//                        NetworkActivityIndicatorManager.networkOperationFinished()
                        ARSLineProgress.hide()
                        if case .success(let product) = result {
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                    
                            let activityIndicator = ActivityIndicator()
                            
                            let getOrderIdRequest = RequestProvider.request(api: ParametersAPI.placeAnOrder(objId: self.objId, type: 2, payType: 3))
                                .trackActivity(activityIndicator)
                                .mapObject(type: OrderInfo.self)
                                .shareReplay(1)
                            
                
                          let request =  getOrderIdRequest.flatMap{$0.unwarp()}.map{$0.result_data}
                                .unwrap()
                                .flatMap{RequestProvider.request(api: ParametersAPI.vipOrder(out_trade_no: $0.number, trade_no: $0.number, total_fee: "\(total_fee)")).mapObject(type: EmptyModel.self)}
                                  .shareReplay(1)

                            Observable.from([getOrderIdRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}])
                                .merge()
                                .subscribe(onNext: { (_) in
//                  	                  Drop.down("获取订单信息失败！", state: .error)
   
                                }, onError: nil, onCompleted: nil, onDisposed: nil)
                                .addDisposableTo(self.rx_disposeBag)
                            
                            request.flatMap{$0.unwarp()}
                            .subscribe(onNext: { (_) in
                                UserModel.shared.rank.value = "M"
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


//
//  WithdrawViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
class WithdrawViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var lb_withdrawPrice: UILabel!
    @IBOutlet weak var tf_price: UITextField!
    @IBOutlet weak var tf_zfbAcount: UITextField!
    @IBOutlet weak var tf_weChatAcount: UITextField!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(WithdrawViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "申请提现"
        lb_withdrawPrice.text = "可提现金额：￥\(UserModel.shared.rautumnCurrency.value)(1币= ￥1)"
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)

        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @IBAction func submitAction(_ sender: Any) {
        guard let price = tf_price.text else {
            Drop.down("请输入提现金额！", state: .error)
            return
        }
        if price.characters.count == 0 {
            Drop.down("请输入提现金额！", state: .error)
            return
        }
        if Float(price)! <= 0 {
            Drop.down("提现金额必须大于0！", state: .error)
            return
        }
        if Float(price)! > UserModel.shared.rautumnCurrency.value {
            Drop.down("最多提现\(UserModel.shared.rautumnCurrency.value)元！", state: .error)
            return
        }
        guard let zfbAcount = tf_zfbAcount.text,let weChatAcount = tf_weChatAcount.text else {
            Drop.down("请输入支付宝或者微信账号！", state: .error)
            return
        }
    
        if zfbAcount.characters.count == 0 && weChatAcount.characters.count == 0{
            Drop.down("请输入支付宝或者微信账号！", state: .error)
            return
        }
        if zfbAcount.characters.count != 0 && weChatAcount.characters.count != 0{
            Drop.down("不能同时输入支付宝或者微信账号！", state: .error)
            return
        }
        let activityIndicator = ActivityIndicator()
       let request =  RequestProvider.request(api: ParametersAPI.withdrawDeposit(rautumnCurrency: Double(price)!, alipay: tf_zfbAcount.text!, weChatAccount: tf_weChatAcount.text!)).mapObject(type: EmptyModel.self)
        .trackActivity(activityIndicator)
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            UserModel.shared.rautumnCurrency.value = UserModel.shared.rautumnCurrency.value - Float(price)!
            _ = self.navigationController?.popViewController(animated: true)
            Drop.down("提现申请已提交，等待平台审核！", state: .success)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}.subscribe(onNext: { (error) in
            Drop.down(error, state: .error)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }


}

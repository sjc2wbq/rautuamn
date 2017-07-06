//
//  ForgetPwdTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/7.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import IBAnimatable
class ForgetPwdTableViewController: UITableViewController {
    @IBOutlet weak var tf_phone: UITextField!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var tf_pwd: UITextField!

    @IBOutlet weak var btn_getCode: AnimatableButton!
    @IBOutlet weak var btn_done: AnimatableButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tf_phone.rx.text.unwrap().map{$0.isMobileNumber()}.bindTo(btn_getCode.rx.isEnabled).addDisposableTo(rx_disposeBag)
        
        
        do{ //获取验证码
            let activityIndicator = ActivityIndicator()
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
            let getCodeRequest =  btn_getCode.rx.tap.flatMap{RequestProvider.request(api: ParametersAPI.getVerificationCode(phone: self.tf_phone.text!, type: 2)).mapObject(type: VerificationCode.self)
                .trackActivity(activityIndicator)
                }
                .shareReplay(1)
            getCodeRequest.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            })
            .addDisposableTo(rx_disposeBag)
            getCodeRequest.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: { (code) in
            self.btn_getCode.startTime(timeOut: 60)
            })
            .addDisposableTo(rx_disposeBag)
        }
    
    
        do{ //忘记密码操作
            btn_done.addTarget(self, action: #selector(doneBtnAction), for: .touchUpInside)
            
        
        }
    }
    @objc fileprivate func doneBtnAction(){
        self.view.endEditing(true)
        guard let phone = tf_phone.text else {
            Drop.down("请输入手机号码！", state: .error)
            tf_phone.becomeFirstResponder()
            return
        }
        if phone.characters.count == 0 {
            Drop.down("请输入手机号码！", state: .error)
            tf_phone.becomeFirstResponder()
        return
        }
        
        if !phone.isMobileNumber() {
            Drop.down("手机号码格式有误！", state: .error)
            tf_phone.becomeFirstResponder()

            return
        }
    
        guard let code = tf_code.text else {
            Drop.down("请输入验证码！", state: .error)
            return
        }
        if code.characters.count != 6 {
            Drop.down("请输入6位验证码！", state: .error)
            tf_code.becomeFirstResponder()
            return
        }
        
        guard let pwd = tf_pwd.text else {
            Drop.down("请输入密码！", state: .error)
            tf_pwd.becomeFirstResponder()

            return
        }
        if pwd.characters.count == 0 {
            Drop.down("请输入密码！", state: .error)
            tf_pwd.becomeFirstResponder()
            return
        }
        if pwd.containSpecialCharacters() {
            Drop.down("密码为6~20位英文字母和数字,不能包含特殊字符！", state: .error)
            return
        }
        if !pwd.isPassWord() {
            Drop.down("密码为6~20位英文字母和数字！", state: .error)
            return
        }
      let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在提交...", for: view)).addDisposableTo(rx_disposeBag)
      let request =   RequestProvider.request(api: ParametersAPI.forgetPassword(phone: phone, newPassword: pwd, vcode: code)).mapObject(type: EmptyModel.self)
        .trackActivity(activityIndicator)
        .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            })
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}
            .subscribe(onNext: { (_) in
            _ =  self.navigationController?.popViewController(animated: true)
                Drop.down("修改登录密码成功！", state: .success)
            })
            .addDisposableTo(rx_disposeBag)

        
    }
}

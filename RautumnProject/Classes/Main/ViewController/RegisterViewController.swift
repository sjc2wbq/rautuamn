//
//  RegisterViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/27.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import SwiftyDrop
class RegisterViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var tf_phone: UITextField!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var tf_pwd: UITextField!
    @IBOutlet weak var btn_getCode: UIButton!
    @IBOutlet weak var btn_nextStop: UIButton!
    @IBOutlet weak var animatedImagesView: RCAnimatedImagesView!
    @IBOutlet weak var img_loginBg: UIImageView!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    
    var viewModel:RegisterViewModel!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        title = NSLocalizedString("RegisterTitle", comment: "")
        bindViewModel()
        bindRx()
        animatedImagesView.delegate = self
        tf_phone.delegate = self
        tf_pwd.delegate = self
        tf_code.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatedImagesView.startAnimating()
        img_loginBg.isHidden = true
       animatedImagesView.isHidden = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        img_loginBg.isHidden = false
        animatedImagesView.isHidden = true
        animatedImagesView.stopAnimating()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func agreeEvent(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func goToAgreement(_ sender: UIButton) {
        let vc = WebViewViewController()
        vc.title = "用户协议"
        vc.urlStr = "http://www.rautumn.com/resource/platformProtocol/1492174107177679969.html"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension RegisterViewController{
    func  bindRx()  {
        rx.sentMessage(#selector(UIViewController.touchesBegan(_:with:))).subscribe(onNext: { (_) in
            self.view.endEditing(true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }
    fileprivate func bindViewModel(){
        viewModel =     RegisterViewModel(input:(tf_phone.rx.text.asObservable(),
                                          code:tf_code.rx.text.asObservable(),
                                          password:tf_pwd.rx.text.asObservable(),
                                          getVerificationCodeAction:btn_getCode.rx.tap.asObservable(),
                                          checkVerificationCodeAction:btn_nextStop.rx.tap.asObservable()))

        
            viewModel.getVerificationCodeBtnEnable.bindTo(btn_getCode.rx.isEnabled)
        .addDisposableTo(rx_disposeBag)
        

        viewModel.getingVerificationCode.bindTo(isLoading(showTitle: "正在获取验证码...", for: self.view)).addDisposableTo(rx_disposeBag)
        
        viewModel.getingVerificationCode.map{!$0}.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)
        viewModel.checkingVerificationCode.map{!$0}.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)

        viewModel.getVerificationCodeSuccess.subscribe(onNext: { (code) in
                self.btn_getCode.startTime(timeOut: 60)
//                Drop.down(code!, state: .info)

            })
        .addDisposableTo(rx_disposeBag)

        btn_nextStop.addTarget(self, action: #selector(RegisterViewController.btn_nextStopAction), for: .touchUpInside)
    }
    @objc fileprivate func btn_nextStopAction(){
//        self.performSegue(withIdentifier: "pushRegister2VC", sender: self)
//        return
        guard let phone = tf_phone.text  else{
            Drop.down("请输入手机号码！", state: .error)
            return
        }
        if phone.characters.count == 0 {
            Drop.down("请输入手机号码！", state: .error)
            tf_phone.becomeFirstResponder()
            return
        }
        if !phone.isMobileNumber() {
            Drop.down("输入手机号码格式有误！", state: .error)
            tf_phone.becomeFirstResponder()
            return
        }
        guard let vCode = tf_code.text  else{
            Drop.down("请输入验证码！", state: .error)
            tf_code.becomeFirstResponder()
            return
        }
        
        if vCode.characters.count != 6 {
            Drop.down("请输入6位验证码！", state: .error)
            tf_code.becomeFirstResponder()
            return
        }
        
        guard let pwd = tf_pwd.text  else{
            Drop.down("请输入注册密码！", state: .error)
            return
        }
        if pwd.characters.count == 0 {
            Drop.down("请输入注册密码！", state: .error)
            tf_pwd.becomeFirstResponder()
            return
        }
        if !pwd.isPassWord() {
            Drop.down("请输入6~20位的英文或者数字密码！", state: .error)
            tf_pwd.becomeFirstResponder()
            return
        }
        
        if !agreeButton.isSelected {
            Drop.down("请阅读并同意《用户协议》！", state: .error)
            return
        }
        
        let checkVerificationCodeActivityIndicator = ActivityIndicator()
        
        checkVerificationCodeActivityIndicator.asObservable().bindTo(isLoading(showTitle: "正在验证中...", for: self.view)).addDisposableTo(rx_disposeBag)
        let request = RequestProvider.request(api: ParametersAPI.registerVerificationVCode(userPhone:phone , vcode: vCode)).mapObject(type: EmptyModel.self)
            .trackActivity(checkVerificationCodeActivityIndicator)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}
        .subscribe(onNext: {[unowned self] (_) in
            self.performSegue(withIdentifier: "pushRegister2VC", sender: self)

        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: {(error) in
                Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushRegister2VC" {
            let vc = segue.destination as! Register2ViewController
            if let userPhone = tf_phone.text, let vcode = tf_code.text,let password = tf_pwd.text{
                vc.userPhone = userPhone
                vc.vcode = vcode
                vc.password = password
            }
        }
    }
    func initChildViews()  {

        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenW, height: 64))
        navBar.rc_setBackgroundColor(UIColor.white.withAlphaComponent(0))
       let navigationItem =  UINavigationItem(title: NSLocalizedString("RegisterTitle", comment: ""))
        let leftNavBarItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "back")
        leftNavBarItem.rx.tap.subscribe(onNext: { (_) in
          _ =   self.navigationController?.popViewController(animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        navigationItem.leftBarButtonItem = leftNavBarItem
        navBar.items = [navigationItem]
        view.addSubview(navBar)
    }
}
extension RegisterViewController:RCAnimatedImagesViewDelegate{
    func animatedImagesNumber(ofImages animatedImagesView: RCAnimatedImagesView!) -> UInt {
        return 2
    }
    func animatedImagesView(_ animatedImagesView: RCAnimatedImagesView!, imageAt index: UInt) -> UIImage! {
        return UIImage(named: "bg_login")
    }
}

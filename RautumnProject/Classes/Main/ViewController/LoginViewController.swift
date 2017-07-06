//
//  LoginViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/27.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import IBAnimatable
import SwiftyDrop
import NSObject_Rx
class LoginViewController: UIViewController,RCIMConnectionStatusDelegate,UITextFieldDelegate{
    @IBOutlet weak var tf_phone: UITextField!
    @IBOutlet weak var tf_pwd: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var animatedImagesView: RCAnimatedImagesView!
    @IBOutlet weak var img_loginBg: UIImageView!
   
    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var lookAgreementButton: UIButton!
    
//btnNormalImage
    override func viewDidLoad() {
        super.viewDidLoad()
//        initChildViews()
        title = NSLocalizedString("LoginTitle", comment: "")
        bindRx()
        animatedImagesView.delegate = self
        tf_phone.delegate = self
        tf_pwd.delegate = self
        do{
            if UserDefaults.standard.bool(forKey: "BOOLFORKEY"){
                
            }else{
               
                UserDefaults.standard.set(true, forKey: "BOOLFORKEY")
                let imageNameArray = ["page1","page2"]
                
       
                let guidePage = DHGuidePageHUD(frame: UIScreen.main.bounds, imageNameArray: imageNameArray, buttonIsHidden: true)
                guidePage?.slideInto = true
                self.navigationController?.view.addSubview(guidePage!)
                
                guidePage?.leftBtn.rx.tap.subscribe(onNext: { (_) in
                    UIView.animate(withDuration: 0.25, animations: {
                        guidePage?.alpha = 0
                    }, completion: { (_) in
                        guidePage?.removeFromSuperview()
                    })
                }).addDisposableTo(rx_disposeBag)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.img_loginBg.isHidden = true
        animatedImagesView.isHidden = false
        animatedImagesView.startAnimating()
//        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.img_loginBg.isHidden = false
        animatedImagesView.isHidden = true
        animatedImagesView.stopAnimating()
//        navigationController?.navigationBar.isHidden = false
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
    
    @IBAction func goToRegister(_ sender: UIButton) {
        
        
        
        
        
        
        let vc = UIStoryboard.init(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "Register_rautumn")
        
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
extension LoginViewController{
    
    
    
    @IBAction func loginAction(_ sender: AnimatableButton) {
        guard let phone = tf_phone.text  else{
            Drop.down("请输入手机号码！", state: .error)
            return
        }
        if phone.characters.count == 0 {
            Drop.down("请输入手机号码！", state: .error)
            return
        }
        if !phone.isMobileNumber() {
            Drop.down("输入手机号码格式有误！", state: .error)
            tf_phone.text = nil
            tf_phone.becomeFirstResponder()
            return
        }
        guard let pwd = tf_pwd.text  else{
            Drop.down("请输入登录密码！", state: .error)
            return
        }
        if pwd.characters.count == 0 {
            Drop.down("请输入登录密码！", state: .error)
            return
        }
        if pwd.containSpecialCharacters() {
            Drop.down("密码为6~20位英文字母和数字,不能包含特殊字符！", state: .error)
            return
        }
        if !pwd.isPassWord() {
            Drop.down("请输入6~20位的英文或者数字密码！", state: .error)
            tf_pwd.text = nil
            tf_pwd.becomeFirstResponder()
            return
        }
        
        if !agreeButton.isSelected {
            Drop.down("请阅读并同意《用户协议》！", state: .error)
            return
        }
        
        let aactivityIndicator = ActivityIndicator()
        aactivityIndicator.asObservable().bindTo(isLoading(showTitle: "登录中...", for: view)).addDisposableTo(rx_disposeBag)
         let request =  RequestProvider.request(api: ParametersAPI.userLogin(phone: phone, password: pwd.md5())).mapObject(type: UserModel.self)
        .trackActivity(aactivityIndicator)
        .shareReplay(1)

         let loginIMReuquest =  request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .do(onNext: { (userModel) in
                UserModel.shared = userModel
//                MBProgressHUD.bwm_showAdded(to: self.view, title: "登录中...")
            
            })
            .flatMap({ (userModel) -> Observable<Result<String>> in
                if let _ = UserDefaults.standard.value(forKey: "userToken") as? String{
                    return  Observable.create({ (observer ) -> Disposable in
                        observer.onNext(Result.success("登录成功！"))
                        observer.onCompleted()
                        return Disposables.create()
                    })
                }
                return  self.loginIM(token: userModel.token)
                    .trackActivity(aactivityIndicator)

            })
            .trackActivity(aactivityIndicator)
        .shareReplay(1)
        loginIMReuquest.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            UserDefaults.standard.set(UserModel.shared.nickName.value, forKey: "userName")
            UserDefaults.standard.set(self.tf_phone.text!, forKey: "userPhone")
            UserDefaults.standard.set(self.tf_pwd.text!, forKey: "userPwd")
            UserDefaults.standard.set(UserModel.shared.token, forKey: "userToken")
            UserDefaults.standard.set("\(UserModel.shared.id)", forKey: "userId")
            UserDefaults.standard.set("\(UserModel.shared.headPortUrl.value)", forKey: "userPortraitUri")
            //
            UserDefaults.standard.synchronize()
   
            
            RCDRCIMDataSource.shareInstance().syncGroups()
            DispatchQueue.main.async {
                let userInfo = RCUserInfo()
                userInfo.name = UserModel.shared.nickName.value
                userInfo.userId = "\(UserModel.shared.id)"
                userInfo.portraitUri = UserModel.shared.headPortUrl.value
                RCIM.shared().currentUserInfo = userInfo
                //setCurrentUserInfo
                RCIMClient.shared().currentUserInfo = userInfo
                RCDLive.shared().currentUserInfo = userInfo
                DBTool.shared.saveUserModel()
                let mainVC =  UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()  as! TabBarController
                UIApplication.shared.keyWindow?.rootViewController = mainVC
            }
 
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
      

        Observable.of(loginIMReuquest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
            .merge()
            .subscribe(onNext: { (error) in
                Drop.down(error)
//                MBProgressHUD.hide(for: self.view, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }
    
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {

        if status == .ConnectionStatus_Connected {
              RCIM.shared().connectionStatusDelegate = UIApplication.shared.delegate as! RCIMConnectionStatusDelegate
            
            if let userPhone = UserDefaults.standard.value(forKey: "userPhone") as? String , let userPwd = UserDefaults.standard.value(forKey: "userPwd") as? String{
                
                let request =  RequestProvider.request(api: ParametersAPI.userLogin(phone: userPhone, password: userPwd.md5())).mapObject(type: UserModel.self)
                    .shareReplay(1)
                request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                .subscribe(onNext: { (userModel) in
                    UserModel.shared = userModel
                    DBTool.shared.saveUserModel()
                    let mainVC =  UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()  as! TabBarController
                    UIApplication.shared.keyWindow?.rootViewController = mainVC
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            }
            
        }else if status == .ConnectionStatus_NETWORK_UNAVAILABLE{
           Drop.down("当前网络不可用，请检查网络连接！", state: .error)
        }else if status == .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT{
            Drop.down("您的帐号在别的设备上登录，您被迫下线！", state: .error)
        }else if status == .ConnectionStatus_TOKEN_INCORRECT{
            Drop.down("无法连接到服务器！", state: .error)
        }
    }
    ///登录融云IM
    fileprivate func loginIM(token:String) -> Observable<Result<String>>{
        return Observable.create({ (observer) -> Disposable in
            RCIM.shared().connect(withToken: token, success: { (userName) in
                observer.onNext(Result.success("登录成功！"))
                observer.onCompleted()
            }, error: { (code) in
                observer.onNext(Result.failure(NSError(domain: "登录失败！", code: 1, userInfo: nil)))
                RCIM.shared().connectionStatusDelegate = self
                observer.onCompleted()
            }) {
                UserDefaults.standard.set(nil, forKey: "userToken")
                observer.onNext(Result.failure(NSError(domain: "Token已过期，请重新登录！", code: 1, userInfo: nil)))
                observer.onCompleted()
            }
            return Disposables.create()
})
  

    }
}
extension LoginViewController{
    func  bindRx()  {
        rx.sentMessage(#selector(UIViewController.touchesBegan(_:with:))).subscribe(onNext: { (_) in
            self.view.endEditing(true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)

    }
    func initChildViews()  {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenW, height: 64))
        navBar.rc_setBackgroundColor(UIColor.white.withAlphaComponent(0))
        
        let navigationItem =  UINavigationItem(title: NSLocalizedString("LoginTitle", comment: ""))
        navBar.items = [navigationItem]
        view.addSubview(navBar)
    }
    
}
extension LoginViewController:RCAnimatedImagesViewDelegate{
    func animatedImagesNumber(ofImages animatedImagesView: RCAnimatedImagesView!) -> UInt {
        return 2
    }
    func animatedImagesView(_ animatedImagesView: RCAnimatedImagesView!, imageAt index: UInt) -> UIImage! {
        return UIImage(named: "bg_login")
    }
}

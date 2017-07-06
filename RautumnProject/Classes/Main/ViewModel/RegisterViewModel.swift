
//
//  RegisterViewModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/3.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyDrop
import NSObject_Rx
struct RegisterViewModel {
    let disposeBag = DisposeBag()

    //下一步按钮是否可用
    let nextStopBtnEnable:Observable<Bool>
    let getVerificationCodeSuccess:Observable<String?>
    let getVerificationCodeBtnEnable:Observable<Bool>
    
    let checkingVerificationCode:Observable<Bool>
    let getingVerificationCode:Observable<Bool>
//    let checkVerificationCodeSuccess:Observable<Bool>
    
    init(input:(phone:Observable<String?>,code:Observable<String?>,password:Observable<String?>,getVerificationCodeAction:Observable<Void>,checkVerificationCodeAction:Observable<Void>)) {
        
        //正在验证验证码
        let checkVerificationCodeActivityIndicator =  ActivityIndicator()
        checkingVerificationCode = checkVerificationCodeActivityIndicator.asObservable()

        //正在获取验证码
        let getingVerificationCodeActivityIndicator =  ActivityIndicator()
        getingVerificationCode = getingVerificationCodeActivityIndicator.asObservable()
        
        //下一步按钮是否可用
      nextStopBtnEnable =   Observable.combineLatest(input.phone,input.password,input.code,checkingVerificationCode) { (phone,pwd,code,checkingVerificationCode) -> Bool in
            return phone!.isMobileNumber() && pwd!.isPassWord() && code!.isPassWord() && !checkingVerificationCode
            }
        
        //验证码按钮是否可用
        getVerificationCodeBtnEnable = input.phone.unwrap().map{$0.isMobileNumber()}
        //获取验证码
    let   getVerificationCodeRequest =  input.getVerificationCodeAction
        .withLatestFrom(input.phone)
        .unwrap()
        .flatMap{ RequestProvider.request(api: ParametersAPI.getVerificationCode(phone: $0, type: 1)).mapObject(type: VerificationCode.self)
        .trackActivity(getingVerificationCodeActivityIndicator)
        }
        .shareReplay(1)
        
        getVerificationCodeSuccess = getVerificationCodeRequest.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().map{$0.verificationCode!}
        
        getVerificationCodeRequest.flatMap{$0.error}.map{$0.domain}
        .subscribe { (error) in
            Drop.down(error, state: .error)
        
        }
            .addDisposableTo(disposeBag)
        
        //下一步按钮时间
//     let checkVerificationCodeRequest =   input.checkVerificationCodeAction
//        .withLatestFrom(Observable.combineLatest(input.phone, input.code){($0,$1)})
//        .flatMap{
//            RequestProvider.request(api: ParametersAPI.registerVerificationVCode(userPhone: $0.0!, vcode: $0.1!)).mapObject(type: EmptyModel.self)
//            .trackActivity(checkVerificationCodeActivityIndicator)
//        }
//        .shareReplay(1)
//
//        checkVerificationCodeSuccess = checkVerificationCodeRequest.flatMap{$0.unwarp()}.map{_ in true}
//        
//        checkVerificationCodeRequest.flatMap{$0.error}.map{$0.domain}
//        .subscribe { (error) in
//                UIApplication.shared.keyWindow?.makeToast(error)
//            }
//        .addDisposableTo(disposeBag)
    
        

    }
}

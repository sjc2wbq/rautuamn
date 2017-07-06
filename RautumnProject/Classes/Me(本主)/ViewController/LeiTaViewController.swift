//
//  LeiTaViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import RxSwift
import MBProgressHUD
import UIKit
import SwiftyDrop
class LeiTaViewController: UIViewController {
    @IBOutlet weak var tf: UITextField!
   public var userId = 0
    var isGroup = false
    var sendMessage = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(LeiTaViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "发送")
            let count = tf.rx.text.map{$0!.characters.count}.shareReplay(1)
            count.map{$0 > 0  && $0 <= 20}.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)
            
            
            do{
                let activityIndicator = ActivityIndicator()
                activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在发送入群请求...", for: view)).addDisposableTo(rx_disposeBag)
                
                if isGroup {
                    
                    let request =  self.navigationItem.rightBarButtonItem!.rx.tap
                        .do(onNext: {[unowned self ] _ in
                            self.tf.endEditing(true)
                        })
                        .flatMap{ _ in RequestProvider.request(api: ParametersAPI.applyJoinGroup( beAddGroupId: self.userId, msg: self.sendMessage+":--"+self.tf.text!)).mapObject(type: EmptyModel.self)
                            .trackActivity(activityIndicator)}
                        .shareReplay(1)
                        
                        
                        .shareReplay(1)
                    
                    request.flatMap{$0.unwarp()}.subscribe(onNext: {[unowned self] (_) in
                        let av = UIAlertController(title: "温馨提示", message: "加群请求已发出！", preferredStyle: .alert)
                        av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                            _ = self.navigationController?.popViewController(animated: true)
                            
                        }))
                        self.present(av, animated: true, completion: nil)
                        
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(rx_disposeBag)
                    
                    
                    
                    request.flatMap{$0.error}.map{$0.domain}.subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(rx_disposeBag)
                    
                } else {
                    let request =  self.navigationItem.rightBarButtonItem!.rx.tap
                        .do(onNext: {[unowned self ] _ in
                            self.tf.endEditing(true)
                        })
                        .flatMap{ _ in RequestProvider.request(api: ParametersAPI.establishFriendRelationship(beAddedUserInfoId: self.userId,msg:self.tf.text!)).mapObject(type: EmptyModel.self)
                            .trackActivity(activityIndicator)}
                        .shareReplay(1)
                        
                        
                        .shareReplay(1)
                    
                    request.flatMap{$0.unwarp()}.subscribe(onNext: {[unowned self] (_) in
                        let av = UIAlertController(title: "温馨提示", message: "加好友请求已发出！", preferredStyle: .alert)
                        av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                            _ = self.navigationController?.popViewController(animated: true)
                            
                        }))
                        self.present(av, animated: true, completion: nil)
                        
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(rx_disposeBag)
                    
                    
                    
                    request.flatMap{$0.error}.map{$0.domain}.subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(rx_disposeBag)
                }
                
            }
            
        }
    }
    
    func applyJionGroup() {
        
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在发送群组请求...", for: view)).addDisposableTo(rx_disposeBag)
        
        let request = RequestProvider.request(api: ParametersAPI.applyJoinGroup( beAddGroupId: self.userId, msg: sendMessage))
            .mapObject(type: EmptyModel.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        request.flatMap{($0.unwarp())}
            .subscribe(onNext: { (_) in
                let av = UIAlertController(title: "温馨提示", message: "加群请求已发出！", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                    _ = self.navigationController?.popViewController(animated: true)
                }))
                self.present(av, animated: true, completion: nil)
            }).addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error ) in
                Drop.down(error, state: .error)
            })
            .addDisposableTo(rx_disposeBag)
    }
}

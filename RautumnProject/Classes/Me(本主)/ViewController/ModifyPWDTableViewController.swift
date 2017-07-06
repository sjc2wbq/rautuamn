
//
//  ModifyPWDTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
class ModifyPWDTableViewController: UITableViewController {
    @IBOutlet weak var tf_oldPwd: UITextField!
    @IBOutlet weak var tf_newPwd: UITextField!
    @IBOutlet weak var tf_reNewPwd: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = bgColor
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

    }
    
    @IBAction func done(_ sender: Any) {
        self.view.endEditing(true)
        guard let oldPwd = tf_oldPwd.text else {
            Drop.down("请输入原密码！", state: .error)
            return
        }
        
        if oldPwd.characters.count == 0 {
            Drop.down("请输入原密码！", state: .error)
            return
        }
        if oldPwd.containSpecialCharacters() {
            Drop.down("旧密码为6~20位英文字母和数字,不能包含特殊字符！", state: .error)
            return
        }
        if !oldPwd.isPassWord(){
            Drop.down("密码格式错误(6~20位英文字母和数字)！", state: .error)
            return

        }
        guard let newPwd = tf_newPwd.text else {
            Drop.down("请输入新密码！", state: .error)
            return
        }
        
        if newPwd.characters.count == 0 {
            Drop.down("请输入新密码！", state: .error)
            return
        }
        if newPwd.containSpecialCharacters() {
            Drop.down("新密码为6~20位英文字母和数字,不能包含特殊字符！", state: .error)
            return
        }
        if !newPwd.isPassWord(){
            Drop.down("密码格式错误(6~20位英文字母和数字)！", state: .error)
            return
        }
        
        
        guard let reNewPwd = tf_reNewPwd.text else {
            Drop.down("请再次输入新密码！", state: .error)
            return
        }
        
        if reNewPwd.characters.count == 0 {
            Drop.down("请再次输入新密码！", state: .error)
            return
        }
        if newPwd != reNewPwd{
            Drop.down("两次输入的新密码不一致，请重新输入！", state: .error)
            return
        }
        
        
     let request =   RequestProvider.request(api: ParametersAPI.modifyPassword(oldPwd: oldPwd, newPwd: newPwd)).mapObject(type: EmptyModel.self)
        .shareReplay(1)
        request.flatMap{$0.unwarp()}
        .subscribe(onNext: { (_) in
            _ = self.navigationController?.popViewController(animated: true)
            Drop.down("修改密码成功！", state: .success)
            UserDefaults.standard.removeObject(forKey: "userPwd")
        _ = self.navigationController?.popViewController(animated: true)
//            let mainVC =  UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()  as! TabBarController
//            UIApplication.shared.keyWindow?.rootViewController = mainVC
        }, onError: nil, onCompleted: nil , onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}
            .map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil , onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
}

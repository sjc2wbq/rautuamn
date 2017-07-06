//
//  MyWalletHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class MyWalletHeaderView: UIView {

    @IBOutlet weak var h: NSLayoutConstraint!
    @IBOutlet weak var lb_gold: UILabel!
    static func headerView() -> MyWalletHeaderView{
        return Bundle.main.loadNibNamed("MyWalletHeaderView", owner: nil, options: nil)![0] as! MyWalletHeaderView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserModel.shared.inApp {
          h.constant = 0
        }else{
            h.constant = 50
        }
        
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: 0, y: bounds.size.height - 10, width: screenW, height: 10)
        lineLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(lineLayer)
        UserModel.shared.rautumnCurrency.asObservable().map{"\($0)"}.bindTo(lb_gold.rx.text).addDisposableTo(rx_disposeBag)
    }
    @IBAction func withdrawalAction(_ sender: Any) {
        if UserModel.shared.licenseStatus != 3 {
            let vc = UIAlertController(title: "温馨提示", message: "您的身份必须验证通过(上传身份证并审核通过)后才可提现，是否现在去验证？", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            vc.addAction(UIAlertAction(title: "去验证", style: .default, handler: {[unowned self] _ in
                let vc = Register2ViewController()
                vc.editUserInfo = true
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
            }))
            self.viewController?.present(vc, animated: true, completion: nil)
            return
        }
        let vc = WithdrawViewController()
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func loanAction(_ sender: Any) {
        let vc = UIViewController()
        vc.title = "镭秋贷"
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

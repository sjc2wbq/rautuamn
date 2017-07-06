//
//  OpeningMemberRankTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class OpeningMemberRankTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_title: UILabel!//1个月会员费用：￥12
    @IBOutlet weak var lb_subTitle: UILabel!//2017年8月31日前优惠季
    @IBOutlet weak var btn_price: UIButton!//￥8

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var vipsetting:Vipsetting!{
        didSet{
            
            lb_title.text = "\(vipsetting.month)个月会员费用：￥\(vipsetting.price)"
            lb_subTitle.text = "\(vipsetting.discountEndDate)前优惠季"
            
            let dateF = DateFormatter()
            dateF.dateFormat = "YYYY年MM月dd日"
            let timeInterval = dateF.date(from: vipsetting.discountEndDate)!.timeIntervalSince1970
            log.info("Date().timeIntervalSince1970 =----- \(Date().timeIntervalSince1970) --- timeInterval === \(timeInterval)")
            if Date().timeIntervalSince1970 >= timeInterval{
            btn_price.setTitle(String(format:"￥%.2f",vipsetting.price), for: .normal)
            }else{
            btn_price.setTitle(String(format:"￥%.2f",vipsetting.price - vipsetting.preferentialQuota), for: .normal)
            }

    
            vipsetting.selected.asObservable().subscribe(onNext: { (selected) in
                if  selected{
                    self.contentView.backgroundColor = UIColor.colorWithHexString("#E4F8FF")
                }else{
                    self.contentView.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                }
            }, onError: nil , onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
        }
    }

}

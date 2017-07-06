//
//  MyWalletViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class MyWalletViewCell: UITableViewCell {
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_price: UILabel!
    
    @IBOutlet weak var lb_imageView: UIImageView!

    @IBOutlet weak var lb_titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    var wallet : Wallet!{
        didSet{
            lb_time.text = wallet.date
            lb_price.text = wallet.countRautumnCurrency
            lb_titleLabel.text = wallet.typeName
            
            if wallet.typeName == "我打赏" {
                lb_imageView.image = UIImage.init(named: "wodashang")
            } else if (wallet.typeName == "打赏我") {
                lb_imageView.image = UIImage.init(named: "dahsangwo")
            } else if (wallet.typeName == "充值") {
                lb_imageView.image = UIImage.init(named: "chongzhi")
            } else {
                lb_imageView.image = UIImage.init(named: "tixian")
            }
            
        }
    }
}

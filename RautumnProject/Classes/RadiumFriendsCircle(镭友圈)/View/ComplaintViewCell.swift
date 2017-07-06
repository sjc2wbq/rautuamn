//
//  ComplaintViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
class ComplaintViewCell: UITableViewCell {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var model : ComplaintModel!{
        didSet{
           lb_title.text = model.title
            model.check.asObservable().subscribe(onNext: {[unowned self] (check) in
                self.img.image = UIImage(named:check == true ? "shippingAdress_check" : "shippingAdress_unCheck")
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
        }
    }
    
}

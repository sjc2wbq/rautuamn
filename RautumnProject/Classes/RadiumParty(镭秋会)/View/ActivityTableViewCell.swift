
//
//  MyActivityTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDWebImage
class ActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_tag: AnimatableLabel!
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var btn_time: UIButton!
    @IBOutlet weak var lb_address: UILabel!
    @IBOutlet weak var btn_price: UIButton!
    @IBOutlet weak var lb_distance: UILabel!

    @IBOutlet weak var lb_tag_w: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var rauactivitie:Rauactivitie!{
        didSet{
            img_iocn.sd_setImage(with: URL(string:rauactivitie.coverPhotoUrl))
            lb_name.text = rauactivitie.name
            btn_time.setTitle(rauactivitie.activityDateTime, for: .normal)
            lb_address.text = rauactivitie.place
            btn_price.setTitle("￥\(rauactivitie.expense)", for: .normal)
            lb_distance.text = "\(rauactivitie.distance)km"
            lb_tag.text = rauactivitie.label
            lb_tag_w.constant = lb_tag.text!.width(14, height: 21) + 15
        }
    }
}

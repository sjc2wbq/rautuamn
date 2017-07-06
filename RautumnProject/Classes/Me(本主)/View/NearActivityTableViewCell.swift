//
//  NearActivityTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable

class NearActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var btn_time: UIButton!
    @IBOutlet weak var lb_address: UILabel!
    @IBOutlet weak var btn_price: UIButton!
    @IBOutlet weak var lb_distance: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

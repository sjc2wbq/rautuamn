//
//  MyGroupTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDWebImage
class MyGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_personCount: UILabel!

    @IBOutlet weak var btn_jiesao: UIButton!
    @IBOutlet weak var btn_edit: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var raugroup:Raugroup!{
        didSet{
            img_iocn.sd_setImage(with: URL(string:raugroup.coverPhotoUrl), placeholderImage: placeHolderImage)
            lb_name.text = raugroup.name
            lb_personCount.text = "\(raugroup.rguCount)人"
        }
    }
}

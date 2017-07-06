//
//  NearActivityHeaderCollectionViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/4.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class NearActivityHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lb_tag: AnimatableLabel!
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var rauActivityEnroll:RauActivityEnroll!{
        didSet{
        img_icon.sd_setImage(with: URL(string:rauActivityEnroll.headPortUrl), placeholderImage: placeHolderImage)
        lb_title.text = rauActivityEnroll?.nickName
        }
    }
}

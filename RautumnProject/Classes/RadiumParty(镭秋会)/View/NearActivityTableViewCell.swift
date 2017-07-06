//
//  NearActivityTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
class NearActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var lb_subTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
      _ =  lb_title.sd_layout().leftSpaceToView(contentView,10)?.topSpaceToView(contentView,10)?.heightIs(15)?.widthIs(200)
        _ =  lb_subTitle.sd_layout().leftSpaceToView(contentView,10)?.topSpaceToView(lb_title,10)?.rightSpaceToView(contentView,10)?.autoHeightRatio(0)
        setupAutoHeight(withBottomView: lb_subTitle, bottomMargin: 10)

    }
    
}

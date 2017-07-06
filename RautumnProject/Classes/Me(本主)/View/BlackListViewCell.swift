//
//  BlackListViewCell.swift
//  ObjectsProject
//
//  Created by Raychen on 2016/10/20.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import SDWebImage
class BlackListViewCell: UITableViewCell {
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var model:BlackList!{
        didSet{
            
            img_icon.sd_setImage(with: URL(string:model.headPortrait), placeholderImage: placeHolderImage)

            lb_name.text = model.nickName
            lb_time.text = "拉黑时间：\(model.date)"
        }
    }
    
}

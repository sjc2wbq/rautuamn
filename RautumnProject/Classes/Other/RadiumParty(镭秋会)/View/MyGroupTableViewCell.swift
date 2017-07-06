//
//  MyGroupTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class MyGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_personCount: UILabel!

    @IBOutlet weak var btn_jiesao: UIButton!
    @IBOutlet weak var btn_edit: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

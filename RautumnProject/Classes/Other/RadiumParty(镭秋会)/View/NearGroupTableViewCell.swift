//
//  NearGroupTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/21.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class NearGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_groupCount: AnimatableLabel!
    @IBOutlet weak var btn_distane: UIButton!
    @IBOutlet weak var btn_chat: AnimatableButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

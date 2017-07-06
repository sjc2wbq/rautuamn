//
//  NearOpinionPollsTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class NearOpinionPollsTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_name_W: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var raufricivilmediation:Raufricivilmediation!{
        didSet{
        lb_name.text = raufricivilmediation.title
            lb_time.text = "截止\(raufricivilmediation.closingDateTime)"
            lb_name_W.constant = screenW - lb_time.text!.width(12, height: 21) - 30
        }
    }
}

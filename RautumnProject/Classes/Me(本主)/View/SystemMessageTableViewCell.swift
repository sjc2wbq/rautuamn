//
//  SystemMessageTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class SystemMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var sysTemMessage : SystemMessage!{
        didSet{
            lb_time.text = sysTemMessage.time
            if sysTemMessage.title == ""{
                lb_message.text = sysTemMessage.message
            }else{
                lb_message.text = sysTemMessage.title
            }
        }
    }
}

//
//  UserOtherInfoViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
class UserOtherInfoViewCell: UITableViewCell {

    @IBOutlet weak var lb_messageDesc: UILabel!
    @IBOutlet weak var lb_message: UILabel!
    @IBOutlet weak var lb_mottoDesc: UILabel!
    @IBOutlet weak var lb_motto: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
            selectionStyle = .none
       _ =  lb_motto.sd_layout().leftSpaceToView(contentView,8)?.topSpaceToView(contentView,15)?.heightIs(20)
        
        _ =  lb_mottoDesc.sd_layout().leftEqualToView(lb_motto)?.topSpaceToView(lb_motto,10)?.autoHeightRatio(0)?.rightSpaceToView(contentView,8)

        _ =  lb_message.sd_layout().leftEqualToView(lb_mottoDesc)?.topSpaceToView(lb_mottoDesc,20)?.heightIs(20)

        _ =  lb_messageDesc.sd_layout().leftEqualToView(lb_message)?.topSpaceToView(lb_message,10)?.autoHeightRatio(0)?.rightSpaceToView(contentView,8)

            setupAutoHeight(withBottomView: lb_messageDesc, bottomMargin: 15)
    }
    var userModel : UserModel!{
        didSet{
            lb_message.text = "擅长的技能"
            lb_mottoDesc.text = userModel.motto
            lb_messageDesc.text = userModel.autograph.characters.count == 0 ? "无" : userModel.autograph
        }
    }
    var model:FriendInfoModel?{
        didSet{
            guard let model = model else {
                return
            }
           lb_mottoDesc.text = model.motto
            if model.autograph == "" {
                lb_message.isHidden = true
                lb_messageDesc.isHidden = true
              _ = lb_message.sd_layout().heightIs(0)
                _ = lb_messageDesc.sd_layout().heightIs(0)
                setupAutoHeight(withBottomView: lb_message, bottomMargin: 10)
            }else{
                lb_message.text = "擅长的技能"
                _ = lb_message.sd_layout().heightIs(20)
                _ = lb_messageDesc.sd_layout().autoHeightRatio(0)
                lb_message.isHidden = false
                lb_messageDesc.isHidden = false
                lb_messageDesc.text = model.autograph
                setupAutoHeight(withBottomView: lb_messageDesc, bottomMargin: 10)

            }
        }
    }
    
}

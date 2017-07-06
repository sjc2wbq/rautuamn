//
//  RadiumFriendsCircleDetailViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDAutoLayout
import SDWebImage
class RadiumFriendsCircleDetailViewCell: UITableViewCell {
    @IBOutlet weak var img_icon: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_content: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        _  = img_icon.sd_layout().leftSpaceToView(contentView,15)?.topSpaceToView(contentView,20)?.widthIs(40)?.heightIs(40)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_icon,5)?.heightIs(20)?.topEqualToView(img_icon)
        
        _ = lb_time.sd_layout().rightSpaceToView(contentView,15)?.heightIs(15)?.centerYEqualToView(lb_name)?.widthIs(200)
        
        _ = lb_content.sd_layout().leftEqualToView(lb_name)?.topSpaceToView(lb_name,10)?.rightEqualToView(lb_time)?.autoHeightRatio(0)
        
        setupAutoHeight(withBottomView: lb_content, bottomMargin: 20)
        

        
          }
 
    var model:Rautumnfriendscirclecom!{
        didSet{
            img_icon.sd_setImage(with: URL(string:model.headPortUrl), placeholderImage: defaultHeaderImage)
          lb_name.text = model.userName
            lb_time.text = model.dateTimeStr
            lb_content.text = model.content
        }
    }
    var rauVideoUsefulCom : Rautumnfriendscirclecom!{
        didSet{
            img_icon.sd_setImage(with: URL(string:rauVideoUsefulCom.headPortUrl), placeholderImage: defaultHeaderImage)
            lb_name.text = rauVideoUsefulCom.userName
            lb_time.text = rauVideoUsefulCom.dateTimeStr
            lb_content.text = rauVideoUsefulCom.content

        
        }
    }
//    
//    var audionModel:Rautumnfriendscirclecom! {
//        didSet{
//            img_icon.sd_setImage(with: URL(string:rauVideoUsefulCom.headPortUrl), placeholderImage: defaultHeaderImage)
//            lb_name.text = rauVideoUsefulCom.userName
//            lb_time.text = rauVideoUsefulCom.dateTimeStr
//            lb_content.text = rauVideoUsefulCom.content
//            
//            
//        }
//    }
    
}

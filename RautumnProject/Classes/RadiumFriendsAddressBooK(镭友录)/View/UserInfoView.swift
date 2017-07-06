//
//  UserInfoView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/16.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import SDWebImage
import IBAnimatable
class UserInfoView: UIView {

    @IBOutlet weak var img_icon: AnimatableImageView!
    @IBOutlet weak var img_rank: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_huzhu: UILabel!
    @IBOutlet weak var starView: StarView!
    @IBOutlet weak var lb_tag1: AnimatableLabel!
    @IBOutlet weak var lb_tag2: AnimatableLabel!
    @IBOutlet weak var btn_city: UIButton!
    @IBOutlet weak var btn_distance: UIButton!
    static func userInfoView() -> UserInfoView{
        return Bundle.main.loadNibNamed("UserInfoView", owner: nil, options: nil)![0] as! UserInfoView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        print("UIScreen.main.bounds.size.width  === \(UIScreen.main.bounds.size.width)")
        _ = img_icon.sd_layout().leftSpaceToView(self,10)?.topSpaceToView(self,10)?.widthIs(50)?.heightIs(50)
        
            img_icon.sd_cornerRadiusFromWidthRatio = NSNumber(value: Float(0.5))
        
        _ = img_rank.sd_layout().rightEqualToView(img_icon)?.bottomEqualToView(img_icon)?.widthIs(13)?.heightIs(13)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_icon,5)?.heightIs(15)?.topSpaceToView(self,10)
        
        _ = starView.sd_layout().leftSpaceToView(lb_name,0)?.heightIs(20)?.centerYEqualToView(lb_name)

        if UIScreen.main.bounds.size.width == 320.0 {
            _ = lb_tag1.sd_layout().leftEqualToView(lb_name)?.widthIs(20)?.heightIs(12)?.topSpaceToView(lb_name,2)
        }else{
            _ = lb_tag1.sd_layout().leftSpaceToView(starView,4)?.widthIs(20)?.heightIs(12)?.centerYEqualToView(starView)
        }
        
        _ = lb_tag2.sd_layout().leftSpaceToView(lb_tag1,2)?.widthIs(20)?.heightIs(12)?.centerYEqualToView(lb_tag1)
        
        _ = lb_huzhu.sd_layout().leftSpaceToView(lb_tag2,2)?.widthIs(20)?.heightIs((12))?.centerYEqualToView(lb_tag2)
        
        _ = btn_city.sd_layout().leftEqualToView(lb_name)?.widthIs(70)?.heightIs(20)?.bottomEqualToView(img_icon)
        
        _ = btn_distance.sd_layout().leftSpaceToView(btn_city,10)?.heightIs(20)?.widthIs(70)?.centerYEqualToView(btn_city)
        
        setupAutoHeight(withBottomView: btn_distance, bottomMargin: 10)
        
        let userModel = UserModel.shared
        
        starView.star = userModel.starLevel
        img_icon.sd_setImage(with: URL(string:userModel.headPortUrl.value), placeholderImage: defaultHeaderImage)
        
        img_rank.image = UIImage(named:"isCertification_\(userModel.rank.value)")
        
        lb_name.text = userModel.nickName.value
        
        lb_huzhu.isHidden = !userModel.mutualTourism
        
        lb_tag1.backgroundColor = UIColor.colorWithHexString(userModel.emotion == "找女友" ? "#84E941" : "#FD6BA7")
        
        if userModel.emotion == "找女友"{
            lb_tag1.text = "FG"
            lb_tag1.isHidden = false
            _ = lb_tag1.sd_layout().widthIs(24)
        }else if userModel.emotion == "找男友" {
            lb_tag1.text = "FB"
            lb_tag1.isHidden = false
            _ = lb_tag1.sd_layout().widthIs(24)
        }else{
            lb_tag1.isHidden = true
            _ = lb_tag1.sd_layout().widthIs(0)
        }

        if userModel.changeJob {
            lb_tag2.isHidden = false
            _ = lb_tag2.sd_layout().widthIs(24)
        }else{
            lb_tag2.isHidden = true
            _ = lb_tag2.sd_layout().widthIs(0)
        }
        if userModel.distanceOff{
            btn_distance.setTitle("关闭距离", for: .normal)
        }else{
            btn_distance.setTitle("开启距离", for: .normal)
        }
        btn_city.setTitle(userModel.permanentCity, for: .normal)

        _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(13, height: 20) + 5)

        if let text = btn_city.titleLabel?.text{
            _ = btn_city.sd_layout().widthIs(text.width(12, height: 20) + 20)
        }

    }

}

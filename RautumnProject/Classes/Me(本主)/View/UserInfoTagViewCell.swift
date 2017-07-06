
//
//  UserInfoTagViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class UserInfoTagViewCell: UITableViewCell {
    @IBOutlet weak var lb_tag1: UILabel!
    @IBOutlet weak var lb_tag2: UILabel!
    @IBOutlet weak var lb_huzhu: UILabel!
    @IBOutlet weak var tagView: MKTagView!
    @IBOutlet weak var lb_wW: NSLayoutConstraint!
    @IBOutlet weak var lb_tag1_w: NSLayoutConstraint!
    @IBOutlet weak var lb_tag2_w: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        tagView.tagTextPadding = UIEdgeInsetsMake(20, 10, 20, 10)
        
    }
    
    var userModel : UserModel!{
        didSet{
            
            lb_tag1.backgroundColor = UIColor.colorWithHexString(userModel.emotion == "找女友" ? "#84E941" : "#FD6BA7")
            if userModel.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                lb_tag1_w.constant = 27
            }else if userModel.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                lb_tag1_w.constant = 27
                
            }else{
                lb_tag1_w.constant = 0
                lb_tag1.isHidden = true
            }
            lb_tag2.isHidden = !userModel.changeJob
            lb_tag2_w.constant = userModel.changeJob == true ? 27 : 0
            lb_huzhu.isHidden = !userModel.mutualTourism
            let tags = userModel.hobby.components(separatedBy: ",") + userModel.vocationalCertificate.components(separatedBy: ",") + userModel.language.components(separatedBy: ",")
            tagView.removeAllTag()
            tagView.addTags(tags + [userModel.constellation,userModel.occupation])
//            self.bounds = 
            
        }
    }
    var model:FriendInfoModel?{
        didSet{
            guard let model = model else {
                return
            }
            if model.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                lb_tag1_w.constant = 27
            }else if model.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                lb_tag1_w.constant = 27

            }else{
                lb_tag1_w.constant = 0
                lb_tag1.isHidden = true
            }
            lb_tag2.isHidden = !model.changeJob
            lb_tag2_w.constant = model.changeJob == true ? 27 : 0
            lb_huzhu.isHidden = !model.mutualTourism
            tagView.removeAllTag()
            let tags = model.hobby.components(separatedBy: ",") + model.vocationalCertificate.components(separatedBy: ",") + model.language.components(separatedBy: ",")
            
            tagView.addTags(tags + [model.constellation,model.occupation])

        }
    }
    
}

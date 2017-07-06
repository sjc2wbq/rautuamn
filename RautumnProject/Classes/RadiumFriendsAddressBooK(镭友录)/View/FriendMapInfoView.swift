//
//  FriendMapInfoView.swift
//  RautumnProject
//
//  Created by Kun Huang on 2017/5/24.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import Masonry
import SDWebImage

class FriendMapInfoView: UIView {

    public var cancelClickedBlock:(() -> Void)?
    public var sendClickedBlock:(() -> Void)?
    
    @IBOutlet weak var headImageView: AnimatableImageView!
    
    
    @IBOutlet weak var nameLabelLayout: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel! // 名字
    

    @IBOutlet weak var lb_tag1: AnimatableLabel!
    @IBOutlet weak var lb_tag2: AnimatableLabel!
    @IBOutlet weak var lb_tag3: AnimatableLabel!
    
    
    @IBOutlet weak var address: UIButton! // 地址
    @IBOutlet weak var distance: UIButton! // 距离
    @IBOutlet weak var intimacy: UILabel! // 亲密度
    @IBOutlet weak var skillLabel: UILabel! // 技能

    
    static func infoView() -> FriendMapInfoView{
        return Bundle.main.loadNibNamed("FriendMapInfoView", owner: nil, options: nil)!.first as! FriendMapInfoView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headImageView.layer.cornerRadius = 45.0
        headImageView.clipsToBounds = true
        
    }
    
    
    var info: Friend! {
        didSet {
            
            headImageView.sd_setImage(with: URL.init(string: info.headPortUrl))
            nameLabel.text = info.nickName
            
            skillLabel.text = "擅长的技能：\(info.autograph)"
            intimacy.text = "亲密度：\(info.degree_of_intimacy)"
            
            log.info("autogrph = \(self.info.autograph)")
            
            if info.autograph.characters.count == 0 {
                skillLabel.isHidden = true
            } else {
                skillLabel.isHidden = false
            }
            
            lb_tag3.isHidden = !info.mutualTourism
            
            lb_tag1.backgroundColor = UIColor.colorWithHexString(info.emotion == "找女友" ? "#84E941" : "#FD6BA7")
            if info.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
//                _ = lb_tag1.sd_layout().widthIs(27)
//                FG_Left.constant = 5.0
                lb_tag1.frame = CGRect.init(x: self.bounds.width/2.0, y: nameLabel.frame.minY+2.0, width: 27.0, height: 17.0)
                
            }else if info.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
//                _ = lb_tag1.sd_layout().widthIs(27)
//                FG_Left.constant = 5.0
                lb_tag1.frame = CGRect.init(x: self.bounds.width/2.0, y: nameLabel.frame.minY+2.0, width: 27.0, height: 17.0)
            }else{
                lb_tag1.isHidden = true
//                _ = lb_tag1.sd_layout().widthIs(0)
//                FG_Left.constant = 0.0
//                W_Left.constant = 0.0
                lb_tag1.frame = CGRect.init(x: self.bounds.width/2.0, y: nameLabel.frame.minY+2.0, width: 0.0, height: 17.0)
            }
            
            if info.changeJob {
                lb_tag2.isHidden = false
//                _ = lb_tag2.sd_layout().widthIs(27)
//                W_Left.constant = 7.0
                lb_tag2.frame = CGRect(x: lb_tag1.frame.maxX+5.0, y: lb_tag1.frame.minY, width: 27.0, height: 17.0)
                
            }else{
                lb_tag2.isHidden = true
//                W_Left.constant = 0.0
//                _ = lb_tag2.sd_layout().widthIs(0)
                lb_tag2.frame = CGRect(x: lb_tag1.frame.maxX, y: lb_tag1.frame.minY, width: 0.0, height: 17.0)

            }
            
            lb_tag3.frame = CGRect(x: lb_tag2.frame.maxX+5.0, y: lb_tag1.frame.minY, width: 27.0, height: 17.0)
            
            if info.distanceOff{
                distance.setTitle("关闭距离", for: .normal)
            }else{
                distance.setTitle("\(info.distance)km", for: .normal)
            }
            
            address.setTitle(info.permanentCity, for: .normal)
            //            btn_lei.setTitle(friend.isFriends == true ? "发消息" : "镭Ta", for: .normal)
//            _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(15, height: 20 + 5))
//            if let text = btn_city.titleLabel?.text{
//                _ = btn_city.sd_layout().widthIs(text.width(15, height: 20) + 20)
//            }
            if lb_tag1.isHidden && lb_tag2.isHidden && lb_tag3.isHidden {
                nameLabelLayout.constant = -300.0/2.0+15.0
                nameLabel.textAlignment = .center
            }
            
            
            
        }
    }

    // 取消按钮
    @IBAction func cancelEvent(_ sender: UIButton) {
        cancelClickedBlock?()
        
    }
    
    // 发消息
    @IBAction func sendEvent(_ sender: UIButton) {
        sendClickedBlock?()
    }
}

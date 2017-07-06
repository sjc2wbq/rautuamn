//
//  FindFriendsViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import SDWebImage
import IBAnimatable
class FindFriendsViewCell: UITableViewCell {
    @IBOutlet weak var img_icon: AnimatableImageView!
    @IBOutlet weak var img_rank: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_huzhu: UILabel!
    @IBOutlet weak var starView: StarView!
    @IBOutlet weak var lb_tag1: AnimatableLabel!
    @IBOutlet weak var lb_tag2: AnimatableLabel!
    
    @IBOutlet weak var btn_city: UIButton!
    @IBOutlet weak var btn_distance: UIButton!
    
    @IBOutlet weak var btn_lei: AnimatableButton!
    
    @IBOutlet weak var btn_check: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
      _  =  btn_check.sd_layout().leftSpaceToView(contentView,8)?.widthIs(40)?.heightIs(40)?.centerYEqualToView(contentView)

        _ =  img_icon.sd_layout().leftSpaceToView(btn_check,8)?.centerYEqualToView(btn_check)?.widthIs(50)?.heightIs(50)
    
        _ = img_rank.sd_layout().rightEqualToView(img_icon)?.bottomEqualToView(img_icon)?.widthIs(16)?.heightIs(16)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_icon,5)?.heightIs(20)?.topSpaceToView(self.contentView,10)
        
        _ = starView.sd_layout().leftSpaceToView(lb_name,2)?.heightIs(20)?.centerYEqualToView(lb_name)
        
        _ = lb_tag1.sd_layout().leftSpaceToView(starView,5)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(starView)
        
        _ = lb_tag2.sd_layout().leftSpaceToView(lb_tag1,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag1)
        
        _ = lb_huzhu.sd_layout().leftSpaceToView(lb_tag2,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag2)
        
        _ = btn_city.sd_layout().leftEqualToView(lb_name)?.widthIs(100)?.heightIs(20)?.bottomEqualToView(img_icon)
        
        _ = btn_distance.sd_layout().leftSpaceToView(btn_city,10)?.heightIs(20)?.widthIs(100)?.centerYEqualToView(btn_city)
        
        _ = btn_lei.sd_layout().rightSpaceToView(self.contentView,10)?.widthIs(66)?.heightIs(26)?.centerYEqualToView(btn_distance)
        
        setupAutoHeight(withBottomView: btn_lei, bottomMargin: 10)
        img_icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.img_iconAction(tap:))))

    }
    @objc fileprivate func img_iconAction(tap:UITapGestureRecognizer)  {
        let vc = UserInfoViewController()
        vc.visitorUserId = Int(self.friend.userId)
//        vc.title = self.friend.nickName
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    var friend:Friend!{
        didSet{
            
            friend.isShowCheck.asObservable().subscribe(onNext: {[unowned self] (isShowCheck) in
                _ = self.btn_check.sd_layout().widthIs(isShowCheck == true ? 40 : 0)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
            
            friend.isCheck.asObservable().bindTo(btn_check.rx.isSelected).addDisposableTo(rx_reusableDisposeBag)
            
            starView.star = friend.starLevel
            starView.isHidden = friend.starLevel == 0
            img_icon.sd_setImage(with: URL(string:friend.headPortUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(friend.rank)")
            
            lb_name.text = friend.nickName
            
            lb_huzhu.isHidden = !friend.mutualTourism
            
            btn_lei.setTitle(friend.friend == true ? "发消息" : "镭Ta", for: .normal)

            lb_tag1.backgroundColor = UIColor.colorWithHexString(friend.emotion == "找女友" ? "#84E941" : "#FD6BA7")
            if friend.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
            }else if friend.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
                
            }else{
                lb_tag1.isHidden = true
                _ = lb_tag1.sd_layout().widthIs(0)
            }
            
            if friend.changeJob {
                lb_tag2.isHidden = false
                _ = lb_tag2.sd_layout().widthIs(24)
                
            }else{
                lb_tag2.isHidden = true
                _ = lb_tag2.sd_layout().widthIs(0)
            }
            if friend.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(friend.distance)km", for: .normal)
            }
            btn_city.setTitle(friend.permanentCity, for: .normal)
            
//            btn_lei.setTitle(friend.isFriends == true ? "发消息" : "镭Ta", for: .normal)
            _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(15, height: 20 + 5))
            if let text = btn_city.titleLabel?.text{
                _ = btn_city.sd_layout().widthIs(text.width(15, height: 20) + 20)
            }
        }
    }
}

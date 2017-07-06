//
//  NearOpinionPollsDetailViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDAutoLayout
class NearOpinionPollsDetailViewCell: UITableViewCell {

    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var img_rank: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    
    @IBOutlet weak var lb_tag1: AnimatableLabel!
    @IBOutlet weak var starView: StarView!
    @IBOutlet weak var lb_tag2: AnimatableLabel!
    @IBOutlet weak var lb_huzhu: AnimatableLabel!
    
    @IBOutlet weak var btn_distance: UIButton!
    @IBOutlet weak var btn_address: UIButton!
    
    @IBOutlet weak var lb_question: UILabel!
    
    @IBOutlet weak var btn_answer1: UIButton!
    
    @IBOutlet weak var btn_answer2: UIButton!
    @IBOutlet weak var btn_answer3: UIButton!
    @IBOutlet weak var lb_endTime: UILabel!
    
    var answer = ""
    weak var btn_seleted: UIButton?
    @IBOutlet weak var btn_result: AnimatableButton!

    @IBOutlet weak var btn_resultContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        _ =  lb_title.sd_layout().leftSpaceToView(contentView,15)?.topSpaceToView(contentView,10)?.rightSpaceToView(contentView,15)?.heightIs(50)

        
        _ =  img_iocn.sd_layout().leftEqualToView(lb_title)?.topSpaceToView(lb_title,15)?.widthIs(50)?.heightIs(50)
        
        _ = img_rank.sd_layout().rightEqualToView(img_iocn)?.bottomEqualToView(img_iocn)?.widthIs(16)?.heightIs(16)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_iocn,5)?.heightIs(20)?.topEqualToView(img_iocn)
        
        _ = starView.sd_layout().leftSpaceToView(lb_name,2)?.heightIs(20)?.centerYEqualToView(lb_name)
        
        _ = lb_tag1.sd_layout().leftSpaceToView(starView,5)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(starView)
        
        _ = lb_tag2.sd_layout().leftSpaceToView(lb_tag1,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag1)
        
        _ = lb_huzhu.sd_layout().leftSpaceToView(lb_tag2,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag2)
        
        _ = btn_address.sd_layout().leftEqualToView(lb_name)?.widthIs(100)?.heightIs(20)?.bottomEqualToView(img_iocn)
        
        _ = btn_distance.sd_layout().leftSpaceToView(btn_address,10)?.heightIs(20)?.widthIs(100)?.centerYEqualToView(btn_address)

        
        _ = lb_question.sd_layout().leftEqualToView(img_iocn)?.topSpaceToView(btn_address,20)?.rightSpaceToView(contentView,15)?.autoHeightRatio(0)
    
        _ = btn_answer1.sd_layout().leftEqualToView(lb_question)?.topSpaceToView(lb_question,5)?.rightEqualToView(lb_question)?.heightIs(35)
        
        _ = btn_answer2.sd_layout().leftEqualToView(lb_question)?.topSpaceToView(btn_answer1,0)?.rightEqualToView(lb_question)?.heightIs(35)

    
        _ = btn_answer3.sd_layout().leftEqualToView(lb_question)?.topSpaceToView(btn_answer2,0)?.rightEqualToView(lb_question)?.heightIs(35)

        _ = lb_endTime.sd_layout().leftEqualToView(btn_answer3)?.topSpaceToView(btn_answer3,10)?.rightEqualToView(btn_answer3)?.heightIs(15)
        
        _ = btn_resultContentView.sd_layout().leftSpaceToView(contentView,0)?.topSpaceToView(lb_endTime,5)?.rightSpaceToView(contentView,0)?.heightIs(86)

        _ = btn_result.sd_layout().leftSpaceToView(btn_resultContentView,15)?.topSpaceToView(btn_resultContentView,18)?.rightSpaceToView(btn_resultContentView,15)?.bottomSpaceToView(btn_resultContentView,18)
   
        setupAutoHeight(withBottomView: btn_resultContentView, bottomMargin: 10)
        
    }

    var model:RfcmDetailsModel?{
        didSet{
            guard let model = model else {
                return
            }
//            if model.vote {
//                btn_answer1.isEnabled = false
//                btn_answer2.isEnabled = false
//                btn_answer3.isEnabled = false
//            }
            if model.option == "A"{
                btn_answer1.isSelected = true
                btn_answer2.isSelected = false
                btn_answer3.isSelected = false
                btn_answer1.setImage(UIImage(named: "shippingAdress_check"), for: .selected)
                btn_answer2.setImage(UIImage(named: "shippingAdress_unCheck"), for: .normal)
                btn_answer3.setImage(UIImage(named: "shippingAdress_unCheck"), for: .normal)
                btn_answer1.backgroundColor = UIColor.colorWithHexString("#E4F8FF")
                btn_answer2.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                btn_answer3.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                
            }else if model.option == "B"{
                btn_answer1.isSelected = false
                btn_answer2.isSelected = true
                btn_answer3.isSelected = false
                btn_answer1.setImage(UIImage(named: "shippingAdress_unCheck"), for: .normal)
                btn_answer2.setImage(UIImage(named: "shippingAdress_check"), for: .selected)
                btn_answer3.setImage(UIImage(named: "shippingAdress_unCheck"), for: .normal)
                btn_answer1.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                btn_answer2.backgroundColor = UIColor.colorWithHexString("#E4F8FF")
                btn_answer3.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
            
            }else if model.option == "C"{
                btn_answer1.isSelected = false
                btn_answer2.isSelected = false
                btn_answer3.isSelected = true
                btn_answer1.setImage(UIImage(named: "shippingAdress_unCheck"), for: .selected)
                btn_answer2.setImage(UIImage(named: "shippingAdress_unCheck"), for: .selected)
                btn_answer3.setImage(UIImage(named: "shippingAdress_check"), for: .selected)
                btn_answer1.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                btn_answer2.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
                btn_answer3.backgroundColor = UIColor.colorWithHexString("#E4F8FF")



            }
            answerAction(btn_answer1)
            self.model?.answer = model.optionA
            starView.star = model.starLevel
            
            img_iocn.sd_setImage(with: URL(string:model.headPortUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(model.rank)")
            
            lb_name.text = model.nickName
            
            lb_huzhu.isHidden = !model.mutualTourism
            lb_tag1.backgroundColor = UIColor.colorWithHexString(model.emotion == "找女友" ? "#84E941" : "#FD6BA7")
            if model.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
            }else if model.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
                
            }else{
                lb_tag1.isHidden = true
                _ = lb_tag1.sd_layout().widthIs(0)
            }
            if model.changeJob {
                lb_tag2.isHidden = false
                _ = lb_tag2.sd_layout().widthIs(24)
                
            }else{
                lb_tag2.isHidden = true
                _ = lb_tag2.sd_layout().widthIs(0)
            }
            if model.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(model.distance)km", for: .normal)
            }
            btn_address.setTitle(model.permanentCity, for: .normal)
            
            _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(15, height: 20) + 5)
            if let text = btn_distance.titleLabel?.text{
                _ = btn_distance.sd_layout().widthIs(text.width(15, height: 20) + 20)
            }
            lb_question.text = model.title
            
            btn_answer1.setTitle(model.optionA, for: .normal)
            btn_answer2.setTitle(model.optionB, for: .normal)
//            btn_answer3.setTitle(model.optionC, for: .normal)
            lb_endTime.text = model.closingDateTime
            btn_result.setTitle(model.vote == true ? "查看结果" : "提交并查看结果", for: .normal)
        }
    }
    @IBAction func answerAction(_ sender: UIButton) {
        guard let model = model else {
            return
        }
        if model.vote{
        return
        }
        btn_seleted?.isSelected = false
        sender.isSelected = true
        if sender.isSelected {
            sender.backgroundColor = UIColor.colorWithHexString("#E4F8FF")
            btn_seleted?.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
        }else{
            sender.backgroundColor = UIColor.colorWithHexString("#FBFBFB")
            btn_seleted?.backgroundColor = UIColor.colorWithHexString("#E4F8FF")
        }
        btn_seleted = sender
        if sender == btn_answer1{
            answer = "A"
        }else  if sender == btn_answer2{
            answer = "B"
        }else  if sender == btn_answer3{
            answer = "C"
        }
    }
    
}

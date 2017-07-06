//
//  NewFriendViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/18.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable

protocol NewFriendViewCellDelegate : NSObjectProtocol{
    func  didClickedAcceptBtn(btn:UIButton,cell:NewFriendViewCell)
}

class NewFriendViewCell: UITableViewCell {
    weak var delegate : NewFriendViewCellDelegate?
    @IBOutlet weak var img_icon: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_subName: UILabel!
    @IBOutlet weak var btn_accept: AnimatableButton!
    @IBOutlet weak var lb_accepted: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        btn_accept.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    @objc fileprivate func btnAction(){
     delegate?.didClickedAcceptBtn(btn: btn_accept, cell: self)
    }
    var friend:NewFriend!{
        didSet{
            img_icon.sd_setImage(with: URL(string:friend.headPortUrl), placeholderImage: defaultHeaderImage)
            lb_name.text = friend.nickname
            lb_subName.text = friend.msg
            
            friend.state.asObservable().subscribe(onNext: {[unowned self] (state) in
                if state == 1{
                    self.lb_accepted.isHidden = false
                    self.btn_accept.isHidden = true
                    self.lb_accepted.text = "等待验证"
                }else  if state == 2{
                    
                }else  if state == 3{
                    self.lb_accepted.isHidden = false
                    self.btn_accept.isHidden = true
                    
                    if self.friend.isGroup {
                       self.lb_accepted.text = "已同意"
                    } else {
                        self.lb_accepted.text = "已添加"
                    }
                }else  if state == 4{
                    self.lb_accepted.isHidden = true
                    self.btn_accept.isHidden = false
                }else  if state == 5{
                    self.lb_accepted.isHidden = true
                    self.btn_accept.isHidden = false
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
           
        }
    }
}

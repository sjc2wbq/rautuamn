//
//  NearGroupTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/21.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDWebImage

class NearGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var img_iocn: AnimatableImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_groupCount: AnimatableLabel!
    @IBOutlet weak var btn_distane: UIButton!
    @IBOutlet weak var btn_chat: AnimatableButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    var raugroup:Raugroup!{
        didSet{
            img_iocn.sd_setImage(with: URL(string:raugroup.coverPhotoUrl), placeholderImage: placeHolderImage)
            lb_name.text = raugroup.name
            
            lb_groupCount.text = "\(raugroup.rauGroupUserCount)人"
            btn_distane.setTitle("\(raugroup.distance)km", for: .normal)
            raugroup.jion.asObservable()
            .subscribe(onNext: { (jion) in
                self.btn_chat.setTitle(jion == true ? "进入群聊" : "加入", for: .normal)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
        }
    }
}

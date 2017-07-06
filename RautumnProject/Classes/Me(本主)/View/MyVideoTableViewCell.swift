
//
//  MyVideoTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDWebImage
class MyVideoTableViewCell: UITableViewCell {
    @IBOutlet weak var btn_delete: UIButton!
    
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_vover: UIImageView!
    @IBOutlet weak var img_paly: UIImageView!
    @IBOutlet weak var lb_timeAndPlayCount: UILabel!
    @IBOutlet weak var lb_commentCount: UILabel!
    @IBOutlet weak var lb_price: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var rsv :MyRSV!{
        didSet{
            lb_title.text = rsv.title
            img_vover.sd_setImage(with: URL(string:rsv.coverPhotoUrl), placeholderImage: placeHolderImage)
            
            rsv.playTimes.asObservable().map{"\(self.rsv.time)  播放：\($0)次"}.bindTo(lb_timeAndPlayCount.rx.text).addDisposableTo(rx_reusableDisposeBag)
            
            lb_commentCount.text = "\(rsv.commentCount)"
            
            rsv.countRC.asObservable().map{"￥\($0)"}.bindTo(lb_price.rx.text).addDisposableTo(rx_reusableDisposeBag)

        }
    }
}

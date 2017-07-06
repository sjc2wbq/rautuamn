//
//  GroupInfoHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import KSPhotoBrowser
import SDCycleScrollView
class GroupInfoHeaderView: UIView,SDCycleScrollViewDelegate {
    @IBOutlet weak var cycleScrollView: SDCycleScrollView!

    @IBOutlet weak var lb_title: UILabel!

    @IBOutlet weak var placeholderImageView: UIImageView!

    //
    override func awakeFromNib() {
        super.awakeFromNib()
        cycleScrollView.delegate = self
        cycleScrollView.bannerImageViewContentMode = .scaleAspectFit
        
    }
    static func headerView() -> GroupInfoHeaderView{
        return Bundle.main.loadNibNamed("GroupInfoHeaderView", owner: nil, options: nil)!.first as! GroupInfoHeaderView
    }
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        let browser = KSPhotoBrowser(photoItems: cycleScrollView.imageURLStringsGroup.map{KSPhotoItem(sourceView: placeholderImageView, imageUrl: URL(string:$0 as! String))}, selectedIndex: UInt(index))
        browser?.show(from: self.viewController)
    }
    var model:GroupDetailsModel?{
        didSet{
            guard let model = model  else {
                return
            }
            cycleScrollView.imageURLStringsGroup = model.rauGroupAlbums.map{$0.url}
            lb_title.text = model.name
//            btn_address.setTitle(model.address, for: .normal)
//            if model.distance == 0{
//              btn_distance.isHidden = true
//            }else{
//                btn_distance.isHidden = false
//                btn_distance.setTitle("\(model.distance)km", for: .normal)
//
//            }
//            var  w = btn_address.titleLabel!.text!.width(15, height: 22) + 20
//                 w =  w > screenW - 150 ?  screenW - 150 : w
//                 btn_address_w.constant =  w
        }
    }
}

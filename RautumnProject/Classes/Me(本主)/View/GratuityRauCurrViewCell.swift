//
//  GratuityRauCurrViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDWebImage
//import AnimatableImageView
class GratuityRauCurrViewCell: UITableViewCell {
   
    typealias DeleteClosure = () -> Void
    
    @IBOutlet weak var img_icom: UIImageView!
    @IBOutlet weak var lb_price: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_name: UILabel!
    
    fileprivate var deleteClosure: DeleteClosure?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(deleteCell(gesture:)))
        self.contentView.addGestureRecognizer(longPress)
        
      
    }
    
    func deleteThisCell(closure: DeleteClosure?) {
        self.deleteClosure = closure
    }
    
    @objc fileprivate func deleteCell(gesture: UILongPressGestureRecognizer) {
        self.deleteClosure?()
    }

    var model:Gratuityraucurr!{
        didSet{
            img_icom.sd_setImage(with: URL(string:model.headPortUrl), placeholderImage: defaultHeaderImage)
            
            print("ssss\(img_icom.image)")
            lb_price.text = "￥\(model.rauCurr)"
            lb_name.text = "\(model.nickName)"
            lb_time.text = model.date
        }
    }
    
}

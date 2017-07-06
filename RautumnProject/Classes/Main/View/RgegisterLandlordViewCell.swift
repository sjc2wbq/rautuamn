//
//  RgegisterLandlordViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/29.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import Eureka
import IBAnimatable
class RgegisterLandlordViewCell : Cell<String>,CellType {
    weak var btn_seleted: AnimatableButton?
    @IBOutlet weak var btn1: AnimatableButton!
    @IBOutlet weak var btn2: AnimatableButton!
    @IBOutlet weak var btn3: AnimatableButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        btn1.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn3.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        selectionStyle = UITableViewCellSelectionStyle.none
        layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
        layer.borderWidth = 0.5
        clipsToBounds = true
        layer.cornerRadius = 4

    }
    func btnAction(_ sender: AnimatableButton) {
        sender.isSelected = true
        btn_seleted?.isSelected = false
        btn_seleted = sender
        if sender == btn1{
            btn1.borderColor = UIColor.colorWithHexString("#ff8200")
            btn2.borderColor = UIColor.colorWithHexString("#999999")
            btn3.borderColor = UIColor.colorWithHexString("#999999")
        }else if sender == btn2{
            btn1.borderColor = UIColor.colorWithHexString("#999999")
            btn2.borderColor = UIColor.colorWithHexString("#ff8200")
            btn3.borderColor = UIColor.colorWithHexString("#999999")

        }else if sender == btn3{
            btn1.borderColor = UIColor.colorWithHexString("#999999")
            btn2.borderColor = UIColor.colorWithHexString("#999999")
            btn3.borderColor = UIColor.colorWithHexString("#ff8200")
        }
            row.value = sender.titleLabel!.text
    }
    
}


//MARK: RegisterSingleRow
final class RgegisterLandlordRow: Row<RgegisterLandlordViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<RgegisterLandlordViewCell>(nibName: "RgegisterLandlordViewCell")
    }
}

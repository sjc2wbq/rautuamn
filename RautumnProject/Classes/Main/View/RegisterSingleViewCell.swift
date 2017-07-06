//
//  RegisterJobViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/29.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import Eureka
import IBAnimatable
class RegisterSingleViewCell : Cell<String>,CellType {
    weak var btn_seleted: AnimatableButton?
    @IBOutlet weak var lb_desc: UILabel!
    @IBOutlet weak var btn1: AnimatableButton!
    @IBOutlet weak var btn2: AnimatableButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        btn1.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
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
        }else if sender == btn2{
            btn1.borderColor = UIColor.colorWithHexString("#999999")
            btn2.borderColor = UIColor.colorWithHexString("#ff8200")
        }
        self.row.value = sender.titleLabel!.text
    }
    override func update() {
        super.update()
        textLabel?.text = nil
//        lb_desc.text = row.title
        lb_desc.attributedText = row.attributeTitle
    }
}


//MARK: RegisterSingleRow
final class RegisterSingleRow: Row<RegisterSingleViewCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<RegisterSingleViewCell>(nibName: "RegisterSingleViewCell")
    }
}

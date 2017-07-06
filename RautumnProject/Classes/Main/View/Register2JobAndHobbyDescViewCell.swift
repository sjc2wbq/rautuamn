//
//  Register2JobAndHobbyDescViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/30.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import Eureka

class Register2JobAndHobbyDescViewCell: Cell<Set<String>>,CellType {

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    override func setup() {
        super.setup()
        height = {40}
    }
}
final class RgegisterJobAndHobbyRow: Row<Register2JobAndHobbyDescViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<Register2JobAndHobbyDescViewCell>(nibName: "Register2JobAndHobbyDescViewCell")
    }
}

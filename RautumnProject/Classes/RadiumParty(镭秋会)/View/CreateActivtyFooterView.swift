//
//  CreateActivtyFooterView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class CreateActivtyFooterView: UIView {
    @IBOutlet weak var btn_done: AnimatableButton!
    static func footerView() -> CreateActivtyFooterView{
        return Bundle.main.loadNibNamed("CreateActivtyFooterView", owner: nil, options: nil)!.first as! CreateActivtyFooterView
    }

}

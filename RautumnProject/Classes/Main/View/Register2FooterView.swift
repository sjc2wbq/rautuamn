//
//  Register2FooterView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/29.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import SwiftyDrop
class Register2FooterView: UIView {
    @IBOutlet weak var lb_title: AnimatableLabel!
    @IBOutlet weak var btn_idCardZ: AnimatableButton!
    @IBOutlet weak var btn_idCardF: AnimatableButton!
    var imagePicker :AIImagePicker?
    var imagePicker2 :AIImagePicker?
    @IBOutlet weak var btn: AnimatableButton!
    @IBOutlet weak var w: NSLayoutConstraint!
    public var idCardZ:String?
    public var idCardF:String?
    public var idCardZImg:UIImage?
    public var idCardFImg:UIImage?
    public  var chosedIdCardZ = Variable(false)
    public  var chosedIdCardF = Variable(false)

    static func footerView() -> Register2FooterView{
        return Bundle.main.loadNibNamed("Register2FooterView", owner: nil, options: nil)!.first as! Register2FooterView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("IdentityAuthentication", comment: "身份认证"))
        attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 4))
        attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(4, attributeTitle.length - 4))
        lb_title.attributedText = attributeTitle
        
        
        w.constant = NSLocalizedString("IdentityAuthentication", comment: "身份认证").width(14, height: 33) + 15

    }
    @IBAction func choseIdCardZAction(_ sender: UIButton) {
        if UserModel.shared.licenseStatus == 3{ //认证状态1待认证 2认证不通过 3审核认证通过
            Drop.down("身份已验证通过，不必再次验证身份！", state: .info)
            return
        }
        
        imagePicker = AIImagePicker()
        imagePicker?.allowEditting = true
        imagePicker?.imagePickerCompletion = {(image,path ) in
        sender.setImage(image, for: .normal)
            self.idCardZImg = image
        self.chosedIdCardZ.value = true
    }
        imagePicker?.show(in: self.viewController?.view)
    }
    @IBAction func choseIdCardFAction(_ sender: UIButton) {
        if UserModel.shared.licenseStatus == 3{ //认证状态1待认证 2认证不通过 3审核认证通过
            Drop.down("身份已验证通过，不必再次验证身份！", state: .info)
            return
        }
        imagePicker2 = AIImagePicker()
        imagePicker2?.allowEditting = true
        imagePicker2?.imagePickerCompletion = {(image,path ) in
            sender.setImage(image, for: .normal)
            self.idCardFImg = image
            self.chosedIdCardF.value = true

        }
        imagePicker2?.show(in: self.viewController?.view)
    }
    
}

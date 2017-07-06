//
//  Register2HeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/28.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import RxSwift
class Register2HeaderView: UIView {
   private var imagePicker :AIImagePicker?
    @IBOutlet weak var infoViewH: NSLayoutConstraint!
    @IBOutlet weak var datalabelW: NSLayoutConstraint!
    @IBOutlet weak var img_choseHeaderImg: UIImageView!
  public  var choseImaged = Variable(false)
   public var headerUlr:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        infoViewH.constant = NSLocalizedString("RegisterRule", comment: "注册规则").height(12, wight: screenW - 16) + 20
        datalabelW.constant = NSLocalizedString("RegisterBasicData", comment: "完善资料").width(14, height: 33) + 15
        img_choseHeaderImg.rx.gesture(.tap)
            .subscribe(onNext: {[unowned self] _ in
            self.imagePicker = AIImagePicker()
            self.imagePicker?.allowEditting = true
            self.imagePicker?.imagePickerCompletion = { [unowned self] (image,headerUlr) in
            self.img_choseHeaderImg.image = image
                self.headerUlr = headerUlr
                self.choseImaged.value = true
            }
            self.imagePicker?.show(in: self.viewController?.view)
        }).addDisposableTo(rx_disposeBag)
       
    }
    static func headerView() -> Register2HeaderView{
        return Bundle.main.loadNibNamed("Register2HeaderView", owner: nil, options: nil)!.first as! Register2HeaderView
    }

}

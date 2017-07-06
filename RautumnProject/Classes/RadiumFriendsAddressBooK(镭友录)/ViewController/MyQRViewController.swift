//
//  MyQRViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/16.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import swiftScan
import SDAutoLayout
import SDWebImage
import IBAnimatable
import CryptoSwift
class MyQRViewController: UIViewController {
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var img_qr: UIImageView!
    @IBOutlet weak var img_qr_h: NSLayoutConstraint!
    
    @IBOutlet weak var img_code: AnimatableImageView!
    let userView = UserInfoView.userInfoView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(MyQRViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的二维码"
        userView.backgroundColor = UIColor.clear
        userInfoView.addSubview(userView)
        img_qr_h.constant = screenW - 100
        do{
            //
       let codeString =  "\(Date().timeIntervalSince1970)".md5() + "&sdsddff#d&dfd" + "\(UserModel.shared.id)" + "&assdas#dxcx&"
            
            img_code.sd_setImage(with: URL(string:UserModel.shared.headPortUrl.value), placeholderImage: placeHolderImage)
            img_qr.sd_setImage(with: URL(string:UserModel.shared.headPortUrl.value), completed: { (image, _, _, _) in
            let qrImg = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator",codeString:codeString, size: self.img_qr.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
                if let qrImg = qrImg{
                   self.img_qr.image =  LBXScanWrapper.getConcreteCodeImage(srcCodeImage: qrImg, rect: self.img_qr.bounds)
//                    self.img_qr.image = LBXScanWrapper.addImageLogo(srcImg: qrImg, logoImg: image, logoSize: CGSize(width: 60, height: 60))
                }
        })
    }
    }
}
extension MyQRViewController{

}

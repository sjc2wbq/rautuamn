//
//  FindFriendsHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SimpleAlert
import IBAnimatable
import swiftScan
class FindFriendsHeaderView: UIView {
    @IBOutlet weak var btn_region: AnimatableButton!
    @IBOutlet weak var bottomView: UIView!
    var btnAction:((_ index:Int,_ isSelected:Bool) -> ())?
    
    @IBOutlet weak var w: NSLayoutConstraint!
    @IBOutlet weak var btn_fg: UIButton!
    @IBOutlet weak var btn_fb: UIButton!
    @IBOutlet weak var btn_w: UIButton!
    @IBOutlet weak var btn_hz: UIButton!
    static func headerView() -> FindFriendsHeaderView{
        return Bundle.main.loadNibNamed("FindFriendsHeaderView", owner: nil, options: nil)!.first as! FindFriendsHeaderView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        btn_region.setTitle(UserModel.shared.city == "定位失败" ? "北京" : UserModel.shared.city, for: .normal)
//        w.constant = btn_region.titleLabel!.text!.width(15, height: 31) + 20
        btn_fg.layer.cornerRadius = 4
        btn_fg.layer.borderWidth = 1
        btn_fg.layer.borderColor = UIColor(red: 131/255.0, green: 235/255.0, blue: 82/255.0, alpha: 1).cgColor
        
        btn_fb.layer.cornerRadius = 4
        btn_fb.layer.borderWidth = 1
        btn_fb.layer.borderColor = UIColor(red: 255/255.0, green: 129/255.0, blue: 179/255.0, alpha: 1).cgColor
        
        btn_w.layer.cornerRadius = 4
        btn_w.layer.borderWidth = 1
        btn_w.layer.borderColor = UIColor(red: 80/255.0, green: 189/255.0, blue: 253/255.0, alpha: 1).cgColor
        
        btn_hz.layer.cornerRadius = 4
        btn_hz.layer.borderWidth = 1
        btn_hz.layer.borderColor = UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1).cgColor
        
        btn_hz.clipsToBounds = true

        btn_fg.clipsToBounds = true

        btn_fb.clipsToBounds = true

        btn_w.clipsToBounds = true

        
    }
    @IBAction func buttonAction(_ sender: UIButton) {
        if sender == btn_fg{
//            btn_fg.setBackgroundImage(UIImage(named:"FG"), for: .normal)
//            btn_fg.clipsToBounds = false
//            btn_fg.clipsToBounds = true
//            btn_fg.setTitleColor(UIColor.white, for: .normal)
//            btn_fg.setTitle(nil, for: .normal)
//
//            btn_fb.setTitle("FB", for: .normal)
//            btn_fb.setBackgroundImage(nil, for: .normal)
//            btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)
            
            btn_fg.isSelected = !btn_fg.isSelected
            if btn_fg.isSelected{
                
                btn_fb.isSelected = false
                btn_w.isSelected = false
                btn_hz.isSelected = false

                
                btn_fb.setTitle("FB", for: .normal)
                btn_fb.setBackgroundImage(nil, for: .normal)
                btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)

                
                btn_w.setTitle("W", for: .normal)
                btn_w.setTitleColor(UIColor(red: 65/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1), for: .normal)
                
                btn_w.clipsToBounds = true
                btn_w.setBackgroundImage(nil, for: .normal)

                
                btn_hz.backgroundColor = UIColor.white
                btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)
                
                
                btn_fg.setBackgroundImage(UIImage(named:"FG"), for: .normal)
                btn_fg.clipsToBounds = false
                btn_fg.clipsToBounds = true
                btn_fg.setTitleColor(UIColor.white, for: .normal)
                btn_fg.setTitle(nil, for: .normal)
                
                if btn_fb.isSelected{
                    btn_fb.setTitle("FB", for: .normal)
                    btn_fb.clipsToBounds = true
                    btn_fb.clipsToBounds = false
                    btn_fb.setBackgroundImage(nil, for: .normal)
                    btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)
                    btn_fb.isSelected = false
                }
                
                  }else{
                btn_fg.setBackgroundImage(nil, for: .normal)
                btn_fg.clipsToBounds = true
                btn_fg.clipsToBounds = false
                btn_fg.setTitleColor(UIColor(red: 177/255.0, green: 233/255.0, blue: 51/255.0, alpha: 1), for: .normal)
                btn_fg.setTitle("FG", for: .normal)
            }
            
        }else if sender == btn_fb{
            btn_fb.isSelected = !btn_fb.isSelected
            
            
            btn_fg.isSelected = false
            btn_w.isSelected = false
            btn_hz.isSelected = false
            
            
            btn_fg.setBackgroundImage(nil, for: .normal)
            btn_fg.clipsToBounds = true
            btn_fg.clipsToBounds = false
            btn_fg.setTitleColor(UIColor(red: 177/255.0, green: 233/255.0, blue: 51/255.0, alpha: 1), for: .normal)
            btn_fg.setTitle("FG", for: .normal)
        
        
            btn_w.setTitle("W", for: .normal)
            btn_w.setTitleColor(UIColor(red: 65/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1), for: .normal)
            
            btn_w.clipsToBounds = true
            btn_w.setBackgroundImage(nil, for: .normal)
            
            
            btn_hz.backgroundColor = UIColor.white
            btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)

            
            if btn_fb.isSelected{
                
                
                
                btn_fb.setTitleColor(UIColor.white, for: .normal)
                btn_fb.setBackgroundImage(UIImage(named:"FB"), for: .normal)
                btn_fb.setTitle(nil, for: .normal)

            
                if btn_fg.isSelected {
                    btn_fg.setBackgroundImage(nil, for: .normal)
                    btn_fg.clipsToBounds = true
                    btn_fg.clipsToBounds = false
                    btn_fg.setTitleColor(UIColor(red: 177/255.0, green: 233/255.0, blue: 51/255.0, alpha: 1), for: .normal)
                    btn_fg.setTitle("FG", for: .normal)
                    btn_fg.isSelected = false

                }
            }else{
                btn_fb.setTitle("FB", for: .normal)
                btn_fb.setBackgroundImage(nil, for: .normal)
                btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)

            }

            
        }else if sender == btn_w{
            btn_w.isSelected = !btn_w.isSelected
            
            
            btn_fg.isSelected = false
            btn_fb.isSelected = false
            btn_hz.isSelected = false
            
            
            btn_fb.setTitle("FB", for: .normal)
            btn_fb.setBackgroundImage(nil, for: .normal)
            btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)
            
            
            btn_fg.setBackgroundImage(nil, for: .normal)
            btn_fg.clipsToBounds = true
            btn_fg.clipsToBounds = false
            btn_fg.setTitleColor(UIColor(red: 177/255.0, green: 233/255.0, blue: 51/255.0, alpha: 1), for: .normal)
            btn_fg.setTitle("FG", for: .normal)
            
            
            btn_hz.backgroundColor = UIColor.white
            btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)
            btn_w.clipsToBounds = true
            btn_w.setBackgroundImage(nil, for: .normal)
            
            
            btn_hz.backgroundColor = UIColor.white
            btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)

            if btn_w.isSelected{
                btn_w.setBackgroundImage(UIImage(named:"FW"), for: .normal)
                btn_w.clipsToBounds = false
                btn_w.setTitle(nil, for: .normal)
                btn_w.setTitleColor(UIColor.white, for: .normal)
            }else{
                btn_w.setTitle("W", for: .normal)
                btn_w.setTitleColor(UIColor(red: 65/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1), for: .normal)
                
                btn_w.clipsToBounds = true
                btn_w.setBackgroundImage(nil, for: .normal)

            }
            
        }else if sender == btn_hz{
            btn_hz.isSelected = !btn_hz.isSelected
            
            btn_fg.isSelected = false
            btn_fb.isSelected = false
            btn_w.isSelected = false
            
            
            btn_fg.setBackgroundImage(nil, for: .normal)
            btn_fg.clipsToBounds = true
            btn_fg.clipsToBounds = false
            btn_fg.setTitleColor(UIColor(red: 177/255.0, green: 233/255.0, blue: 51/255.0, alpha: 1), for: .normal)
            btn_fg.setTitle("FG", for: .normal)
            
            btn_fb.setTitle("FB", for: .normal)
            btn_fb.setBackgroundImage(nil, for: .normal)
            btn_fb.setTitleColor(UIColor(red: 252/255.0, green: 106/255.0, blue: 106/255.0, alpha: 1), for: .normal)
            
            
            
            btn_w.setTitle("W", for: .normal)
            btn_w.setTitleColor(UIColor(red: 65/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1), for: .normal)
            
            btn_w.clipsToBounds = true
            btn_w.setBackgroundImage(nil, for: .normal)
            
            btn_hz.backgroundColor = UIColor.white
            btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)

            if btn_hz.isSelected{
                btn_hz.setTitleColor(UIColor.white, for: .selected)
                btn_hz.backgroundColor = UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1)
            }else{
                btn_hz.backgroundColor = UIColor.white
                btn_hz.setTitleColor(UIColor(red: 255/255.0, green: 162/255.0, blue: 33/255.0, alpha: 1), for: .normal)
            }
        }
        btnAction?(sender.tag,sender.isSelected)
    }
    //CityViewController
}
class FindFriendsPopView: UIView {
    var qrAction:(() -> ())?
    var leiAction:(() -> ())?
    static func popView() -> FindFriendsPopView{
        return Bundle.main.loadNibNamed("FindFriendsHeaderView", owner: nil, options: nil)![1] as! FindFriendsPopView
    }
    @IBAction func leiYFAction(_ sender: UIButton) {
    leiAction?()
    }
    
    @IBAction func scanQRAction(_ sender: Any) {
     qrAction?()
     
    }
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return false
//    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        if view!.isKind(of: FindFriendsPopView.self) {
//            return nil
//        }
//        return nil
//    }
}

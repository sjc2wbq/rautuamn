
//
//  ExceptionalView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
import UIKit
import IBAnimatable
import SimpleAlert
import SwiftyDrop
class ExceptionalView: UIView {
    @IBOutlet weak var slider: ASValueTrackingSlider!
    @IBOutlet weak var lb_gold: UILabel!
    @IBOutlet weak var btn_topUp: UIButton!
    var rautumnFriendsCircle : RautumnFriendsCircle?
    public var rvUseful:RvUseful?
    var exceptionalGoldHander : (() -> ())?
    public var type = 1
    var objId = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        btn_topUp.rx.tap
//            .subscribe(onNext: {[unowned self] (_) in
//                let vc1 = RechargeViewController()
////                let tabBar = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
////                tabBar.selectedViewController?.navigationController?.pushViewController(vc1, animated: true)
//                self.viewController?.navigationController?.pushViewController(vc1, animated: true)
//                let vc = self.viewController as? AlertController
//                vc?.dismiss(animated: true, completion: {
////                    let vc1 = RechargeViewController()
////                    let tabBar = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
////                    tabBar.selectedViewController?.navigationController?.pushViewController(vc1, animated: true)
//                })
//
//            }, onError: nil, onCompleted: nil, onDisposed: nil )
//            .addDisposableTo(rx_disposeBag)
        slider.popUpViewColor = UIColor.black
        
        slider.textColor = UIColor.white
        slider.tintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.colorWithHexString("#ff8200")
        slider.minimumTrackTintColor = UIColor.colorWithHexString("#ff8200").withAlphaComponent(0.5)
    }
    static func exceptionalView() -> ExceptionalView{
        return Bundle.main.loadNibNamed("ExceptionalView", owner: nil, options: nil)!.first as! ExceptionalView
    }
    
    @IBAction func exceptionalAction(_ sender: Any) {
        if Float(UserModel.shared.rautumnCurrency.value) == 0  {
            self.exceptionalGoldHander?()
            return
        }
        if Float(UserModel.shared.rautumnCurrency.value) < slider.value  {
            self.exceptionalGoldHander?()
            return
        }
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(UIApplication.shared.keyWindow!.isLoading(showTitle: "", for: UIApplication.shared.keyWindow!))
            .addDisposableTo(rx_disposeBag)
        
        let request = RequestProvider.request(api: ParametersAPI.gratuityRauCurr(gratuityRauCurr: slider.value == 0 ? 0.18 : slider.value , objId: objId, type: type)).mapObject(type: EmptyModel.self)
            .trackActivity(activityIndicator)
             .shareReplay(1)

        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
            Drop.down(error, state: .error)
            let vc = self.viewController as? AlertController
            vc?.dismiss(animated: true, completion: nil)
        }, onError: nil, onCompleted: nil, onDisposed: nil )
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}
        .subscribe(onNext: {[unowned self] (_) in
            Drop.down("打赏成功！", state: .success)
            if let _ = self.rvUseful{
                self.rvUseful!.countRC.value = String(format: "%.2f",Float(self.rvUseful!.countRC.value)! + self.slider.value )
            }
            if let _ = self.rautumnFriendsCircle{
                self.rautumnFriendsCircle!.countRC.value = self.rautumnFriendsCircle!.countRC.value + self.slider.value 
            }
            UserModel.shared.rautumnCurrency.value = Float(String(format:"%.2f",UserModel.shared.rautumnCurrency.value - self.slider.value - 0.18))!
            
            let vc = self.viewController as? AlertController
            vc?.dismiss(animated: true, completion: nil)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)

    }

    @IBAction func cancelAction(_ sender: Any) {
        let vc = self.viewController as? AlertController
        vc?.dismiss(animated: true, completion: nil)
    }
}

//
//  LeiFateViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/18.
//  Copyright © 2017年 Rautumn. All rights reserved.
// 镭缘分

import UIKit
import SwiftyDrop
import RxSwift
import IBAnimatable
import ObjectMapper
struct RauFriendModel {
    var id = 0
    var headPortUrl = ""
    var nickName = ""
    
    init(map: Map) {}
}

extension RauFriendModel: Mappable {
    mutating func mapping(map: Map) {
        id <- map["id"]
        headPortUrl <- map["headPortUrl"]
        nickName <- map["nickName"]
    }
}
class LeiFateViewController: UIViewController ,UIAlertViewDelegate{

    @IBOutlet weak var siriWaveformView: SCSiriWaveformView!
    @IBOutlet weak var siriWaveformVie2: SCSiriWaveformView!
    @IBOutlet weak var siriWaveformVie3: SCSiriWaveformView!
    @IBOutlet weak var btn_see: AnimatableButton!
    @IBOutlet weak var btn_lei: AnimatableButton!
    @IBOutlet weak var lb_leiCount: UILabel!
    var disPlayLinker:CADisplayLink!
    var hasFriend = Variable(false)
    var timer : Timer?
    var model:RauFriendModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(LeiFateViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "镭缘分"
        
        do{
            self.btn_see.backgroundColor = UIColor.white
            self.btn_see.layer.borderWidth = 0.5
            self.btn_see.layer.masksToBounds = true
            self.btn_see.layer.borderColor = UIColor.colorWithHexString("#666666").cgColor
            self.btn_see.setTitleColor(UIColor.colorWithHexString("#666666"), for: .normal)

            disPlayLinker = CADisplayLink.init(target: self, selector:#selector(LeiFateViewController.updateShap))
            disPlayLinker.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
            setWaveformView(siriWaveformView: siriWaveformView)
            setWaveformView(siriWaveformView: siriWaveformVie2)
            setWaveformView(siriWaveformView: siriWaveformVie3)
        
            do{
            hasFriend.asObservable()
                .filter{$0 == true}
                .subscribe(onNext: {[unowned self] (hasFriend) in
                    if let _ = self.navigationController?.topViewController?.isKind(of: LeiFateViewController.self) {
//                        let alertView = UIAlertView(title: "温馨提示", message: "镭平台已为你找到 1 位镭友", delegate: self, cancelButtonTitle: "去看看", otherButtonTitles: "继续镭")
//                        alertView.show()
                        DispatchQueue.main.async {
                            self.siriWaveformView.idleAmplitude = 0
                            self.siriWaveformVie2.idleAmplitude = 0
                            self.siriWaveformVie3.idleAmplitude = 0
                            
                            
                            self.btn_see.backgroundColor = UIColor.colorWithHexString("#FF8200")
                            self.btn_see.layer.borderWidth = 0
                            self.btn_see.layer.borderColor = UIColor.colorWithHexString("#FF8200").cgColor
                            self.btn_see.layer.masksToBounds = false
                            self.btn_see.setTitleColor(UIColor.white, for: .normal)
//                            self.disPlayLinker.remove(from: RunLoop.current, forMode: .commonModes)
                        }
                        
                    }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            }
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        self.lb_leiCount.text = "镭平台已为你找到 0 位镭友"
        hasFriend.value = false
        if buttonIndex == 1{
        
            self.addTimer()

        }else{
            let vc = UserInfoViewController()
            vc.visitorUserId = model!.id
//            vc.title = model!.nickName
            navigationController?.pushViewController(vc, animated: true)

        }
    }
    func setWaveformView(siriWaveformView:SCSiriWaveformView)  {
        siriWaveformView.numberOfWaves = 1
    }
        func updateShap(){
            let level:Float = 0
            self.siriWaveformView.update(withLevel: CGFloat(level))
            self.siriWaveformVie2.update(withLevel: CGFloat(level))
            self.siriWaveformVie3.update(withLevel: CGFloat(level))
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.siriWaveformView.idleAmplitude = 0.1
        self.siriWaveformVie2.idleAmplitude = 0.3
        self.siriWaveformVie3.idleAmplitude = 0.2
        self.addTimer()
        

//        disPlayLinker.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);

//        hasFriend.value = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.viewWillDisappear(animated)
        self.removeTimer()
//        hasFriend.value = false
        

    }
    deinit {
        hasFriend.value = false

        self.removeTimer()
    }
    ///去看看
    @IBAction func seeAction(_ sender: Any) {
        guard let model = model else {
            Drop.down("还没有镭到好友！", state: .info)
            return
        }
        self.btn_see.backgroundColor = UIColor.white
        self.btn_see.layer.borderWidth = 0.5
        self.btn_see.layer.masksToBounds = true
        self.btn_see.layer.borderColor = UIColor.colorWithHexString("#666666").cgColor
        self.btn_see.setTitleColor(UIColor.colorWithHexString("#666666"), for: .normal)
        self.lb_leiCount.text = "镭平台已为你找到 0 位镭友"
        let vc = UserInfoViewController()
        vc.visitorUserId = model.id
//        vc.title = model.nickName
        self.model = nil
        navigationController?.pushViewController(vc, animated: true)
    }
    ///继续镭
    @IBAction func continueAction(_ sender: Any) {
        
        self.btn_see.backgroundColor = UIColor.white
        self.btn_see.layer.borderWidth = 0.5
        self.btn_see.layer.masksToBounds = true
        self.btn_see.layer.borderColor = UIColor.colorWithHexString("#666666").cgColor
        self.btn_see.setTitleColor(UIColor.colorWithHexString("#666666"), for: .normal)

        self.lb_leiCount.text = "镭平台已为你找到 0 位镭友"
        self.siriWaveformView.idleAmplitude = 0.1
        self.siriWaveformVie2.idleAmplitude = 0.3
        self.siriWaveformVie3.idleAmplitude = 0.2
        
        self.addTimer()
    }
    @objc fileprivate func timerRun(){
        let request =  RequestProvider.request(api: ParametersAPI.rauFriend).mapObject(type: RauFriendModel.self)
                .shareReplay(1)
    
        request.flatMap{$0.unwarp()}.map{$0.result_data}
            .subscribe(onNext: {[unowned self] (model) in
                guard let  _ = model else{
                    self.lb_leiCount.text = "镭平台已为你找到 0 位镭友"
                    return
                }
                self.removeTimer()
                self.hasFriend.value = true
                self.lb_leiCount.text = "镭平台已为你找到 1 位镭友"
                self.model = model
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: {[unowned self] (error) in
                Drop.down(error, state: .error)
                self.removeTimer()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    
    }
    fileprivate func addTimer(){
        timer = Timer(timeInterval: 5, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
         RunLoop.main.add(timer!, forMode: .commonModes)
    }
    fileprivate func removeTimer(){
      timer?.invalidate()
      timer = nil
    }
}

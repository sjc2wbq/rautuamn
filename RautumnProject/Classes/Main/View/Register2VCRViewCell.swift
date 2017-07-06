//
//  Register2VCRViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/29.
//  Copyright © 2016年 Rautumn. All rights reserved.
//
import Eureka
import SwiftyDrop
import UIKit
import IBAnimatable
import RxSwift
import AVFoundation

class Register2VCRViewCell: Cell<URL>,CellType,RxMediaPickerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate {
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lb_title: AnimatableLabel!
    @IBOutlet weak var w: NSLayoutConstraint!

    @IBOutlet weak var h: NSLayoutConstraint!
    @IBOutlet weak var btn: AnimatableButton!
    let maximumDuration :TimeInterval = 45
    var picker: RxMediaPicker!
    let img_palyVideo = UIImageView()
    var player :AVPlayer?
    var editUserInfo = false
    public var recordVCR : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        picker = RxMediaPicker(delegate: self)

    
        selectionStyle = UITableViewCellSelectionStyle.none
        
        let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("myVCR", comment: "我的VCR(可选，不超过45秒)"))
        attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 5))
        attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(5, attributeTitle.length - 5))
        lb_title.attributedText = attributeTitle
        
        w.constant = NSLocalizedString("myVCR", comment: "我的VCR(可选，不超过45秒)").width(14, height: 33) + 15
        h.constant = NSLocalizedString("VCRExample", comment: "VCR举例").height(12, wight: screenW - 16) + 20
        
    }
    override func update() {
        super.update()
        self.height = {100 + screenW / 2}
    }
//KZVideoViewController
    
    @IBAction func vcrAction(_ sender: UIButton) {
        
        if self.row.value == nil {
            let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从手机选择","录制")
                sheet.show(in:self.viewController!.view)
            
        }else{

            let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "播放", style: .default, handler: { (_) in
                
                guard let url = self.row.value else{
                    return
                }
                let vc = PlayVideoViewController()
                vc.videoUrl = url.absoluteString.hasPrefix("http://") == true ? URL(string:UserModel.shared.vcrUrl) : url
                self.viewController?.present(vc, animated: true, completion: nil)
            }))
            
            vc.addAction(UIAlertAction(title: "从手机选择", style: .default, handler: {[unowned self] (_) in
                self.picker.selectVideo(source: .photoLibrary, maximumDuration: self.maximumDuration, editable: true)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (url ) in
                        self.row.value = url
                        self.player  =  AVPlayer(url: url)
                        self.player?.volume = 0
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = self.btn.bounds
                        self.btn.layer.addSublayer(playerLayer)
                        self.player?.play()
                        
                        self.addSubview(self.img_palyVideo)
                        self.btn.setBackgroundImage(nil, for: .normal)
                        self.btn.setImage(nil, for: .normal)
                    })
                    .addDisposableTo(self.rx_reusableDisposeBag)
            }))
            
            vc.addAction(UIAlertAction(title: "录制", style: .default, handler: {[unowned self] (_) in
                self.picker.recordVideo(maximumDuration: self.maximumDuration, editable: true)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: {[unowned self] (url) in
                        self.row.value = url
                        self.player  =  AVPlayer(url: url)
                        self.player?.volume = 0
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = self.btn.bounds
                        self.btn.layer.addSublayer(playerLayer)
                        self.player?.play()
                        
                        self.addSubview(self.img_palyVideo)
                        self.btn.setBackgroundImage(nil, for: .normal)
                        self.btn.setImage(nil, for: .normal)
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(self.rx_reusableDisposeBag)
            }))
            vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.viewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            self.picker.selectVideo(source: .photoLibrary, maximumDuration: maximumDuration, editable: true)
                .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (url ) in
                self.row.value = url
                self.player  =  AVPlayer(url: url)
                self.player?.volume = 0
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.btn.bounds
                self.btn.layer.addSublayer(playerLayer)
                self.player?.play()
                
                self.addSubview(self.img_palyVideo)
                self.btn.setBackgroundImage(nil, for: .normal)
                self.btn.setImage(nil, for: .normal)
            })
                .addDisposableTo(self.rx_reusableDisposeBag)

        }else if buttonIndex == 2{
        
            self.picker.recordVideo(maximumDuration: maximumDuration, editable: true)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[unowned self] (url) in
                    self.row.value = url
                    self.player  =  AVPlayer(url: url)
                    self.player?.volume = 0
                    let playerLayer = AVPlayerLayer(player: self.player)
                    playerLayer.frame = self.btn.bounds
                    self.btn.layer.addSublayer(playerLayer)
                    self.player?.play()
                    
                    self.addSubview(self.img_palyVideo)
                    self.btn.setBackgroundImage(nil, for: .normal)
                    self.btn.setImage(nil, for: .normal)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(self.rx_reusableDisposeBag)
            

        }
    }
    func present(picker: UIImagePickerController){
    self.viewController?.present(picker, animated: true, completion: nil)
    }
    func dismiss(picker: UIImagePickerController){
        DispatchQueue.main.async {
            self.viewController?.dismiss(animated: true, completion: nil)
        }
    }
}
//MARK: RgegisterMottoRow
final class RgegisterVCRRow: Row<Register2VCRViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<Register2VCRViewCell>(nibName: "Register2VCRViewCell")
    }
}

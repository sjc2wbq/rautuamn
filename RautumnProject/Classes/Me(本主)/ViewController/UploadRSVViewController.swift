
//
//  UploadRSVViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyDrop
import RxSwift
import SwiftLocation
import AVFoundation
import FDFullscreenPopGesture
class UploadRSVViewController: UITableViewController , RxMediaPickerDelegate,UITextFieldDelegate ,UIActionSheetDelegate ,UIAlertViewDelegate{
    var player :AVPlayer?

    @IBOutlet weak var img_cover: UIImageView!
    private var imagePicker :AIImagePicker?
    private  var choseImaged = Variable(false)
    private var picker: RxMediaPicker!
    var videoCoverUrl = ""
    var videoUrl = ""
    var position = "未知"
    var chosed = false
    
    @IBOutlet weak var tf_title: UITextField!
    @IBOutlet weak var img_videoCover: AnimatableButton!
    @IBOutlet weak var img_video: AnimatableButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        do{
            //import FDFullscreenPopGesture

            self.fd_interactivePopDisabled = true
            let item = UIBarButtonItem.itemWithTitle(title: "取消")
            self.navigationItem.leftBarButtonItem = item
            item.rx.tap
                .map{_ in self.chosed}
                .subscribe(onNext: {[unowned self] (chosed) in
                    self.view.endEditing(true)
                    if chosed {
                        let vc = UIAlertController(title: nil, message: "您确认放弃上传视频？", preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: {[unowned self] _ in
                            _ =  self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        _ =  self.navigationController?.popViewController(animated: true)
                    }
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)

        }
        picker = RxMediaPicker(delegate: self)
        do{
            var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                _ =  Location.reverse(location: loc, onSuccess: { (placemark) in
                    self.position = (placemark.addressDictionary?["FormattedAddressLines"] as! NSArray)[0] as! String
                }, onError: { (_) in
                    
                })
            }) { (last, err) in
                print("err \(err)")
            }
            r.onAuthorizationDidChange = { newStatus in
                print("New status \(newStatus)")
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        }
          return  120 + screenW / 2
    }
    @IBAction func choseVideoCoverAction(_ sender: UIButton) {
        self.tf_title.endEditing(true)
        self.imagePicker = AIImagePicker()
        self.imagePicker?.allowEditting = true
        self.imagePicker?.imagePickerCompletion = { [unowned self] (image,videoCoverUrl) in
            sender.setImage(image, for: .normal)
            self.videoCoverUrl = videoCoverUrl!
            self.choseImaged.value = true
           self.chosed = true
        }
        self.imagePicker?.show(in: self.view)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        chosed = true
        return true
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            self.selectVideo()
        }else if buttonIndex == 2{
        self.recordVideo()
        }
    }
    fileprivate func recordVideo(){
        self.picker.recordVideo(maximumDuration: 90, editable: true)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (url) in
                self.img_cover.image = nil
                self.img_cover.isHidden = true
                self.videoUrl = url.absoluteString
                self.player  =  AVPlayer(url: url)
                self.player?.volume = 0
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.img_video.bounds
                self.img_video.layer.addSublayer(playerLayer)
                self.player?.play()
                self.chosed = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.rx_disposeBag)

    }
    
    fileprivate func selectVideo(){
        self.picker.selectVideo(source: .photoLibrary, maximumDuration: 90, editable: true)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (url) in
                self.img_cover.image = nil
                self.img_cover.isHidden = true
                self.videoUrl = url.absoluteString
                self.player  =  AVPlayer(url: url)
                self.player?.volume = 0
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.img_video.bounds
                self.img_video.layer.addSublayer(playerLayer)
                self.player?.play()
                self.chosed = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.rx_disposeBag)
        
    }
    
    @IBAction func choseVideoAction(_ sender: Any) {
        self.tf_title.endEditing(true)
        if self.videoUrl == ""{
           let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从手机选择", "录制")
            actionSheet.show(in: view)
        }else{
            let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "播放", style: .default, handler: { (_) in
                let vc = PlayVideoViewController()
                vc.videoUrl = URL(string:self.videoUrl)
                self.present(vc, animated: true, completion: nil)
            }))
            vc.addAction(UIAlertAction(title: "从手机选择", style: .default, handler: {[unowned self] (_) in
                self.selectVideo()
                
            }))
            vc.addAction(UIAlertAction(title: "录制", style: .default, handler: {[unowned self] (_) in
                self.recordVideo()
            }))
            vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func done(_ sender: UIButton) {
        guard let name = tf_title.text  else {
            Drop.down("请输入标题！", state: .error)
            return
        }
        if name.characters.count == 0{
            Drop.down("请输入标题！", state: .error)
            return
        }
        if videoCoverUrl == ""{
            Drop.down("请选择视频封面！", state: .error)
            return
        }
        if videoUrl == ""{
            Drop.down("请录制视频！", state: .error)
            return
        }

         let alertView = UIAlertView(title: "上传位置", message: "是否上传位置？", delegate: self, cancelButtonTitle: "不上传", otherButtonTitles: "确定上传")
            alertView.show()
        
      
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        guard let name = tf_title.text  else {
            return
            }
     
        if videoCoverUrl == ""{
            
        }
   
        if buttonIndex == 0 {
            self.position = ""
        }
        
        let activityIndicator = ActivityIndicator()
        
        activityIndicator.asObservable()
            .bindTo(isLoading(showTitle: "发布中...", for: view)).addDisposableTo(rx_disposeBag)
        
        activityIndicator.asObservable()
            .map{!$0}.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)
        
        let uploadVideoCoverRequest =  RequestProvider.upload(type: .png, fileUrl: URL(string:videoCoverUrl)!)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        let uploadVideoRequest =  RequestProvider.upload(type: .mp4, fileUrl: URL(string:videoUrl)!)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        //
        
        
        let allRequest =  Observable.zip(uploadVideoCoverRequest.flatMap{$0.unwarp()}, uploadVideoRequest.flatMap{$0.unwarp()}) { (videoCoverUrl, videoUrl) -> (String,String) in
            return (videoCoverUrl,videoUrl)
            }
            .flatMap{RequestProvider.request(api: ParametersAPI.publishRSV(title: name, coverPhotoUrl: $0.0, videoUrl: $0.1, position: self.position))}
            .mapObject(type: MyRSV.self)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        allRequest.flatMap{$0.unwarp()}.map{$0.result_data}
            .unwrap()
            .subscribe(onNext: { (rsv) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PublishRSVSucccessNotifation"), object: nil, userInfo: ["rsv":rsv])
                _ = self.navigationController?.popViewController(animated: true)
                Drop.down("发布视频成功！", state: .success)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        Observable.of(uploadVideoCoverRequest.flatMap{$0.error}.map{$0.domain},uploadVideoRequest.flatMap{$0.error}.map{$0.domain},allRequest.flatMap{$0.error}.map{$0.domain})
            .merge()
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func present(picker: UIImagePickerController){
        self.present(picker, animated: true, completion: nil)
    }
    func dismiss(picker: UIImagePickerController){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: .none)
        }
    }
}

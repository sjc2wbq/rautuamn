//
//  PostDynamicController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import SDWebImage
import AVFoundation
import SwiftyDrop
import  MBProgressHUD
import KMPlaceholderTextView
import SimpleAlert
import ARSLineProgress

class PostDynamicController: UITableViewController,SearchMapViewControllerDelegate,UITextViewDelegate {

    let maximumDuration : TimeInterval = 45
    enum PostType {
        case mp4
        case photo
        case mp3
    }
    var param = PublishRFCParam()

    var recordMp4 = Variable(false)
    
    var mp4Url:URL?
    var mp3Url:URL?
    var postType:Variable<PostType> = Variable(.photo)
    var audio_length = 0

    var audioPlayer: HKPlayer?
    
    var edit = false
    @IBOutlet weak var btn_address: UIButton!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: 80, height: 80)
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = UIColor.white
            collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "Section")
            collectionView.register(PostDynamicViewCell.self, forCellWithReuseIdentifier: "PostDynamicViewCell")
            collectionView.register(PostDynamicVideoViewCell.self, forCellWithReuseIdentifier: "PostDynamicVideoViewCell")
            collectionView.register(PostDynamicAudioViewCell.self, forCellWithReuseIdentifier: "PostDynamicAudioViewCell")
        }
    }
    @IBOutlet weak var textView: KMPlaceholderTextView!
    

    let maxCount = 3000
    typealias TableSectionModel = AnimatableSectionModel<String, Photo>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Photo]()
    var imageUrls : Variable<[String]> = Variable([])

    
    var picker: RxMediaPicker?
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
        }
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.audioPlayer?.pausePlay()
    }
    
    override func viewDidLoad() {
        param.userId = UserModel.shared.id
        textView.delegate = self
        textView.returnKeyType = .done
        
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView = UIView()
        initCollectionView()
        do {
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "DeleteVideoNotifation"))
            .subscribe(onNext: {[unowned self] (_) in
                self.postType.value = .photo
                self.sections.value = [TableSectionModel(model: "", items: [])];
                var photo = Photo()
                photo.image = UIImage(named:"tianjiatup")!
                photo.imagePath = ""
                self.items.append(photo)
                self.sections.value = [TableSectionModel(model: "", items: self.items)];
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
    }

    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == "dismissPostVC" { //发布成功
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushSearchMapViewController" { //搜索位置信息控制器
        let vc = segue.destination as! SearchMapViewController
            vc.delegate = self
        }
    }
    func searchMapViewController(_ vc: SearchMapViewController!, sendLocationWithLatitude latitude: Double, longitude: Double, address: String!) {
        self.param.positionName = address
        self.param.lon = longitude
        self.param.lat = latitude
        btn_address.setTitle(address, for: .normal)
    }
}
extension PostDynamicController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        return 50
    }

}
extension PostDynamicController : TZImagePickerControllerDelegate,RxMediaPickerDelegate,UIActionSheetDelegate{
    
    func  bindRx()  {
        self.textView.text = "大叔大婶多"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWithTitle(title: "取消")
        self.navigationItem.leftBarButtonItem!.rx.tap
            .map{_ in self.edit}
            .subscribe(onNext: {[unowned self] (edit) in
                if edit {
            let alertController = UIAlertController(title: "提示", message: "确定要退出编辑吗？", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {_ in
                    
                        self.navigationController?.dismiss(animated: true, completion: nil)

                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                return
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(rx_disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "确定发布")
        let count = textView.rx.text.shareReplay(1)
        count.map{$0!.characters.count > 0  && $0!.characters.count <= self.maxCount && $0!.isEmptyString() == false}.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)

    }
    func initCollectionView()  {
        var photo = Photo()
        photo.image = UIImage(named:"tianjiatup")!
        photo.imagePath = ""
        self.items.append(photo)
        bindViewModel()
        bindRx()
        recoredMp4()
        push()
}

    func bindViewModel() {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        sections.value = [TableSectionModel(model: "", items: self.items)];
        
        dataSource.configureCell =  {[unowned self] (ds, collectionView, indexPath, photo) in
            if self.postType.value == .photo{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostDynamicViewCell", for: indexPath) as! PostDynamicViewCell
                cell.showDeleteImage = self.items.count != indexPath.item + 1
                cell.photo = photo
                return cell
            }
            
            if self.postType.value == .mp3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostDynamicAudioViewCell", for: indexPath) as! PostDynamicAudioViewCell
                
                cell.audioTime = self.audio_length
                self.audioPlayer = cell.aduioPlayer
                return cell
            }
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostDynamicVideoViewCell", for: indexPath) as!
            PostDynamicVideoViewCell
            cell.url = self.mp4Url
            return cell
        }
        dataSource.supplementaryViewFactory =  {_,collectionView ,kind ,indexPath in
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath)
        }
        
        sections.asObservable().bindTo(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            self.textView.endEditing(true)
            if indexPath.item == self.items.count - 1{
                if self.postType.value == .mp4 || self.postType.value == .mp3{
                    return
                }
                 if 10 - self.items.count <= 0{
                    Drop.down("最多选择9张图片", state: .info)
                    return
                }
                if self.imageUrls.value.count > 1{
                    self.showImagePickerController()
                    return
                }
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
               alertController.addAction(UIAlertAction(title: "照片", style: .default, handler: {[unowned self] (_) in
                self.postType.value = .photo
                 self.showImagePickerController()
               }))
                
                alertController.addAction(UIAlertAction(title: "录音", style: .default, handler: {[unowned self] (_) in
                    
                    let recordView = RecordView.recordView()
                    
                    let alert = AlertController.init(view: recordView, style: .alert)
                    self.present(alert, animated: true, completion: nil)
                    recordView.clickButton(clourse: { (button,url,time) in
                        if button == recordView.cancelButton {
                            alert.dismiss(animated: true, completion: nil)
                            return
                        }
                        
                        self.postType.value = .mp3
                        self.mp3Url = url
                        self.audio_length = time
                        var photo = Photo()
                        photo.image = UIImage.init(named: "Free_Play")
                    
                        self.items.removeLast()
                        self.sections.value = [TableSectionModel(model: "", items: self.items)];
                        
                        self.items.insert(photo, at: 0)
                        self.edit = true
                        self.sections.value = [TableSectionModel(model: "", items: self.items)];
                        
                        alert.dismiss(animated: true, completion: nil)
                        
                    })
                    
                    weak var weakAlert = alert
                    alert.touchClourse(aClource: { 
                        if recordView.recordType == .start {
                            weakAlert?.dismiss(animated: true, completion: nil)
                        }
                    })

                    
                }))
                
                alertController.addAction(UIAlertAction(title: "视频", style: .default, handler: {[unowned self] (_) in
                    let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从手机选择", "录制")
                    actionSheet.show(in: self.view)
                }))
                
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler:nil))
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                if self.postType.value == .mp4{
                    let vc = CircleVideoViewController()
                    if let url = self.mp4Url{
                    vc.videoUrl = url
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
                if self.postType.value == .mp3 {
                    
                    return
                }
                
                self.items.remove(at: indexPath.item)
                self.sections.value = [TableSectionModel(model: "", items: self.items)];
                 self.imageUrls.value = self.items.map{$0.imagePath}
            }
        }).addDisposableTo(rx_disposeBag)
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            self.picker = RxMediaPicker(delegate: self)
            self.picker?.selectVideo(source: .photoLibrary, maximumDuration: self.maximumDuration, editable: true)
                .observeOn(MainScheduler.instance)
                .do(onNext: { (url) in
                    self.postType.value = .mp4
                    self.mp4Url = url
                    self.items.removeLast()
                    self.sections.value = [TableSectionModel(model: "", items: self.items)];
                })
                .subscribe { (url) in
                    self.sections.value = [TableSectionModel(model: "", items: [Photo()])];
                }
                .addDisposableTo(rx_disposeBag)

        }else if buttonIndex == 2{
            self.picker = RxMediaPicker(delegate: self)
            self.recordMp4.value = true
        }
    }
    
    func present(picker: UIImagePickerController){
        present(picker, animated: true, completion: nil)
    }
    func dismiss(picker: UIImagePickerController){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func chageSwitch(_ sender: UISwitch) {
        param.original = sender.isOn
    }
    func textViewDidChange(_ textView: UITextView) {
        self.edit = true
    }
    ///发布动态
    fileprivate func push(){
        
        
       let postType =  self.navigationItem.rightBarButtonItem!.rx.tap
        .do(onNext: { (_) in
            
            
            self.navigationItem.rightBarButtonItem!.isEnabled = false
            self.textView.endEditing(true)
            self.param.content = self.textView.text
        })
            .withLatestFrom(self.postType.asObservable())
        .shareReplay(1)
        /*
         photosOrVideosUrl 	是 	string 	图片或者视频地址（多个以英文逗号隔开）
         positionName 	是 	string 	发布位置地点
         lon 	是 	double 	发布位置经度
         lat 	是 	double 	发布位置纬度
         */

        param.content = textView.text

        let activityIndicator =   ActivityIndicator()
        
        
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "发布中...", for: view)).addDisposableTo(rx_disposeBag)
        
        
        let enable =     activityIndicator.asObservable()
            .do(onNext: {[unowned self] (_) in
                self.textView.text = nil
            })
            .map{!$0}
        .shareReplay(1)
        enable.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)
        enable.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)
        
        do{//发布视频
           let upLoadMp4Request =   postType
                .filter{$0 == .mp4}
                .flatMap{_ in RequestProvider.upload(type: .mp4, fileUrl: self.mp4Url!)
            .trackActivity(activityIndicator)
            }
                .shareReplay(1)

            
            let allRequest =   upLoadMp4Request
                .flatMap{$0.unwarp()}
                .do(onNext: { (_) in
                    self.navigationItem.rightBarButtonItem!.isEnabled = false
                })
                .flatMap({ (url) -> Observable<Result<ResponseInfo<RautumnFriendsCircle>>> in
                    self.param.photosOrVideosUrl = url
                    self.param.type = 2
                    return RequestProvider.request(api: ParametersAPI.publishRFC(param: self.param)).mapObject(type: RautumnFriendsCircle.self)
                        .trackActivity(activityIndicator)
                })
                .shareReplay(1)
            

        
            allRequest.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                
            .subscribe(onNext: { (model) in
                Drop.down("发布成功！", state: .success)
                model.userId = UserModel.shared.id
                model.coverUrl.value = (model.rfcPhotosOrSmallVideos.first?.coverUrl)!
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishRFCSuccessNotifation"), object: model)
                self.dismiss(animated: true, completion: nil)
                self.navigationItem.rightBarButtonItem!.isEnabled = true

            })
            .addDisposableTo(rx_disposeBag)
            
            Observable.of(upLoadMp4Request.flatMap{$0.error}.map{$0.domain},
                          allRequest.flatMap{$0.error}.map{$0.domain})
                .merge()
                .subscribe(onNext: { (error) in
                    ARSLineProgress.hide()
                    Drop.down(error)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                })
                .addDisposableTo(rx_disposeBag)
        
        }
        
        // 发布音频
        do {
            
            print("ssssss = \(self.mp3Url)")
            
            self.audioPlayer?.pausePlay()
            
            let upLoadMp3Request =   postType
                .filter{$0 == .mp3}
                .flatMap{_ in RequestProvider.upload(type: .mp3, fileUrl: self.mp3Url!)
                    .trackActivity(activityIndicator)
                }
                .shareReplay(1)
            

            let allRequest =   upLoadMp3Request
                .flatMap{$0.unwarp()}
                .do(onNext: { (_) in
                    self.navigationItem.rightBarButtonItem!.isEnabled = false
                })
                .flatMap({ (url) -> Observable<Result<ResponseInfo<RautumnFriendsCircle>>> in
                    self.param.photosOrVideosUrl = url
                    self.param.type = 3
                    self.param.audio_length = self.audio_length
                    
                    return RequestProvider.request(api: ParametersAPI.publishRFC(param: self.param)).mapObject(type: RautumnFriendsCircle.self)
                        .trackActivity(activityIndicator)
                })
                .shareReplay(1)
            

            allRequest.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()

                .subscribe(onNext: { (model) in
                    
                    Drop.down("发布成功！", state: .success)
                    model.userId = UserModel.shared.id
                    model.rfcPhotosOrSmallVideos.first?.audio_length =  self.audio_length
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishRFCSuccessNotifation"), object: model as? Any)
                    self.dismiss(animated: true, completion: nil)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                    
                })
                .addDisposableTo(rx_disposeBag)
            
            Observable.of(upLoadMp3Request.flatMap{$0.error}.map{$0.domain},
                          allRequest.flatMap{$0.error}.map{$0.domain})
                .merge()
                .subscribe(onNext: { (error) in
                    ARSLineProgress.hide()
                    Drop.down(error)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                })
                .addDisposableTo(rx_disposeBag)
        }
        
        do{ //发布图片
        
          let upLoadImageRequest =   postType
                .filter{$0 == .photo}
                .withLatestFrom(self.imageUrls.asObservable())
                .filter{$0.count != 0}
            .flatMap({ (urls ) -> Observable<Result<String>> in
                var urls = urls
                urls.removeLast()
                return   RequestProvider.upLoadImageUrls(imageUrls: urls)
                    .trackActivity(activityIndicator)
            })
                .shareReplay(1)
          
           let allRequest =   upLoadImageRequest
                .flatMap{$0.unwarp()}
                .flatMap({ (urlStrings) -> Observable<Result<ResponseInfo<RautumnFriendsCircle>>> in
                    self.param.photosOrVideosUrl = urlStrings
                    self.param.type = 1
                   return RequestProvider.request(api: ParametersAPI.publishRFC(param: self.param)).mapObject(type: RautumnFriendsCircle.self)
                    .trackActivity(activityIndicator)
                })
            .shareReplay(1)
         
           Observable.of(upLoadImageRequest.flatMap{$0.error}.map{$0.domain},
                                   allRequest.flatMap{$0.error}.map{$0.domain})
            .merge()
            .subscribe(onNext: { (error) in
                ARSLineProgress.hide()
                Drop.down(error)
                self.navigationItem.rightBarButtonItem!.isEnabled = true
            })
            .addDisposableTo(rx_disposeBag)
            
            allRequest.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                .subscribe(onNext: { (model) in
                    Drop.down("发布成功！", state: .success)
                    model.userId = UserModel.shared.id
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishRFCSuccessNotifation"), object: model as? Any)
                    self.dismiss(animated: true, completion: nil)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                    
                })
                .addDisposableTo(rx_disposeBag)
        }
        
        do{ //发布纯文本
            
           let request =   postType
                .filter{$0 == .photo}
                .withLatestFrom(self.imageUrls.asObservable())
                .filter{$0.count == 0}
                .flatMap{_ in RequestProvider.request(api: ParametersAPI.publishRFC(param: self.param)).mapObject(type: RautumnFriendsCircle.self)
                    .trackActivity(activityIndicator)

            }
                .shareReplay(1)
            
            request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                .subscribe(onNext: { (model) in
                    model.userId = UserModel.shared.id
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishRFCSuccessNotifation"), object: model as? Any)
                    Drop.down("发布成功！", state: .success)
                    self.dismiss(animated: true, completion: nil)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true

                })
                .addDisposableTo(rx_disposeBag)
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    ARSLineProgress.hide()
                    Drop.down(error, state: .error)
                    self.navigationItem.rightBarButtonItem!.isEnabled = true
                })
                .addDisposableTo(rx_disposeBag)
        }
        
        
    }
}
extension PostDynamicController{
    
    fileprivate func recoredMp4(){
        self.recordMp4.asObservable()
            .filter{$0 == true}
            .flatMap { (_) ->  Observable<URL> in
            return  self.picker!.recordVideo(maximumDuration: self.maximumDuration, editable: true)
            }
            .observeOn(MainScheduler.instance)
        .do(onNext: { (url) in
            self.postType.value = .mp4
            self.mp4Url = url
             self.items.removeLast()
            self.sections.value = [TableSectionModel(model: "", items: self.items)];
        })
        .subscribe {[unowned self] (url) in
            self.edit = true
            self.sections.value = [TableSectionModel(model: "", items: [Photo()])];
        }
        .addDisposableTo(rx_disposeBag)
    }
}
extension PostDynamicController: HXPhotoViewControllerDelegate {
    

//    fileprivate func  showImagePickerController() {
//        let imagePicker = TZImagePickerController(maxImagesCount: 10 - self.items.count, columnNumber: 4, delegate: self)
////
//        imagePicker?.didFinishPickingPhotosWithInfosHandle =  {[unowned self ] photos,assets,isSelectOriginalPhoto,infos in
//            for  (index,image) in photos!.enumerated(){
//                let time =  Date().timeIntervalSince1970
//                let fileName = String(format:"%.f-\(index).png",time)
//                if  let filePath = AIFileManager.setObject(UIImageJPEGRepresentation(image, 0.5), forKey: fileName){
//                    var photo = Photo()
//                    photo.image = image
//                    photo.imagePath = filePath
//                    self.items.insert(photo, at: 0)
//                    //                    self.imageUrls.value.append(filePath)
//                }
//
//            }
//            self.edit = true
//            self.sections.value = [TableSectionModel(model: "", items: self.items)];
//            self.imageUrls.value = self.items.map{$0.imagePath}
//
//        }
//        self.present(imagePicker!, animated: true, completion: nil)
//        
//    }

    fileprivate func  showImagePickerController() {
        
        let manager = HXPhotoManager.init(type: HXPhotoManagerSelectedTypePhoto)
        let photoVC = HXPhotoViewController()
        photoVC.delegate = self
        photoVC.manager = manager
        self.present(UINavigationController.init(rootViewController: photoVC), animated: true, completion: nil)
    }
    
    func photoViewControllerDidNext(_ allList: [HXPhotoModel]!, photos: [HXPhotoModel]!, videos: [HXPhotoModel]!, original: Bool) {
        
        for (index, aPhoto) in photos.enumerated() {
            
            let time =  Date().timeIntervalSince1970
            if aPhoto.type == HXPhotoModelMediaTypePhoto {
                
                HXPhotoTools.fetchImageData(forSelectedPhoto: [aPhoto], completion: { (datas) in
                    
                    let fileName = String(format:"%.f-\(index).png",time)
                    if  let filePath = AIFileManager.setObject(datas?.first, forKey: fileName){
                        var photo = Photo()
                        photo.image = aPhoto.thumbPhoto
                        photo.imagePath = filePath
                        self.items.insert(photo, at: 0)
                        self.edit = true
                        self.sections.value = [TableSectionModel(model: "", items: self.items)];
                        self.imageUrls.value = self.items.map{$0.imagePath}
                    }
                })
                
            } else {
                
                HXPhotoTools.fetchImageData(forSelectedPhoto: [aPhoto], completion: { (datas) in
                    
                    let fileName = String(format:"%.f-\(index).gif",time)
                    if let filePath = AIFileManager.setObject(datas?.first, forKey: fileName) {
                        var photo = Photo()
                        photo.image = aPhoto.thumbPhoto
                        photo.imagePath = filePath
                        self.items.insert(photo, at: 0)
                        self.edit = true
                        self.sections.value = [TableSectionModel(model: "", items: self.items)];
                        self.imageUrls.value = self.items.map{$0.imagePath}
                    }
                })
                
            }
        }
        
    }
    
    /**
     点击取消执行的代理
     */
    func photoViewControllerDidCancel() {
        print("取消")
    }

}

class PostDynamicAudioViewCell: UICollectionViewCell {
    
    var playButton = UIButton.init(type: .custom)
    var audioTime:Int! {
        didSet {
            
//            let second = audioTime%60
//            let minute = audioTime/60
//            if minute == 0 {
//                 playButton.setTitle("\(second)\"", for: .normal)
//            } else {
//                playButton.setTitle("\(minute)'\(second)\"", for: .normal)
//            }
//
            
            playButton.setTitle("\(audioTime!)'", for: .normal)
            
            playButton.setTitleColor(UIColor.colorWithHexString("ff8300"), for: .normal)
            
            playButton.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 10.0, bottom: 0.0, right: -(playButton.titleLabel?.width)!)
            playButton.titleEdgeInsets = UIEdgeInsets.init(top: (playButton.imageView?.height)!+5.0, left: -(playButton.imageView?.width)!, bottom: 0.0, right: 0.0)
            
        }
    }
    
    var aduioPlayer = HKPlayer.instance
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hk_initInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化视图
    func hk_initInterface() {
        
        playButton.frame = self.bounds
        self.contentView.addSubview(playButton)
        playButton.layer.cornerRadius = 4.0
        playButton.clipsToBounds = true
        playButton.backgroundColor = UIColor.colorWithHexString("f8f8f8")
        playButton.setImage(UIImage.init(named: "Free_Play"), for: .normal)
        playButton.setImage(UIImage.init(named: "zanting"), for: .selected)
        playButton.imageView?.contentMode = .center
        playButton.contentVerticalAlignment = .center
        
        playButton.addTarget(self, action: #selector(playEvent(sender:)), for: .touchUpInside)
        
    }
    
    @objc fileprivate func playEvent(sender: UIButton) {
     
        sender.isSelected = !sender.isSelected
        if sender.isSelected  {
//            LVRecordTool.shared().playRecordingFile()
            aduioPlayer.playNativeMusic(pathURL: LVRecordTool.shared().recordFileUrl)
            aduioPlayer.playEnd = { _ in
                
                sender.isSelected = false
            }
        } else {
            aduioPlayer.pausePlay()
        }
        
    }
    
}

class PostDynamicVideoViewCell: UICollectionViewCell {
    var player :AVPlayer?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
    }
    var url:URL?{
        didSet{
            guard let url = url else {
                return
            }
             player  =  AVPlayer(url: url)
            player?.volume = 0
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.contentView.bounds
            layer.addSublayer(playerLayer)
             player?.play()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
class PostDynamicViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var deleteImageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        deleteImageView.frame = bounds
    }
    private func configure() {
    
        imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        addSubview(imageView)
        
        deleteImageView = UIImageView()
        deleteImageView.clipsToBounds = true
        deleteImageView.image = UIImage(named:"registerVC_cell_delete_icon")
        deleteImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        deleteImageView.contentMode = UIViewContentMode.scaleAspectFill
        addSubview(deleteImageView)
    }
    var showDeleteImage = true
    var photo:Photo?{
        didSet{
            if let photo = photo{
                deleteImageView.isHidden = !showDeleteImage
                imageView.image = photo.image
                if photo.imageUrl != ""{
                    imageView.sd_setImage(with: URL(string:photo.imageUrl), placeholderImage: placeHolderImage)
                }
            }
        }
    }
}

extension UIImage : IdentifiableType {
    public typealias Identity = UIImage
    
    public var identity: UIImage {
        return self
    }
    
}
func ==(lhs: UIImage, rhs: UIImage) -> Bool {
    return true
}

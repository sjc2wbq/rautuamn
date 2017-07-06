//
//  CreateGroupViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import RxDataSources
import IBAnimatable
import RxSwift
import SwiftLocation
import SimpleAlert

class CreateGroupViewController: UITableViewController {
    var type = 0
    public var groupId:Int?
    var model:GroupDetailsModel?
    fileprivate var imagePicker :AIImagePicker?
 fileprivate var choseActivityCoverSuccess = Variable(false)
    var height : CGFloat = 0.0
    let maxCount = 120
    var photoUrl = ""
    var deletePhotos = [Photo]()
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var groupStyleLabel: UILabel! // 群组类别
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var bottomButton: AnimatableButton!
    @IBOutlet weak var btn_cover: AnimatableButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lb_count: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = UIColor.white
            //            collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 10)
            collectionView.register(RgegisterPhotoViewCell.self, forCellWithReuseIdentifier: "RgegisterPhotoViewCell")
        }
    }
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: (screenW - 28 - 5 * (4 - 1)) / 4, height: (screenW - 28 - 5 * (4 - 1)) / 4)
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 0
        }
    }
    typealias TableSectionModel = AnimatableSectionModel<String, Photo>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var images : Variable<[Photo]> = Variable([])
    var items = [Photo]()
    
  fileprivate  var param = CreateGroupParam()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        do{
        textFiled.delegate = self
            textView.delegate = self
        }
       
        do{
    
            var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                self.param.latitude = "\(loc.coordinate.latitude)"
                self.param.longitude = "\(loc.coordinate.longitude)"
              _ =  Location.reverse(location: loc, onSuccess: { (placemark) in
                    self.param.address = (placemark.addressDictionary?["FormattedAddressLines"] as! NSArray)[0] as! String
                }, onError: { (_) in
                    
                })
            }) { (last, err) in
                print("err \(err)")
            }
            r.onAuthorizationDidChange = { newStatus in
                print("New status \(newStatus)")
            }
        }
        if let _ = groupId{
            title = "编辑群资料"
            
        }else{
            title = "创建群组"
        }
        view.backgroundColor = bgColor
        
        do{

            images.asObservable().subscribe(onNext: {[unowned self] (images) in
                switch images.count {
                case 0...3:
                    self.height = 130 + (UIScreen.main.bounds.size.width - 52) / 4
                case 4...7:
                    self.height = 130 + 2.0 * ((UIScreen.main.bounds.size.width - 52) / 4) + 10
                default:
                    self.height = 130 + 3.0 * ((UIScreen.main.bounds.size.width - 52) / 4) + 20
                }
//                self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
                self.tableView.reloadData()
//                self.tableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .bottom, animated: false)

                }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            
            
            initCollectionView()
            let count = textView.rx.text.map{$0!.characters.count}.shareReplay(1)
            count.map {$0 <= self.maxCount ? UIColor.colorWithHexString("#999999") : UIColor.red}
                .bindTo(lb_count.rx.textColor).addDisposableTo(rx_disposeBag)
        }
        
        fecthData()        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 50
        }else if indexPath.row == 2 {
            return 120
        }else if indexPath.row == 3 {
            return 55 + screenW / 2
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row == 1 else {
            return
        }
        
        
        let alertController = UIAlertController(title: "选择群组类型", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "普通群组", style: .default, handler: {[unowned self] (_) in
            self.groupStyleLabel.text = "普通群组"
            self.param.groupType = "0"
        }))
        
        alertController.addAction(UIAlertAction(title: "家庭群组", style: .default, handler: {[unowned self] (_) in
            self.groupStyleLabel.text = "家庭群组"
            self.param.groupType = "2"
        }))
        
        alertController.addAction(UIAlertAction(title: "朋友群组", style: .default, handler: {[unowned self] (_) in
            self.groupStyleLabel.text = "朋友群组"
            self.param.groupType = "1"
        }))
        
        alertController.addAction(UIAlertAction(title: "其它", style: .default, handler: {[unowned self] (_) in
            self.groupStyleLabel.text = "其它"
            self.param.groupType = "10"
        }))
        
        alertController.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
    
    
        self.present(alertController, animated: true, completion: nil)
        
        
    }
 
}
extension CreateGroupViewController : UITextViewDelegate,UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textView.becomeFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
        textView.endEditing(true)
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
extension CreateGroupViewController:TZImagePickerControllerDelegate{
    func initCollectionView()  {
        var photo = Photo()
        photo.image = UIImage(named:"RegisterChosePhotoIcon")!
        photo.imagePath = ""
        self.items.append(photo)
 
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        sections.value = [TableSectionModel(model: "", items: self.items)];
        
        dataSource.configureCell =  {(ds, collectionView, indexPath, photo) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RgegisterPhotoViewCell", for: indexPath) as! RgegisterPhotoViewCell
            cell.showDeleteImage = self.items.count != indexPath.item + 1
            cell.photo = photo
            return cell
        }
        
        sections.asObservable().bindTo(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
            if indexPath.item == self.items.count - 1{
                if 9 - self.items.count <= 0{
                    Drop.down(NSLocalizedString("RegisterChosePhotoMaxNumber", comment: "最多上传8张照片"))
                    return
                }
                let imagePicker = TZImagePickerController(maxImagesCount: 9 - self.items.count, columnNumber: 4, delegate: self)
                
                imagePicker?.didFinishPickingPhotosWithInfosHandle =  {[unowned self ] photos,assets,isSelectOriginalPhoto,infos in
                    for (index,image ) in photos!.enumerated(){
                        let time =  Date().timeIntervalSince1970
                        let fileName = String(format:"%.f-\(index).jpg",time)
                        if  let filePath = AIFileManager.setObject(UIImageJPEGRepresentation(image, 0.5), forKey: fileName){
                            var photo = Photo()
                            photo.image = image
                            photo.imagePath = filePath
                            self.items.insert(photo, at: 0)
                            self.images.value.append(photo)
                        }
                    }
                    self.sections.value = [TableSectionModel(model: "", items: self.items)];
                }
                
                self.present(imagePicker!, animated: true, completion: nil)
                
            }else{
                let item = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                if item.upId != -1{
                    self.deletePhotos.append(item)
                }
                self.items.remove(at: indexPath.item)
                self.sections.value = [TableSectionModel(model: "", items: self.items)];
                self.images.value.remove(at: indexPath.item)

            }
        }).addDisposableTo(rx_disposeBag)
    }
}
extension CreateGroupViewController{
    ///选择活动封面
    @IBAction func choseActivityCoverAction(_ sender: AnimatableButton) {
        
        
        
        
        self.imagePicker = AIImagePicker()
        self.imagePicker?.allowEditting = true
        self.imagePicker?.imagePickerCompletion = { [unowned self] (image,photoUrl) in
//            sender.setImage(image, for: .normal)
            self.img.image = image
            self.photoUrl = photoUrl!
            self.choseActivityCoverSuccess.value = true
        }
        self.imagePicker?.show(in: self.view)

        
    }
    
    ///创建或者保存
    @IBAction func createAction(_ sender: UIButton) {
        view.endEditing(true)
        guard let groupName = textFiled.text else {
            Drop.down("请输入群名称(8字以内)！", state: .error)
            return
        }
        
        if groupName.characters.count == 0 {
            Drop.down("请输入群名称(8字以内)！", state: .error)
            return
        }
        if groupName.characters.count > 8 {
            Drop.down("群名称最多输入8个字！", state: .error)
            return
        }
        
        guard let introduce = textView.text else {
            Drop.down("请输入群介绍(最多120字)！", state: .error)
            return
        }
        
        if introduce.characters.count == 0 {
            Drop.down("请输入群介绍(最多120字)！", state: .error)
            return
        }
        
        if introduce.characters.count > 120 {
            Drop.down("群介绍最多输入120个字！", state: .error)
            return
        }
        if photoUrl == ""{
            if groupId == nil{
                Drop.down("请选择活动封面！", state: .error)
                return
            }
        }
        if items.count == 1 {
            Drop.down("请选择群相册！", state: .error)
            return
        }
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在提交...", for: view)).addDisposableTo(rx_disposeBag)
        
        
        activityIndicator.asObservable()
            .map{!$0}.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)
        


        
        if let groupId = groupId {//编辑群资料
            
            //上传头像
            let uploadImageRequest = RequestProvider.upload(type: .png, data: UIImageJPEGRepresentation( img.image!, 0.5)!)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            var param = EditGroupParam()
            param.name = groupName
            param.introduce = introduce
            param.rgId = groupId
            var rgaIds = ""
            self.deletePhotos.forEach({ (photo) in
                rgaIds += "\(photo.upId),"
            })
            
                   //删除群相册
            let deletePhotosRequest = RequestProvider.request(api: ParametersAPI.deleteRGA(rgId: groupId, rgaIds:rgaIds != "" ? (rgaIds as NSString).substring(to: (rgaIds as NSString).length - 1) : "")).mapObject(type: EmptyModel.self)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
             var photos = items
                photos.removeLast()
            var imagePaths = [String]()
            photos.forEach({ (photo) in
                if photo.imagePath != ""{
                  imagePaths.append(photo.imagePath)
                }
            })
            //上传群相册图片
            let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls:  imagePaths)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            
            if deletePhotos.count == 0 { //不删除相册图片
                
             let request =  Observable.zip(uploadImageRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()}){($0,$1)}
                
                .flatMap({ (info) -> Observable<Result<ResponseInfo<EmptyModel>>> in
                    param.coverPhotoUrl = info.0
                    param.rauGroupAlbums = info.1
                    
                    
                    print("coverPhomtouer = \(param)")
                    
                    
                     return RequestProvider.request(api: ParametersAPI.editGroup(param: param)).mapObject(type: EmptyModel.self)
                })
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                request.flatMap{$0.unwarp()}.map{$0.result_data}
                    
                    .subscribe(onNext: {[unowned self] (_) in
                        
                        Drop.down("修改成功！", state: .success)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateGroupSuccessNotifation"), object: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                
                Observable.of(uploadImageRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
                    .merge()
                    .subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            
                
                
            }else{ //删除相册图片
                
                let request =  Observable.zip(uploadImageRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()},deletePhotosRequest.flatMap{$0.unwarp()}){($0,$1,$2)}
                    .flatMap({ (info) -> Observable<Result<ResponseInfo<EmptyModel>>> in
                        param.coverPhotoUrl = info.0
                        param.rauGroupAlbums = info.1
                        return RequestProvider.request(api: ParametersAPI.editGroup(param: param)).mapObject(type: EmptyModel.self)
                    })
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                request.flatMap{$0.unwarp()}.map{$0.result_data}
                    .subscribe(onNext: {[unowned self] (_) in
                        
                        Drop.down("修改成功！", state: .success)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateGroupSuccessNotifation"), object: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                        
                        }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                
                Observable.of(uploadImageRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
                    .merge()
                    .subscribe(onNext: { (error) in
                        Drop.down(error, state: .error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                    }
        }else{  //创建群组
     
            param.name = groupName
            param.introduce = introduce
            //上传头像
            let uploadImageRequest = RequestProvider.upload(type: .png, fileUrl: URL(string:photoUrl)!)
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            
            
            //上传群相册图片
            let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls:  items.dropLast().map{$0.imagePath})
                .trackActivity(activityIndicator)
                .shareReplay(1)

          let request =   Observable.zip(uploadImageRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()}){($0,$1)}.flatMap({ (info) -> Observable<Result<ResponseInfo<Raugroup>>> in
                self.param.coverPhotoUrl = info.0
                self.param.rauGroupAlbums = info.1
            
                print("parm = \(self.param)")
            
            
                return  RequestProvider.request(api: ParametersAPI.createGroup(param:self.param)).mapObject(type: Raugroup.self)
            })
            .trackActivity(activityIndicator)
            .shareReplay(1)
            
            
            request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                .subscribe(onNext: {[unowned self] (model) in
                    
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createGroupSuccessNotifation"), object: model as? Any)
                    _ = self.navigationController?.popViewController(animated: true)
                    Drop.down("创建群组成功！", state: .success)
            
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            Observable.of(uploadImageRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
                .merge()
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
  
    }
}
extension CreateGroupViewController{
    fileprivate func fecthData(){
        guard let groupId = groupId else {
            return
        }
        bottomButton.setTitle("保存", for: .normal)
        let activityIndicator = ActivityIndicator()
        
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
        
        let request = RequestProvider.request(api: ParametersAPI.groupDetails(groupId: groupId)).mapObject(type: GroupDetailsModel.self)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: { (model) in
                self.model = model
                self.textFiled.text = model.name
                self.textView.text = model.introduce
                self.btn_cover.sd_setImage(with: URL(string:model.coverPhotoUrl), for: .normal, placeholderImage: placeHolderImage)
                model.rauGroupAlbums.forEach({ (album) in
                    var photo = Photo()
                        photo.upId = album.id
                        photo.imageUrl = album.url
                    self.items.insert(photo, at: 0)
                })
                self.sections.value = [TableSectionModel(model: "", items: self.items)];
                self.images.value +=  model.rauGroupAlbums.map{Photo(image: nil, imageUrl: $0.url)}
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        
    }

}

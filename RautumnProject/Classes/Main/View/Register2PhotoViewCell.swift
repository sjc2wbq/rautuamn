//
//  PhotoViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 20112/12/30.
//  Copyright © 20112年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import Eureka
import RxSwift
import RxDataSources
import IBAnimatable
struct Photo {
    var image:UIImage?
    var imagePath:String = ""
    var imageUrl:String = ""
    var upId = -1
//    var urls = UploadImages(type: .png, url: "")
    init() {}
    init(image:UIImage?,imageUrl:String) {
        self.image = image
        self.imageUrl = imageUrl
    }

}
extension Photo: IdentifiableType,Equatable ,Hashable {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return 1
    }
    var identity: Int {
        return 1
    }
}
func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.imagePath == rhs.imagePath
}

enum PhotoType {
    case userPhoto
    case activity
}
class Register2PhotoViewCell: Cell<Set<Photo>>,CellType ,TZImagePickerControllerDelegate{
    @IBOutlet weak var lb_desc: AnimatableLabel!
    @IBOutlet weak var w: NSLayoutConstraint!
    var maxCount = 12{
        didSet{
            let attributeTitle = NSMutableAttributedString(string: maxCount == 8 ? "上传照片(最多\(maxCount)张)" : "上传照片(可选，最多\(maxCount)张)")
            attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 4  ))
            attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(4, attributeTitle.length - 4))
            lb_desc.attributedText = attributeTitle
            w.constant = lb_desc.text!.width(14, height: 33) + 15
        }
    }
    var newValue: Set<Photo> = Set<Photo>()
    var photoType : PhotoType = .userPhoto
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: (screenW - 28 - 5 * (4 - 1)) / 4, height: (screenW - 28 - 5 * (4 - 1)) / 4)
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 0
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = UIColor.white
//            collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 10)
            collectionView.register(RgegisterPhotoViewCell.self, forCellWithReuseIdentifier: "RgegisterPhotoViewCell")
        }
    }
    
    typealias TableSectionModel = AnimatableSectionModel<String, Photo>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var photos : Variable<[Photo]> = Variable([])
    var items = [Photo]()
    var deleteImageIds = [Int]()
    override func awakeFromNib() {
        super.awakeFromNib()
            selectionStyle = UITableViewCellSelectionStyle.none
         initCollectionView()
        

    }
    public func setSections(photos:[Photo]){
        photos.forEach {[unowned self] (photo) in
            self.items.insert(photo, at: 0)
        }
        self.photos.value = photos
    
        self.sections.value = [TableSectionModel(model: "", items: self.items)]
    }
    override func setup() {
        super.setup()

        photos.asObservable().subscribe(onNext: {[unowned self] (photos) in
            switch photos.count {
            case 0...3:
                self.height = {60 + (UIScreen.main.bounds.size.width - 52) / 4}
                break
            case 4...7:
                self.height = {60 + 2.0 * ((UIScreen.main.bounds.size.width - 52) / 4) + 10}
                break
            case 8...11:
                self.height = {60 + 3.0 * ((UIScreen.main.bounds.size.width - 52) / 4) + 20}
            case 12:
                self.height = {60 + 4.0 * ((UIScreen.main.bounds.size.width - 52) / 4) + 20}
            default: break
            }
            log.info("photos.count------\(photos.count)")

             log.info("self.row.value ===== \(self.row.value)")
            self.formViewController()?.tableView?.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_reusableDisposeBag)
    }
    
    func initCollectionView()  {
      
        var photo = Photo()
        photo.image = UIImage(named:"RegisterChosePhotoIcon")!
        photo.imagePath = ""
        self.items.append(photo)
        bindViewModel()
    }
    
    func bindViewModel() {
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
                if self.maxCount + 1 - self.items.count <= 0{
                    Drop.down("最多上传\(self.maxCount)张照片", state: .error)
                    return
                }
                let imagePicker = TZImagePickerController(maxImagesCount: self.maxCount + 1 - self.items.count, columnNumber: 4, delegate: self)
                imagePicker?.didFinishPickingPhotosWithInfosHandle =  {[unowned self ] photos,assets,isSelectOriginalPhoto,infos in
                    for (index,image) in photos!.enumerated(){
                        let time =  Date().timeIntervalSince1970
                        let fileName = String(format:"%.f-\(index).jpg",time)
                        if  let filePath = AIFileManager.setObject(UIImageJPEGRepresentation(image, 0.5), forKey: fileName){
                            var photo = Photo()
                            photo.image = image
                            photo.imagePath = filePath
                            self.items.insert(photo, at: 0)
                            self.newValue.insert(photo)
                        }
                    }
                 
                    self.sections.value = [TableSectionModel(model: "", items: self.items)];
                    var items = self.items
                    items.removeLast()
                    self.photos.value = items
                    self.row.value = self.newValue
                }
                self.viewController?.present(imagePicker!, animated: true, completion: nil)
            }else{
                let item = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
                self.items.remove(at: indexPath.item)
                self.sections.value = [TableSectionModel(model: "", items: self.items)];
                var items = self.items
                self.row.value?.remove(item)
                items.removeLast()
                self.photos.value = items
                if item.upId != -1{
                    self.deleteImageIds.append(item.upId)
                }
            }
        }).addDisposableTo(rx_disposeBag)
    }
}
final class RgegisterPhotoRow: Row<Register2PhotoViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<Register2PhotoViewCell>(nibName: "Register2PhotoViewCell")
    }
}
class RgegisterPhotoViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    var deleteImageView: UIImageView!

    
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
                if photo.imageUrl == ""{
                    imageView.image = photo.image
                }else{
                    imageView.sd_setImage(with: URL(string:photo.imageUrl), placeholderImage: placeHolderImage)
                }
            }
        }
    }
 
}

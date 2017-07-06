//
//  CreateActivtyViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
// 创建活动

import UIKit
import Eureka
import RxSwift
import SwiftLocation
import SwiftyDrop
class CreateActivtyViewController: FormViewController {
    let footerView = CreateActivtyFooterView.footerView()
    var param = PublishActivityParam()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "组局"
        tableView?.backgroundColor = bgColor
        view.backgroundColor = UIColor.white
        tableView?.sectionFooterHeight = 0
        tableView?.sectionHeaderHeight = 0
    tableView?.tableFooterView = footerView
        DateTimeRow.defaultRowInitializer = { row in row.minimumDate = Date()
            DateRow.defaultCellUpdate = { cell , row in
                cell.textLabel?.textColor = .black
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.detailTextLabel?.textColor = UIColor.black
            }
        }
        TextRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = .black
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.textField.font = UIFont.systemFont(ofSize: 15)
        }
        
        do{
            var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                self.param.latitude = "\(loc.coordinate.latitude)"
                self.param.longitude = "\(loc.coordinate.longitude)"
            }) { (last, err) in
                print("err \(err)")
            }
            r.onAuthorizationDidChange = { newStatus in
                print("New status \(newStatus)")
            }
        }

        
        form +++
            
            Section()
            
            <<< TextRow() {
                $0.title = "局长"
                $0.placeholder = "6个字符以内"
                $0.value = UserModel.shared.nickName.value
                $0.disabled = true
        }
        
            +++  Section()
            <<< TextRow() {
                $0.title = "局长电话"
                $0.placeholder = "输入组局人电话"
                $0.tag = "phone"
                $0.cell.textField.keyboardType = UIKeyboardType.phonePad
        }
        
            +++  Section()
            
            <<< TextRow() {
                $0.title = "活动名称"
                $0.placeholder = "输入活动名称(12字以内)"
                $0.tag = "activityName"
        }
        
        +++ Section()
        
            <<< DateTimeRow() {[unowned  self] in
                $0.title = "时间选择"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                formatter.timeStyle = .short
                $0.dateFormatter = formatter
                $0.baseCell.accessoryView = self.accessView("arrowDownIcon")
                $0.tag = "time"
        }
            
            +++  Section()
            <<< TextRow() {
                $0.title = "地点"
                $0.placeholder = "输入详细的举办地点"
                $0.tag = "address"
        }
        
            +++  Section()
            <<< TextRow() {
                $0.title = "分类"
                $0.placeholder = "输入活动类别，例如：聚餐(4字以内)"
                $0.tag = "category"
        }
        
            +++  Section()
            <<< TextRow() {
                $0.title = "人数上限"
                $0.placeholder = "输入最多报名人数"
                $0.tag = "personNumber"
                $0.cell.textField.keyboardType = UIKeyboardType.numberPad

        }
        
        +++ Section(footer: "男女不限，费用均摊，适当管理费除外余额返还")
            <<< TextRow() {
                $0.title = "预收费用"
                $0.tag = "price"
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
                label.text = "元"
                label.textAlignment = .right
                label.font = UIFont.systemFont(ofSize: 15)
                $0.cell.accessoryView = label
                $0.cell.textField.keyboardType = UIKeyboardType.numberPad
        }
        
        +++ Section()
        
            <<< CreateActivtyCoverRow(){
            $0.tag = "activtyCoverPhoto"
            }
        
            +++  Section()
            
            <<< RgegisterPhotoRow(){
                $0.cell.maxCount = 8
                $0.tag = "photos"
        }
        
            +++  Section()
        
            <<< RgegisterTextViewRow(){
                $0.cell.height = { 130 }
                $0.title = "活动描述"
                $0.tag = "activityDesc"
        }
        
        do{
            footerView.btn_done.addTarget(self, action: #selector(pushAction), for: UIControlEvents.touchUpInside)
          }

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    ///确定发布
    @objc fileprivate func pushAction(){
        let phoneRow =  form.rowBy(tag: "phone") as? TextRow
        let activityNameRow =  form.rowBy(tag: "activityName") as? TextRow
        let timeRow =  form.rowBy(tag: "time") as? DateTimeRow
        let addressRow =  form.rowBy(tag: "address") as? TextRow
        let categoryRow =  form.rowBy(tag: "category") as? TextRow
        let personNumberRow =  form.rowBy(tag: "personNumber") as? TextRow
        let priceRow =  form.rowBy(tag: "price") as? TextRow
        let activtyCoverPhotoRow =  form.rowBy(tag: "activtyCoverPhoto") as? CreateActivtyCoverRow
        let photosRow =  form.rowBy(tag: "photos") as? RgegisterPhotoRow
        let activityDescRow =  form.rowBy(tag: "activityDesc") as? RgegisterTextViewRow


       
        guard let phone = phoneRow?.value else {
            Drop.down("局长电话不能为空！", state: .error)
            return
        }
        if !phone.isMobileNumber(){
            Drop.down("局长电话的号码有误！", state: .error)
            return
        }
        
        guard let activityName = activityNameRow?.value else {
            Drop.down("活动名称不能为空！", state: .error)
            return
        }
        
        if activityName.characters.count > 12{
            Drop.down("活动名称最多12字！", state: .error)
        return
        }
        guard let time = timeRow?.value else {
            Drop.down("请选择活动时间！", state: .error)
            return
        }
        
        guard let address = addressRow?.value else {
            Drop.down("活动举办地点不能为空！", state: .error)
            return
        }
        
        
        guard let category = categoryRow?.value else {
            Drop.down("活动分类不能为空！", state: .error)
            return
        }
        if category.characters.count > 4 {
            Drop.down("活动分类最多为4字！", state: .error)
            return
        }
        
        guard let personNumber = personNumberRow?.value else {
            Drop.down("人数上限不能为空！", state: .error)
            return
        }
        
        guard let price = priceRow?.value else {
            Drop.down("预收费用不能为空！", state: .error)
            return
        }
        
        guard let activtyCoverPhoto = activtyCoverPhotoRow?.value else {
            Drop.down("请选择活动封面！", state: .error)
            return
        }
        
        guard let photos = photosRow?.value else {
            Drop.down("请选择活动宣传图(最多8张)！", state: .error)
            return
        }
        if photos.count == 0 {
            Drop.down("请选择活动宣传图(最多8张)！", state: .error)
            return
        }
        guard let activityDesc = activityDescRow?.value else {
            Drop.down("活动描述不能为空！", state: .error)
            return
        }

        param.authorPhone = phone
        param.name = activityName
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        param.activityDateTime = format.string(from: time)
        param.place = address
        param.label = category
        param.expense = Double(price)!
        param.activityDetails = activityDesc
    param.enrollmentCeiling = Int(personNumber)!
        
        let activityIndicator = ActivityIndicator()

        activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在发布中...", for: view)).addDisposableTo(rx_disposeBag)
        
        activityIndicator.asObservable()
            .map{!$0}.bindTo(self.view.rx.isUserInteractionEnabled).addDisposableTo(rx_disposeBag)
        
        let uploadImgRequest =   RequestProvider.upload(type: .png, fileUrl: URL(string: activtyCoverPhoto)!)
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
    
        let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls: Array(photos.map{$0.imagePath}))
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        
        
        let request = Observable.zip(uploadImgRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()}){($0,$1)}
        .flatMap { (info) -> Observable<Result<ResponseInfo<Rauactivitie>>>  in
            self.param.coverPhotoUrl = info.0
            self.param.rauActivityPictures = info.1
            return  RequestProvider.request(api: ParametersAPI.publishActivity(param: self.param)).mapObject(type: Rauactivitie.self)

        }
            .trackActivity(activityIndicator)
            .shareReplay(1)
        
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { (model) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "publishActivitySuccessNotifation"), object: model as? Any)
            _ = self.navigationController?.popViewController(animated: true)
            Drop.down("发布成功！", state: .success)
        })
            .addDisposableTo(rx_disposeBag)
        
        Observable.of(uploadImgRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
            .merge()
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            })
            .addDisposableTo(rx_disposeBag)
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 7 {
            return 30
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
}
extension CreateActivtyViewController{
    fileprivate func accessView(_ imageNamed:String) -> UIImageView{
        let imageView = UIImageView()
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageView.contentMode = .center
        imageView.image = UIImage(named: imageNamed)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        return imageView
    }
}

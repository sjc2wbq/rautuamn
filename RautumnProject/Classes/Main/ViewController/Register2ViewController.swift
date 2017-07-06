//
//  Register2TableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/28.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import ARSLineProgress
import UIKit
import Eureka
import SDWebImage
import ObjectMapper
import RxSwift
import SwiftyDrop
import FDFullscreenPopGesture
class Register2ViewController: FormViewController {
    public var userPhone = ""
    public var vcode = ""
    public var password = ""
    var editUserInfo = false
    var edited = false
    var ruleRequired = RuleRequired<String>()
    let headerView = Register2HeaderView.headerView()
    let footerView = Register2FooterView.footerView()
    override func viewDidLoad() {
        ruleRequired.validationError = ValidationError(msg: NSLocalizedString("NoEmpty", comment: "不能为空"))
        super.viewDidLoad()
        title = NSLocalizedString("Register2Title", comment: "")
        initTableView()
        event()
        uploadImages()

        footerView.btn.setTitle(editUserInfo == true ? "保存" : "完成注册并登录", for: .normal)
        
        do{
            self.navigationItem.hidesBackButton = true
            self.fd_interactivePopDisabled = true
            let button = UIButton(type: .system)
            button.setTitle("返回   ", for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
                let item = UIBarButtonItem(customView: button)
    
            self.navigationItem.leftBarButtonItem = item
            button.rx.tap
                .map{_ in self.edited}
                .subscribe(onNext: {[unowned self] (chosed) in
                    self.view.endEditing(true)
                    if chosed {
                        let vc = UIAlertController(title: nil, message: "您确认要退出编辑？", preferredStyle: .alert)
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1.0, animations: {[unowned self] in
            self.headerView.layer.transform = CATransform3DIdentity
        })
        
    }
}
extension Register2ViewController{
    fileprivate func initTableView(){

        if editUserInfo {
            headerView.img_choseHeaderImg.sd_setImage(with: URL(string:UserModel.shared.headPortUrl.value), placeholderImage: defaultHeaderImage)
            UserModel.shared.userIDCards.forEach({ (idCard) in
                if idCard.type == 1{
                    footerView.btn_idCardZ.sd_setImage(with: URL(string:idCard.url), for: .normal, placeholderImage: defaultHeaderImage)
                }else{
                    footerView.btn_idCardF.sd_setImage(with: URL(string:idCard.url), for: .normal, placeholderImage: defaultHeaderImage)
                }
            })
        }
        tableView?.separatorStyle = .none
        tableView?.tableHeaderView = headerView
        tableView?.tableFooterView = footerView
        tableView?.backgroundColor = UIColor.white

        DateRow.defaultRowInitializer = { row in row.minimumDate = Date()
            DateRow.defaultCellUpdate = { cell , row in
                cell.textLabel?.textColor = .black
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.detailTextLabel?.textColor = UIColor.black
            }
        }
   
        NameRow.defaultCellUpdate = { cell, row in
            cell.textField.textColor = .black
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.textField.font = UIFont.systemFont(ofSize: 15)
            cell.textField.keyboardType = .default

        }
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .black }
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
            
        }
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
        
        DateRow.defaultRowInitializer = { row in row.maximumDate = Date() }

    
        form +++
            
          Section()
        
            <<< NameRow() { [unowned self] in
                $0.title = NSLocalizedString("RegisterNickName", comment: "昵称")
                $0.placeholder = "6个字符以内"
                $0.tag = "nickName"
                if self.editUserInfo {
                    $0.value = UserModel.shared.nickName.value
                }
                }
            .onChange({[unowned self] (_) in
                self.edited = true
            })
            +++  Section()

            <<< MultipleSelectorRow<String>() {  [unowned self]   (row : MultipleSelectorRow<String>) -> Void in
                row.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                row.baseCell.layer.borderWidth = 0.5
                row.baseCell.clipsToBounds = true
                row.baseCell.layer.cornerRadius = 4
                row.baseCell.accessoryView = self.accessView("rightArrow")
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("RegisterLanguage", comment: "语言"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 2))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(2, attributeTitle.length - 2))
                row.attributeTitle = attributeTitle
                row.options = [NSLocalizedString("Chinese", comment: "中文"),
                              NSLocalizedString("English", comment: "英语"),
                              NSLocalizedString("French", comment: "法语"),
                              NSLocalizedString("Spanish", comment: "西班牙语"),
                              NSLocalizedString("Portuguese", comment: "葡萄牙语"),
                              NSLocalizedString("Arabic", comment: "阿拉伯语"),
                              NSLocalizedString("Russian", comment: "俄语"),
                              NSLocalizedString("Japanese", comment: "日语"),
                              NSLocalizedString("Chinkoreanese", comment: "韩语")]
                row.value = [NSLocalizedString("Chinese", comment: "中文")]
                row.tag = "language"
                if self.editUserInfo {
                    var value = Set<String>()
                UserModel.shared.language.components(separatedBy: ",").forEach({ (t ) in
                               value.insert(t)
                })
                    row.value = value
                }
                }
                .onPresent { from, to in
                    let item = UIBarButtonItem.itemWithTitle(title: "完成")
                    item.rx.tap
                        .subscribe(onNext: {[unowned self] (_) in
                            if let value = to.row.value{
                                if value.count == 0{
                                    Drop.down("至少选择1个！", state: .info)
                                    
                                }else
                                if value.count > 5{
                                    Drop.down("最多选择5个！", state: .info)
                                    
                                }else{
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }else{
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            
                            }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(to.rx_disposeBag)
                    to.navigationItem.rightBarButtonItem = item
                }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })

//

            +++  Section()

            <<< PickerInputRow<String>(NSLocalizedString("RegisterHeight", comment: "身高")) { [unowned self]  (row : PickerInputRow<String>) -> Void in
                row.title = row.tag
              
                row.baseCell.accessoryView = self.accessView("arrowDownIcon")
                row.displayValueFor = { (rowValue: String?) in
                    return "\(rowValue!)cm"
                }
                row.options = []
                for i in 150...200{
                    row.options.append("\(i)")
                }
                row.value = row.options[0]
                row.tag = "height"

                row.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                row.baseCell.layer.borderWidth = 0.5
                row.baseCell.clipsToBounds = true
                row.baseCell.layer.cornerRadius = 4
                if self.editUserInfo {
                    row.value = "\(UserModel.shared.height)"
                }

        }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })

        
            +++  Section()
            
            <<< DateRow() { [unowned self] in
                $0.title = NSLocalizedString("Bir", comment: "出生日期")
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                formatter.locale = .current
//                formatter.dateStyle = .long
                $0.dateFormatter = formatter
                $0.baseCell.accessoryView = self.accessView("arrowDownIcon")
                $0.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                $0.baseCell.layer.borderWidth = 0.5
                $0.baseCell.clipsToBounds = true
                $0.baseCell.layer.cornerRadius = 4
                $0.tag = "bir"
                if self.editUserInfo {
                    $0.value = formatter.date(from: UserModel.shared.dateOfBirth)
                }

        }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })

            +++  Section()
            
            <<< RegisterSexRow(){ [unowned self] in
                $0.tag = "sex"
                if self.editUserInfo {
                    if UserModel.shared.sex == 1 {
                        $0.cell.btnAction($0.cell.btn1)
                    }else{
                        $0.cell.btnAction($0.cell.btn2)
                    }
                    $0.value = UserModel.shared.sex == 1 ? "男" : "女"
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            
            <<< RgegisterLandlordRow(){ [unowned self] in
                $0.tag = "landlord"
                if self.editUserInfo {
                    $0.value = UserModel.shared.emotion
                    if $0.value == "找男友"{
                         $0.cell.btnAction($0.cell.btn1)
                        $0.value = $0.cell.btn1.titleLabel!.text!
                    }else if $0.value == "找女友"{
                        $0.cell.btnAction($0.cell.btn2)
                        $0.value = $0.cell.btn2.titleLabel!.text!
                    }else{
                        $0.cell.btnAction($0.cell.btn3)
                        $0.value = $0.cell.btn3.titleLabel!.text!
                    }
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            <<< PickerInputRow<String>(NSLocalizedString("Constellation", comment: "星座")) { [unowned self] (row : PickerInputRow<String>) -> Void in
                row.title = row.tag

                row.baseCell.accessoryView = self.accessView("arrowDownIcon")

                row.displayValueFor = { (rowValue: String?) in
                    return rowValue
                }

                row.options = [NSLocalizedString("Virgo", comment:"处女座"),
                               NSLocalizedString("Leo", comment:"狮子座"),
                               NSLocalizedString("Pisces", comment:"双鱼座"),
                               NSLocalizedString("Scorpio", comment:"蝎子座"),
                               NSLocalizedString("Capricorn", comment:"魔羯座"),
                               NSLocalizedString("Taurus", comment:"金牛座"),
                               NSLocalizedString("cancer", comment:"巨蟹座"),
                               NSLocalizedString("Gemini", comment:"双子座"),
                               NSLocalizedString("Libra", comment:"天秤座"),
                               NSLocalizedString("Aquarius", comment:"水瓶座"),
                               NSLocalizedString("Aries", comment:"白羊座"),
                               NSLocalizedString("sagittarius", comment:"射手座")]
                
                row.value = row.options[0]
                row.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                row.baseCell.layer.borderWidth = 0.5
                row.baseCell.clipsToBounds = true
                row.baseCell.layer.cornerRadius = 4
                row.tag = "constellation"
                if self.editUserInfo {
                    row.value = UserModel.shared.constellation
                }

        }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            
            <<< RgegisterTextViewRow(){ [unowned self] in
                $0.cell.height = { 130 }
                $0.title = NSLocalizedString("Motto", comment: "座右铭")
                $0.tag = "motto"
                if self.editUserInfo {
                    $0.cell.tf.text = UserModel.shared.motto
                    $0.value = UserModel.shared.motto
                }

        }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
                   +++  Section()
            
            <<< RgegisterJobAndHobbyRow()
                
            +++  Section()
            
            <<< OccupationRow(){ [unowned self] in
                $0.title = "职业"
                $0.noValueDisplayText = "选择职业"
                $0.baseCell.accessoryView = self.accessView("rightArrow")
                $0.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                $0.baseCell.layer.borderWidth = 0.5
                $0.baseCell.clipsToBounds = true
                $0.baseCell.layer.cornerRadius = 4
                $0.tag = "job"
                if self.editUserInfo {
                    $0.value = UserModel.shared.occupation
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()

            <<< RegisterSingleRow(){  [unowned self] in
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("FindJob", comment: "是否找工作(可选)"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 5))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(5, attributeTitle.length - 5))
                $0.attributeTitle = attributeTitle

                
                $0.tag = "findJob"
                if self.editUserInfo {
                    if UserModel.shared.changeJob{
                         $0.cell.btnAction($0.cell.btn1)
                    }else{
                        $0.cell.btnAction($0.cell.btn2)
                    }
                    $0.value = UserModel.shared.mutualTourism == true ? "是" : "否"
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            
            <<< MultipleSelectorRow<String>() { [unowned self] in
                $0.baseCell.accessoryView = self.accessView("rightArrow")
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("Hobby", comment: "爱好"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 2))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(2, attributeTitle.length - 2))
                $0.attributeTitle = attributeTitle
                $0.options = NSArray(contentsOfFile: Bundle.main.path(forResource: "hobby2", ofType: "plist")!) as! [String]
                $0.noValueDisplayText = NSLocalizedString("ChoseHobby", comment: "请选择您的爱好")
                $0.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                $0.baseCell.layer.borderWidth = 0.5
                $0.baseCell.clipsToBounds = true
                $0.baseCell.layer.cornerRadius = 4
                $0.tag = "hobby"
                
//                $0.presentationMode = PresentationMode.show(controllerProvider: $0.presentationMode, onDismiss: { (vc) in
//                  log.info("presentationMode.......")
//                })
                if self.editUserInfo {
                    var value = Set<String>()
                    UserModel.shared.hobby.components(separatedBy: ",").forEach({ (t ) in
                        value.insert(t)
                    })
                    $0.value = value
                    }
                }
                .onPresent { from, to in
                    let item = UIBarButtonItem.itemWithTitle(title: "完成")
                    item.rx.tap
                    .subscribe(onNext: {[unowned self] (_) in
                       if let value = to.row.value{
                        if value.count == 0{
                            Drop.down("至少选择1个！", state: .info)
                            
                        }else
                            if value.count > 5{
                                Drop.down("最多选择5个！", state: .info)
                                
                            }else{
                        _ = self.navigationController?.popViewController(animated: true)
                        }
                       }else{
                        _ = self.navigationController?.popViewController(animated: true)
                        }
                   
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(to.rx_disposeBag)
                    to.navigationItem.rightBarButtonItem = item
            }
            
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            

            +++  Section()
            
            <<< CityRow(){ [unowned self] in
                $0.baseCell.accessoryView = self.accessView("rightArrow")
                let attributeTitle = NSMutableAttributedString(string: "常住城市(必选、单选)")
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 4))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(4, attributeTitle.length - 4))
                $0.attributeTitle = attributeTitle
                
                $0.noValueDisplayText = "选择城市"
                $0.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                $0.baseCell.layer.borderWidth = 0.5
                $0.baseCell.clipsToBounds = true
                $0.baseCell.layer.cornerRadius = 4
                $0.tag = "city"
                var ruleMinLength = RuleMinLength(minLength: 1)
                ruleMinLength.validationError = ValidationError(msg: NSLocalizedString("NickNameMax6Count", comment: "最多输入6个字符"))
                $0.add(rule: ruleMinLength)
                $0.validationOptions = .validatesOnChange
                if self.editUserInfo {
                    $0.value = UserModel.shared.permanentCity
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })

            +++  Section()
            
            <<< RegisterSingleRow(){ [unowned self] in
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("ToLandlord", comment: "我做旅行地主(可选"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 6))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(6, attributeTitle.length - 6))
                $0.attributeTitle = attributeTitle

                $0.tag = "toLandlord"
                if self.editUserInfo {
                    if UserModel.shared.mutualTourism{
                        $0.cell.btnAction($0.cell.btn1)
                    }else{
                        $0.cell.btnAction($0.cell.btn2)
                    }
                    $0.value = UserModel.shared.mutualTourism == true ? "是" : "否"
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            
            <<< RgegisterTextViewRow(){ [unowned self] in
                $0.cell.height = { 130 }
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("Hearsay", comment: "你所擅长的技能(可填)"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 7))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(7, attributeTitle.length - 7))
                $0.attributeTitle = attributeTitle
                $0.tag = "hearsay"
                if self.editUserInfo {
                    $0.cell.tf.text = UserModel.shared.autograph
                    $0.value = UserModel.shared.autograph
                }
        }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })

            +++  Section()
            
            <<< MultipleSelectorRow<String>() { [unowned self] in
                $0.baseCell.accessoryView = self.accessView("rightArrow")
                let attributeTitle = NSMutableAttributedString(string: NSLocalizedString("Certificate", comment: "证书"))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.black], range: NSMakeRange(0, 3))
                attributeTitle.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.colorWithHexString("#999999")], range: NSMakeRange(3, attributeTitle.length - 3))
                $0.attributeTitle = attributeTitle

                $0.options = NSArray(contentsOfFile: Bundle.main.path(forResource: "certificate2", ofType: "plist")!) as! [String]
                $0.noValueDisplayText = NSLocalizedString("Chosecertificate", comment: "请选择您的证书")
                $0.baseCell.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
                $0.baseCell.layer.borderWidth = 0.5
                $0.baseCell.clipsToBounds = true
                $0.baseCell.layer.cornerRadius = 4
                $0.tag = "certificate"
                if self.editUserInfo {
                    var value = Set<String>()
                    UserModel.shared.vocationalCertificate.components(separatedBy: ",").forEach({ (t ) in
                        value.insert(t)
                    })
                    $0.value = value
                }

                }
                
                .onPresent { from, to in
                    let item = UIBarButtonItem.itemWithTitle(title: "完成")
                    item.rx.tap
                        .subscribe(onNext: {[unowned self] (_) in
                            if let value = to.row.value{
                                _ = self.navigationController?.popViewController(animated: true)

//                                if value.count > 5{
//                                    Drop.down("最多选择5个！", state: .info)
//                                    
//                                }else{
//                                    _ = self.navigationController?.popViewController(animated: true)
//                                }
                            }else{
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            
                            }, onError: nil, onCompleted: nil, onDisposed: nil)
                        .addDisposableTo(to.rx_disposeBag)
                    to.navigationItem.rightBarButtonItem = item
                }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            
            <<< RgegisterPhotoRow(){ [unowned self] in
                $0.tag = "photo"
                if self.editUserInfo{
                    var urls = Set<Photo>()
                    UserModel.shared.userPhotos.map{$0.url}.forEach({ (url) in
                        urls.insert(Photo(image: nil, imageUrl: url))
                    })
                    $0.value = urls
                    $0.cell.setSections(photos:UserModel.shared.userPhotos.map({ (userPhoto) -> Photo in
                        var photo = Photo(image: nil, imageUrl: userPhoto.url)
                        photo.upId = userPhoto.id
                        return photo
                    }))
            
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
            +++  Section()
            <<< RgegisterVCRRow(){ [unowned self] in
                $0.tag = "vcr"
                $0.cell.editUserInfo = self.editUserInfo
                if self.editUserInfo{
                    if UserModel.shared.vcrUrl == ""{
                        $0.cell.img_icon.image = UIImage(named: "updateVideoIcon")
                    }else{
                        $0.cell.img_icon.image = UIImage(named: "playBtn")
                        $0.cell.btn.sd_setBackgroundImage(with: URL(string:UserModel.shared.vcrCoverUrl), for: .normal, placeholderImage: placeHolderImage)
                        $0.value = URL(string:UserModel.shared.vcrUrl)
                    
                    }
                 
                }
            }
                .onChange({[unowned self] (_) in
                    self.edited = true
                })
    }
     override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
    }
  @objc fileprivate  func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
  fileprivate  func event(){
    footerView.btn.addTarget(self, action: #selector(footerViewBtnAction), for: .touchUpInside)
    }
    @objc fileprivate func footerViewBtnAction(){
        //昵称
        let nickRow =  self.form.rowBy(tag: "nickName") as? NameRow
        //vrc
        let vcrRow =  self.form.rowBy(tag: "vcr") as? RgegisterVCRRow
        //专业证书
        let certificateRow =  self.form.rowBy(tag: "certificate") as? MultipleSelectorRow<String>
        //你所擅长的技能
        let hearsayRow =  self.form.rowBy(tag: "hearsay") as? RgegisterTextViewRow
        //我做旅行地主
        let toLandlordRow =  self.form.rowBy(tag: "toLandlord") as? RegisterSingleRow
        //城市
        let cityRow =  self.form.rowBy(tag: "city") as? CityRow
        //爱好
        let hobbyRow =  self.form.rowBy(tag: "hobby") as? MultipleSelectorRow<String>
        //是否找工作
        let findJobRow =  self.form.rowBy(tag: "findJob") as? RegisterSingleRow
        //职业
        let jobRow =  self.form.rowBy(tag: "job") as? OccupationRow
        //座右铭
        let mottoRow =  self.form.rowBy(tag: "motto") as? RgegisterTextViewRow
        //星座
        let constellationRow =  self.form.rowBy(tag: "constellation") as? PickerInputRow<String>
        //情感
        let landlordRow =  self.form.rowBy(tag: "landlord") as? RgegisterLandlordRow
        //性别
        let sexRow =  self.form.rowBy(tag: "sex") as? RegisterSexRow
        //生日
        let birRow =  self.form.rowBy(tag: "bir") as? DateRow
        //身高
        let heightRow =  self.form.rowBy(tag: "height") as? PickerInputRow<String>
        //语言
        let languageRow =  self.form.rowBy(tag: "language") as?  MultipleSelectorRow<String>
        let photoRow =  self.form.rowBy(tag: "photo") as?  RgegisterPhotoRow

        if editUserInfo{
        headerView.headerUlr = UserModel.shared.headPortUrl.value
        }
        guard let headerUlr = headerView.headerUlr else {
            Drop.down("请上传头像！", state: .error)
            return
        }
        guard let nickName = nickRow?.value else {
            Drop.down("昵称不能为空！", state: .error)
        return
        }
        if nickName.characters.count > 6 {
            Drop.down("昵称最多输入6个字符！", state: .error)
            return
        }
        guard let sex = sexRow?.value else {
            Drop.down("请选择性别！", state: .error)
            return
        }
        guard let landlord = landlordRow?.value else {
            Drop.down("请选择情感！", state: .error)
            return
        }
        guard let motto = mottoRow?.value else {
            Drop.down("请输入座右铭！", state: .error)
            return
        }
        guard let job = jobRow?.value else {
            Drop.down("请选择职业！", state: .error)
            return
        }
        guard let hobby = hobbyRow?.value else {
            Drop.down("请选择爱好！", state: .error)
            return
        }
        guard let city = cityRow?.value else {
            Drop.down("请选择城市！", state: .error)
            return
        }
        var vcrPath = ""
        if let vcr = vcrRow?.value {
            vcrPath = vcr.absoluteString
        }
        

        if footerView.idCardF != nil &&  footerView.idCardZ == nil{
            Drop.down("请上传身份证正面！", state: .error)
            return
        }
        if footerView.idCardF == nil &&  footerView.idCardZ != nil{
            Drop.down("请上传身份证反面！", state: .error)
            return
        }
        
        let activityIndicator =  ActivityIndicator()

     
        if editUserInfo{ //修改用户资料
        var param = EditUserInfoParam()
            param.phone = UserDefaults.standard.value(forKey: "userPhone") as! String
            param.password = (UserDefaults.standard.value(forKey: "userPwd") as! String).md5()
           
            param.nickName = nickName
            if let height = heightRow?.value{
                param.height = height
            }
            if let language = languageRow?.value{
            
                if (language.reduce("", { (result, s) -> String in
                    return "\(result),\(s)"
                }) as NSString).length > 0 {
                    param.language =  (language.reduce("", { (result, s) -> String in
                        return "\(result),\(s)"
                    }) as NSString).substring(from: 1)
                }else{
                    param.language =  ""
                }
                
                
            }
            param.sex = sex == "男" ? 1 : 2
            param.emotion = landlord
            if let constellation = constellationRow?.value{
                param.cons = constellation
            }
            param.motto = motto
            param.occ = job
            param.changeJob = findJobRow?.value ==  NSLocalizedString("yes", comment: "是") ? true : false
            param.hobby = (hobby.reduce("", { (result, s) -> String in
                return "\(result),\(s)"
            }) as NSString).substring(from: 1)
            param.perCity = city
            if let mutualTourism = toLandlordRow?.value{
                param.mutualTourism = mutualTourism == NSLocalizedString("yes", comment: "是") ? true : false
            }
            if let mutualTourism = hearsayRow?.value{
                param.autograph = mutualTourism
            }
            
            if let certificate = certificateRow?.value {
                if (certificate.reduce("", { (result, s) -> String in
                    return "\(result),\(s)"
                }) as NSString).length > 0 {
                    param.quacer =  (certificate.reduce("", { (result, s) -> String in
                        return "\(result),\(s)"
                    }) as NSString).substring(from: 1)
                }else{
                    param.quacer =  ""
                }
            }
            
            param.vcrUrl = UserModel.shared.vcrUrl
            
            if let idCardZ = footerView.idCardZ , let idCardF = footerView.idCardF{
                param.idCardsUrl = "\(idCardZ),\(idCardF)"
            }
            if let bir = birRow?.value{
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                param.dateOfBirth = format.string(from: bir)
                
                if (bir as NSDate).age() < 16 {
                    Drop.down("年龄至少16岁！", state: .error)
                    return
                }
            }
            ARSLineProgress.showWithPresentCompetionBlock {
                self.view.isUserInteractionEnabled = false

            }
            let uploadHeaderImgRequest = Observable.of(self.headerView.choseImaged.asObservable()
                .filter{$0 == true}
                .flatMap{ _ in
                RequestProvider.upload(type: .png, data: UIImageJPEGRepresentation(self.headerView.img_choseHeaderImg.image!, 0.5)!)
                    .trackActivity(activityIndicator)
                },
                    self.headerView.choseImaged.asObservable()
                    .filter{$0 == false}
                    .flatMap({ (_) -> Observable<Result<String>> in
                        return Observable.just(Result.success(UserModel.shared.headPortUrl.value))
                    }))
            .merge()
            .shareReplay(1)

                
            if let photos = photoRow?.value{
                var imagePaths = [String]()
                photos.forEach({ (photo) in
                    if photo.imagePath != ""{
                        imagePaths.append(photo.imagePath)
                    }
                })
                
                //上传RSV
                let vcrRequest  =  RequestProvider.upload(type: .mp4, fileUrl: URL(string:vcrPath))
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                if photoRow?.cell.deleteImageIds.count != 0 { //删除图片
                    
                   let upIds =  (photoRow!.cell.deleteImageIds.map{"\($0)"}.reduce("", { (result, s) -> String in
                        return "\(result),\(s)"
                    }) as NSString).substring(from: 1)
                    
                    //删除相册图片
                    let deleteUserPhotoRequest =  RequestProvider.request(api: ParametersAPI.deleteUserPhoto(upId: upIds as String)).mapObject(type: EmptyModel.self)
                        .trackActivity(activityIndicator)
                        .shareReplay(1)
                    
                     //上传相册图片
                    let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls: imagePaths)
                        .trackActivity(activityIndicator)
                        .shareReplay(1)
                    
                    //修改用户资料接口
                    let request =    Observable.zip(uploadHeaderImgRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()},vcrRequest.flatMap{$0.unwarp()},deleteUserPhotoRequest.flatMap{$0.unwarp()}){($0,$1,$2,$3)}
                        .flatMap({ (info) ->  Observable<Result<ResponseInfo<UserModel>>> in
                            param.hrurl = info.0
                            param.photosUrl = info.1
                            param.vcrUrl = info.2 == "" ? UserModel.shared.vcrUrl : info.2
                            return  RequestProvider.request(api: ParametersAPI.editUserInfo(param: param)).mapObject(type: UserModel.self)
                                .trackActivity(activityIndicator)

                        })
                        .shareReplay(1)
                    
                    Observable.of(vcrRequest.flatMap{$0.error}.map{$0.domain},deleteUserPhotoRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}).merge()
                        .subscribe(onNext: { (error) in
                            ARSLineProgress.hideWithCompletionBlock {
                                self.view.isUserInteractionEnabled = true

                            }
                            Drop.down(error)
                        })
                        .addDisposableTo(rx_disposeBag)
                    
                    request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { (userModel) in
                        
                        UserModel.shared.nickName.value = userModel.nickName.value
                        UserModel.shared.headPortUrl.value = userModel.headPortUrl.value
                        UserModel.shared = userModel
                        UserModel.shared.userCount.value = userModel.userCount.value
                        UserModel.shared.vcrCoverUrl = userModel.vcrCoverUrl
                        UserModel.shared.vcrUrl = userModel.vcrUrl
                        
//                        RCUserInfo * userinfo = [[RCUserInfo alloc] init];
//                        userinfo.name = [UserModel shared].name;
//                        userinfo.portraitUri = [[UserModel shared].portraitUri stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
//                        userinfo.userId = [NSString stringWithFormat:@"%ld",(long)[UserModel shared].ID];
//                        [RCIM sharedRCIM].currentUserInfo = userinfo;
//                        [RCIMClient sharedRCIMClient].currentUserInfo = userinfo;
                        
                        var userInfo = RCUserInfo()
                        userInfo.name = UserModel.shared.nickName.value
                        userInfo.portraitUri = UserModel.shared.headPortUrl.value
                        userInfo.userId = "\(UserModel.shared.ID)"
                        RCIM.shared().currentUserInfo = userInfo
                        RCIMClient.shared().currentUserInfo = userInfo
//                        
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true

                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUserInfoSuccessNotifation"), object: nil)
                        Drop.down("修改资料成功！", state: .success)
                        DBTool.shared.saveUserModel()
                        self.view.isUserInteractionEnabled = true
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                        .addDisposableTo(rx_disposeBag)

                    
                }else{
                
                    let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls: imagePaths)
                        .trackActivity(activityIndicator)
                        .shareReplay(1)
                    
                    let request =    Observable.zip(uploadHeaderImgRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()},vcrRequest.flatMap{$0.unwarp()}){($0,$1,$2)}
                        .flatMap({ (info) ->  Observable<Result<ResponseInfo<UserModel>>> in
                            param.hrurl = info.0
                            param.photosUrl = info.1
                            param.vcrUrl = info.2 == "" ? UserModel.shared.vcrUrl : info.2
                            return  RequestProvider.request(api: ParametersAPI.editUserInfo(param: param)).mapObject(type: UserModel.self)
                                .trackActivity(activityIndicator)
                        })
                        .shareReplay(1)
                    
                    Observable.of(vcrRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}).merge()
                        .subscribe(onNext: { (error) in
                            ARSLineProgress.hideWithCompletionBlock {
                                self.view.isUserInteractionEnabled = true
                            }
                            Drop.down(error)
                        })
                        .addDisposableTo(rx_disposeBag)
                    
                    request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { (userModel) in
                        UserModel.shared.nickName.value = userModel.nickName.value
                        UserModel.shared.headPortUrl.value = userModel.headPortUrl.value
                        UserModel.shared = userModel
                        UserModel.shared.userCount.value = userModel.userCount.value
                        
                        var userInfo = RCUserInfo()
                        userInfo.name = UserModel.shared.nickName.value
                        userInfo.portraitUri = UserModel.shared.headPortUrl.value
                        userInfo.userId = "\(UserModel.shared.ID)"
                        RCIM.shared().currentUserInfo = userInfo
                        RCIMClient.shared().currentUserInfo = userInfo
                        
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true
                        }
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateUserInfoSuccessNotifation"), object: nil)
                        Drop.down("修改资料成功！", state: .success)
                        DBTool.shared.saveUserModel()
                        _ = self.navigationController?.popViewController(animated: true)
                        self.view.isUserInteractionEnabled = true

                    })
                        .addDisposableTo(rx_disposeBag)

                }
            
     }
        }else{ //注册
            UserModel.shared.vcrUrl = ""
            var param = RegisterParam()
            param.userPhone = userPhone
            param.vcode = vcode
            param.password = password.md5()
            param.hrurl = headerUlr
            param.nickName = nickName
            if let height = heightRow?.value{
                param.height = Double(height)!
            }
            if let language = languageRow?.value{
                param.language = (language.reduce("", { (result, s) -> String in
                    return "\(result),\(s)"
                }) as NSString).substring(from: 1)
            }
            param.sex = sex == "男" ? 1 : 2
            
            param.emotion = landlord
            
            if let constellationRow = constellationRow?.value{
                param.cons = constellationRow
            }
            param.motto = motto
            param.occ = job
            param.changeJob = findJobRow?.value ==  NSLocalizedString("yes", comment: "是") ? true : false
            param.hobby = (hobby.reduce("", { (result, s) -> String in
                return "\(result),\(s)"
            }) as NSString).substring(from: 1)
            param.perCity = city
            if let mutualTourism = toLandlordRow?.value{
                param.mutualTourism = mutualTourism == NSLocalizedString("yes", comment: "是") ? true : false
            }
            if let mutualTourism = hearsayRow?.value{
                param.autograph = mutualTourism
            }
            if let certificate = certificateRow?.value {
                param.quacer = (certificate.reduce("", { (result, s) -> String in
                    return "\(result),\(s)"
                }) as NSString).substring(from: 1)
            }
            
            param.vcrUrl =  vcrPath
            if let idCardZ = footerView.idCardZ , let idCardF = footerView.idCardF{
                param.idCardsUrl = "\(idCardZ),\(idCardF)"
            }
            if let bir = birRow?.value{
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                param.dateOfBirth = format.string(from: bir)
                
                if (bir as NSDate).age() < 16 {
                    Drop.down("年龄至少16岁！", state: .error)
                    return
                }
            }
            
            ARSLineProgress.showWithPresentCompetionBlock {
                self.view.isUserInteractionEnabled = false

            }
            
            //上传头像
            let uploadHeaderImgRequest =   RequestProvider.upload(type: .png, fileUrl: URL(string:headerUlr))
                .trackActivity(activityIndicator)
                .shareReplay(1)
            //上传RSV
            let vcrRequest  =  RequestProvider.upload(type: .mp4, fileUrl: URL(string:vcrPath))
                .trackActivity(activityIndicator)
                .shareReplay(1)
            
            if let photos = photoRow?.value{ //上传图片
                var imagePaths = [String]()
                photos.forEach({ (photo) in
                    if photo.imagePath != ""{
                        imagePaths.append(photo.imagePath)
                    }
                })

                //上传相册
                let uploadPhotosRequest =  RequestProvider.upLoadImageUrls(imageUrls: imagePaths)
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                
                //注册接口
                let request =   Observable.zip(vcrRequest.flatMap{$0.unwarp()},uploadHeaderImgRequest.flatMap{$0.unwarp()}, uploadPhotosRequest.flatMap{$0.unwarp()}){($0,$1,$2)}
                    .flatMap({ (info) ->  Observable<Result<ResponseInfo<UserModel>>> in
                        param.vcrUrl = info.0
                        param.hrurl = info.1
                        param.photosUrl = info.2
                        return  RequestProvider.request(api: ParametersAPI.register(param: param)).mapObject(type: UserModel.self)
                    })
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                
                Observable.of(vcrRequest.flatMap{$0.error}.map{$0.domain},uploadHeaderImgRequest.flatMap{$0.error}.map{$0.domain},uploadPhotosRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}).merge()
                    .subscribe(onNext: { (error) in
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true

                        }
                        Drop.down(error)
                    })
                    .addDisposableTo(rx_disposeBag)
                
                let loginIMReuquest =  request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                    .do(onNext: { (userModel) in
                        UserModel.shared = userModel
                        UserModel.shared.nickName.value = userModel.nickName.value
                        UserModel.shared.headPortUrl.value = userModel.headPortUrl.value
                        UserModel.shared.userCount.value = userModel.userCount.value

                    })
                    .flatMap({ (userModel) -> Observable<Result<String>> in
                        if let _ = UserDefaults.standard.value(forKey: "userToken") as? String{
                            return  Observable.create({ (observer ) -> Disposable in
                                observer.onNext(Result.success("登录成功！"))
                                observer.onCompleted()
                                return Disposables.create()
                            })
                        }
                        return  self.loginIM(token: userModel.token)
                        
                    })
                    .shareReplay(1)
                
                loginIMReuquest.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
                
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(UserModel.shared.nickName.value, forKey: "userName")
                        UserDefaults.standard.set(self.userPhone, forKey: "userPhone")
                        UserDefaults.standard.set(self.password, forKey: "userPwd")
                        UserDefaults.standard.set(UserModel.shared.token, forKey: "userToken")
                        UserDefaults.standard.set("\(UserModel.shared.id)", forKey: "userId")
                        UserDefaults.standard.set("\(UserModel.shared.headPortUrl.value)", forKey: "userPortraitUri")
                        
                        UserDefaults.standard.synchronize()
                        RCDRCIMDataSource.shareInstance().syncGroups()
                        let userInfo = RCUserInfo()
                        userInfo.name = UserModel.shared.nickName.value
                        userInfo.userId = "\(UserModel.shared.id)"
                        userInfo.portraitUri = UserModel.shared.headPortUrl.value
                        RCIM.shared().currentUserInfo = userInfo
                        RCIMClient.shared().currentUserInfo = userInfo
                        RCDLive.shared().currentUserInfo = userInfo
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true
                            
                        }
                        DBTool.shared.saveUserModel()
                        
                        let mainVC =  UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()  as! TabBarController
                        UIApplication.shared.keyWindow?.rootViewController = mainVC
                    }
                   
                    
                    
                    
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                
                Observable.of(loginIMReuquest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
                    .merge()
                    .subscribe(onNext: { (error) in
                        Drop.down(error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            }else{
                //注册接口
                let request =   Observable.zip(vcrRequest.flatMap{$0.unwarp()},uploadHeaderImgRequest.flatMap{$0.unwarp()}){($0,$1)}
                    .flatMap({ (info) ->  Observable<Result<ResponseInfo<UserModel>>> in
                        param.vcrUrl = info.0
                        param.hrurl = info.1
                        return  RequestProvider.request(api: ParametersAPI.register(param: param)).mapObject(type: UserModel.self)
                    })
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
                
                
                Observable.of(vcrRequest.flatMap{$0.error}.map{$0.domain},uploadHeaderImgRequest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain}).merge()
                    .subscribe(onNext: { (error) in
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true

                        }
                        Drop.down(error)
                    })
                    .addDisposableTo(rx_disposeBag)
                
                let loginIMReuquest =  request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
                    .do(onNext: { (userModel) in
                        UserModel.shared = userModel
                        UserModel.shared.nickName.value = userModel.nickName.value
                        UserModel.shared.headPortUrl.value = userModel.headPortUrl.value
                        UserModel.shared.userCount.value = userModel.userCount.value

                    })
                    .flatMap({ (userModel) -> Observable<Result<String>> in
                        if let _ = UserDefaults.standard.value(forKey: "userToken") as? String{
                            return  Observable.create({ (observer ) -> Disposable in
                                observer.onNext(Result.success("登录成功！"))
                                observer.onCompleted()
                                return Disposables.create()
                            })
                        }
                        return  self.loginIM(token: userModel.token)
                        
                    })
                    .shareReplay(1)
                
                loginIMReuquest.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
                    
           
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(UserModel.shared.nickName.value, forKey: "userName")
                        UserDefaults.standard.set(self.userPhone, forKey: "userPhone")
                        UserDefaults.standard.set(self.password, forKey: "userPwd")
                        UserDefaults.standard.set(UserModel.shared.token, forKey: "userToken")
                        UserDefaults.standard.set("\(UserModel.shared.id)", forKey: "userId")
                        UserDefaults.standard.set("\(UserModel.shared.headPortUrl.value)", forKey: "userPortraitUri")
                        
                        UserDefaults.standard.synchronize()
                        RCDRCIMDataSource.shareInstance().syncGroups()
                        let userInfo = RCUserInfo()
                        userInfo.name = UserModel.shared.nickName.value
                        userInfo.userId = "\(UserModel.shared.id)"
                        userInfo.portraitUri = UserModel.shared.headPortUrl.value
                        RCIM.shared().currentUserInfo = userInfo
                        RCIMClient.shared().currentUserInfo = userInfo
                        RCDLive.shared().currentUserInfo = userInfo
                        ARSLineProgress.hideWithCompletionBlock {
                            self.view.isUserInteractionEnabled = true
                            
                        }
                        DBTool.shared.saveUserModel()
                        
                        let mainVC =  UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()  as! TabBarController
                        UIApplication.shared.keyWindow?.rootViewController = mainVC

                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
                
                
                Observable.of(loginIMReuquest.flatMap{$0.error}.map{$0.domain},request.flatMap{$0.error}.map{$0.domain})
                    .merge()
                    .subscribe(onNext: { (error) in
                        Drop.down(error)
                    }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
            }
        }
    }
    
    ///登录融云IM
    fileprivate func loginIM(token:String) -> Observable<Result<String>>{
        return Observable.create({ (observer) -> Disposable in
            RCIM.shared().connect(withToken: token, success: { (userName) in
                observer.onNext(Result.success("登录成功！"))
                observer.onCompleted()
            }, error: { (code) in
                observer.onNext(Result.failure(NSError(domain: "登录失败！", code: 1, userInfo: nil)))
                observer.onCompleted()
            }) {
                UserDefaults.standard.set(nil, forKey: "userToken")
                observer.onNext(Result.failure(NSError(domain: "Token已过期，请重新登录！", code: 1, userInfo: nil)))
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
        
    fileprivate func uploadImages(){
        
   
        
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "正在上传身份证...", for: view)).addDisposableTo(rx_disposeBag)

        let uploadIdCardZRequest =   footerView.chosedIdCardZ.asObservable()
            .filter{$0 == true}
            .do(onNext: { (_) in
                self.view.isUserInteractionEnabled = false
            })
            .flatMap{ _ in
                RequestProvider.upload(type: .png, data: UIImageJPEGRepresentation(self.footerView.idCardZImg!, 0.5)!)
                .trackActivity(activityIndicator)
            }
            .shareReplay(1)
        
        
        
        uploadIdCardZRequest.flatMap{$0.error}.map{$0.domain}.subscribe { (error) in
            Drop.down("上传身份证正面失败！", state: .error)
            self.view.isUserInteractionEnabled = true
            }
            .addDisposableTo(rx_disposeBag)
        
        uploadIdCardZRequest.flatMap{$0.unwarp()}.subscribe(onNext: { (path) in
//            Drop.down("上传身份证正面成功！", state: .success)
            ARSLineProgress.showSuccess()
            self.footerView.idCardZ = path
            self.view.isUserInteractionEnabled = true

        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        
        let uploadIdCardFRequest =   footerView.chosedIdCardF.asObservable()
            .filter{$0 == true}
            .do(onNext: { (_) in
                self.view.isUserInteractionEnabled = false
            })
            .flatMap{ _ in
                RequestProvider.upload(type: .png, data: UIImageJPEGRepresentation(self.footerView.idCardFImg!, 0.5)!)
                    .trackActivity(activityIndicator)
            }
            .shareReplay(1)
        
        
        uploadIdCardFRequest.flatMap{$0.error}.map{$0.domain}.subscribe { (error) in
            Drop.down("上传身份证反面失败！", state: .error)
            self.view.isUserInteractionEnabled = true

            }
            .addDisposableTo(rx_disposeBag)
        
        uploadIdCardFRequest.flatMap{$0.unwarp()}.subscribe(onNext: { (path) in
//            Drop.down("上传身份证反面成功！", state: .success)
            self.view.isUserInteractionEnabled = true
            ARSLineProgress.showSuccess()
            self.footerView.idCardF = path
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    fileprivate func accessView(_ imageNamed:String) -> UIImageView{
    let imageView = UIImageView()
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageView.contentMode = .center
        imageView.image = UIImage(named: imageNamed)
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        return imageView
    }
    
        
}


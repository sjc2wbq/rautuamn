//
//  MeViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop
import SDAutoLayout
struct MeRowInfo {
    var imageNamed = ""
    var title = ""
    var subTitle = ""
    init(imageNamed:String,title:String,subTitle:String = "") {
    self.imageNamed = imageNamed
        self.title = title
        self.subTitle = subTitle
    }
}
//,UITableViewDelegate,UITableViewDataSource
class MeViewController: UITableViewController,MKTagViewDelegate{
//    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
    var model:FriendInfoModel?
    var tagCellH:CGFloat = 0
    var dataSource = [[MeRowInfo]]()
    
    // 处理标签所在cell的高度问题
    var isFirst = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        
        print("*************\(UserModel.shared.headPortUrl.value)")
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor.black
        self.navigationItem.titleView = titleLabel
//        titleLabel.text = UserModel.shared.name
        do{
//            tableView.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
            
            let header = STRefreshHeader()
            self.tableView.st_header = header
          let request =  header.rx.refresh.flatMap{_ in RequestProvider.request(api: ParametersAPI.userLogin(phone: (UserDefaults.standard.value(forKey: "userPhone") as! String), password: (UserDefaults.standard.value(forKey: "userPwd") as! String).md5())).mapObject(type: UserModel.self)}
            .shareReplay(1)
        
            request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (userModel) in
                  UserModel.shared = userModel
                 UserModel.shared.id = Int(UserDefaults.standard.value(forKey: "userId") as! String)!
                self.tableView.reloadData()
                self.tableView.st_header.endRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
            
            request.flatMap{$0.error}.subscribe(onNext: { (_) in
                self.tableView.st_header.endRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        }
        
        do{
            NotificationCenter.default.rx.notification(Notification.Name(rawValue: "UpdateUserInfoSuccessNotifation"))
                .subscribe(onNext: {[unowned self] (_) in
//                    self.title = UserModel.shared.name

                self.tableView.reloadData()
                
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
        }
        do{
        tableView.backgroundColor = bgColor
            let section0Row0 = MeRowInfo(imageNamed: "wallet", title: "我的镭秋钱包",subTitle:"")
            let section0Row = MeRowInfo(imageNamed: "dashangjilu", title: "打赏全记录",subTitle:"")
//            let section0Row6 = MeRowInfo(imageNamed: "myhongbao", title: "我的红包",subTitle:"")
            let section0Row1 = MeRowInfo(imageNamed: "rank", title: "我的等级",subTitle:"")
            let section0Row2 = MeRowInfo(imageNamed: "video", title: "我的视频")
            let section0Row3 = MeRowInfo(imageNamed: "MyAricle", title: "我的发布")
            let section0Row4 = MeRowInfo(imageNamed: "activity", title: "我参与的活动")
            let section0Row5 = MeRowInfo(imageNamed: "groupInfo", title: "我的群组")
            
            let section1Row0 = MeRowInfo(imageNamed: "updatePwd", title: "修改密码")
            let section1Row1 = MeRowInfo(imageNamed: "me_distance", title: "距离显示")

            let section2Row0 = MeRowInfo(imageNamed: "setting", title: "更多")
    
            dataSource = [[section0Row0,section0Row,section0Row1,section0Row2,section0Row3,section0Row4,section0Row5],[section1Row0,section1Row1],[section2Row0]]
        }
    
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let ConversationType_SYSTEM_Count = UserDefaults.standard.value(forKey: "ConversationType_SYSTEM_Count") as? Int{
            self.tabBarController?.tabBar.showBadge(onItemIndex: 4, badgeValue: Int32(ConversationType_SYSTEM_Count))
            self.navigationItem.rightBarButtonItems?[0].badgeValue  = "\(ConversationType_SYSTEM_Count)"
        }else{
            self.navigationItem.rightBarButtonItems?[0].badgeValue  = nil
            self.tabBarController?.tabBar.hideBadge(onItemIndex: 4)
        }
    }
}
extension MeViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userInfoVC" {
            let vc = segue.destination as! Register2ViewController
            vc.editUserInfo = true
        }else if segue.identifier == "SystemMessageViewController" {
            self.tabBarController?.tabBar.hideBadge(onItemIndex: 4)
            UserDefaults.standard.setValue(nil, forKey: "ConversationType_SYSTEM_Count")
        }
    }
    @IBAction func openQRVCAction(_ sender: Any) {
        let vc = MyQRViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension MeViewController{
    
    
    
    fileprivate func initTableView(){
//        self.view.addSubview(tableView)
        tableView.backgroundColor = bgColor
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.register(UINib(nibName: "MeTableViewCell", bundle: nil), forCellReuseIdentifier: "MeTableViewCell")
        tableView.register(UINib(nibName: "UserInfoBaseInfoViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoBaseInfoViewCell")
        tableView.register(UINib(nibName: "UserInfoTagViewCell", bundle: nil), forCellReuseIdentifier: "UserInfoTagViewCell")
        tableView.register(UINib(nibName: "UserOtherInfoViewCell", bundle: nil), forCellReuseIdentifier: "UserOtherInfoViewCell")
    }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoBaseInfoViewCell") as! UserInfoBaseInfoViewCell
            cell.img_playVideo.tag = indexPath.row
            let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
            cell.userModel = UserModel.shared
            
//            let frame = cell.lb_friendCount.frame
//            cell.lb_friendCount.frame = CGRect.init(x: frame.minX, y: frame.minY, width: frame.width, height: 22)
            print("8888888------\(String(describing: cell.lb_friendCount.text))+++++\(cell.lb_friendCount.frame.height)--------\(cell.lb_registerTime.frame.height)")
            cell.img_playVideo.addGestureRecognizer(tap)
            return cell
        }else if indexPath.section == 2{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserOtherInfoViewCell") as! UserOtherInfoViewCell
        cell.userModel = UserModel.shared
        return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoTagViewCell") as! UserInfoTagViewCell
            cell.userModel = UserModel.shared
            cell.tagView.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell") as! MeTableViewCell
        let model = dataSource[indexPath.section - 3][indexPath.row]
        cell.img_icon.image = UIImage(named:model.imageNamed)
        cell.lb_title.text = model.title
        cell.lb_subTitle.text = model.subTitle
        let accessoryView = UISwitch(frame: CGRect(x: 0, y: 0, width: 52, height: 30))
        accessoryView.onTintColor = UIColor.colorWithHexString("#FF8200")
        accessoryView.addTarget(self, action: #selector(switchValueChanged(s:)), for: .valueChanged)
        accessoryView.isOn = !UserModel.shared.distanceOff
        if indexPath.section == 4{
            if indexPath.row == 1{
                cell.accessoryView = accessoryView
                cell.accessoryType = .none
            }else{
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
            }
            cell.lb_subTitle.text = nil

        }else if indexPath.section == 3{
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            if indexPath.row == 0 {
                UserModel.shared.rautumnCurrency.asObservable().map{"\($0)"}.bindTo(cell.lb_subTitle.rx.text).addDisposableTo(cell.rx_reusableDisposeBag)
            }else if indexPath.row == 2 {
                UserModel.shared.rank.asObservable().subscribe(onNext: { (rank) in
                    if rank == "U"{
                        cell.lb_subTitle.text = "注册用户"
                    }else if rank == "M"{
                        cell.lb_subTitle.text = "注册会员"
                    }else  if rank == "V"{
                        cell.lb_subTitle.text = "VIP会员"
                    }else{
                        cell.lb_subTitle.text = nil
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
             
            }
        }else{
                cell.lb_subTitle.text = nil
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
            }
        return cell
    }
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0{
                return 1
            }else if section == 1{
                return 1
            }else if section == 2{
                return 1
            }
            return dataSource[section - 3].count
    }
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0{
        
        
        if UserModel.shared.userPhotos.count == 0 {
            
            
            return 660
        }
        
        return 774
    }else if  indexPath.section == 1{
        
        if self.tagCellH == 0 {
                return 100
        }
        
        return self.tagCellH
    }else if  indexPath.section == 2{
        return cellHeight(for: indexPath, cellContentViewWidth: screenW, tableView: tableView)
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        
        
    if indexPath.section == 3{
        if indexPath.row == 0{
            let vc = MyWalletViewController()
                navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 1{
            let vc = GratuityRauCurrContentViewContoller()
            navigationController?.pushViewController(vc, animated: true)

        }
//        else if indexPath.row == 2{
//            JrmfPacketManager.getEventOpenWallet()
//        }
        else if indexPath.row == 2{
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "RankTableViewController")
            navigationController?.pushViewController(vc, animated: true)

        }else if indexPath.row == 3{
            let vc = MyVideoViewController()
                navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 4{
            let vc = MyArticleViewController()
                vc.title = "我的发布"
                navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 5{
            let vc = MyActivityContentViewController()
            navigationController?.pushViewController(vc, animated: true)

        }else if indexPath.row == 6{
            let vc = MyGroupContentViewController()
                navigationController?.pushViewController(vc, animated: true)
        }
        
    }else if indexPath.section == 4{
        if indexPath.row == 0 {
            let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "ModifyPWDTableViewController")
                navigationController?.pushViewController(vc, animated: true)
        }
    }else if indexPath.section == 5{
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "MoreTableViewController")
            navigationController?.pushViewController(vc, animated: true)
    }
    }
    func mkTagView(_ tagview: MKTagView!, sizeChange newSize: CGRect) {
        tagCellH = newSize.height + 50
        print("ssssss = \(tagCellH)")
        
        if !isFirst {
            tableView.reloadData()
            isFirst = true
        }
    }
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
//        let view = tap.view
//        let indexPath = IndexPath(row: view!.tag, section: 0)
//        let cell = tableView.cellForRow(at: indexPath) as! UserInfoBaseInfoViewCell
        if UserModel.shared.vcrUrl == "" {
            return
        }
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:(UserModel.shared.vcrUrl as NSString).replacingOccurrences(of: "%2F", with: "/"))
        self.present(vc, animated: true, completion: nil)
    }
    @objc fileprivate func switchValueChanged(s:UISwitch){
        let request = RequestProvider.request(api: ParametersAPI.openOrCloseDistance(type: s.isOn == true ? 1 : 2)).mapObject(type: EmptyModel.self)
        .shareReplay(1)
        request.flatMap{$0.unwarp()}
        .subscribe(onNext: { (_) in
            UserModel.shared.distanceOff = !s.isOn
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}
            .map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    }

    
}

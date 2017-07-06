//
//  FindFriendsViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import  MJRefresh
import SimpleAlert
import Popover
import swiftScan
import ObjectMapper
import SwiftyDrop
import SwiftLocation
class FindFriendsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,CityPickerViewControllerDelegate{
    var param = FindFriendParam()
    var page = 1
    var dataSource = [Friend]()
    var emptyDisplayCondition = false
    @IBOutlet weak var tableView: UITableView!
    let menu = DOPDropDownMenu(origin: CGPoint(x: 0, y: 130), andHeight: 44)
let headerView = FindFriendsHeaderView.headerView()
    let popView = FindFriendsPopView.popView()
    var popover: Popover?
    var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.1)),
        .color(UIColor.white)
    ]
    var job =   [DropMenuModel]()
    let language = [
                    DropMenuModel(text: "全部"),
                    DropMenuModel(text: NSLocalizedString("Chinese", comment: "中文")),
                    DropMenuModel(text: NSLocalizedString("English", comment: "英语")),
                    DropMenuModel(text: NSLocalizedString("French", comment: "法语")),
                    DropMenuModel(text: NSLocalizedString("Spanish", comment: "西班牙语")),
                    DropMenuModel(text: NSLocalizedString("Portuguese", comment: "葡萄牙语")),
                    DropMenuModel(text: NSLocalizedString("Arabic", comment: "阿拉伯语")),
                    DropMenuModel(text: NSLocalizedString("Russian", comment: "俄语")),
                    DropMenuModel(text: NSLocalizedString("Japanese", comment: "日语")),
                    DropMenuModel(text: NSLocalizedString("Chinkoreanese", comment: "韩语"))]
    
    let constellation = [
                        DropMenuModel(text: NSLocalizedString("Virgo", comment:"处女座")),
                         DropMenuModel(text: NSLocalizedString("Leo", comment:"狮子座")),
                         DropMenuModel(text: NSLocalizedString("Pisces", comment:"双鱼座")),
                         DropMenuModel(text: NSLocalizedString("Scorpio", comment:"蝎子座")),
                         DropMenuModel(text: NSLocalizedString("Capricorn", comment:"魔羯座")),
                         DropMenuModel(text: NSLocalizedString("Taurus", comment:"金牛座")),
                         DropMenuModel(text: NSLocalizedString("cancer", comment:"巨蟹座")),
                         DropMenuModel(text: NSLocalizedString("Gemini", comment:"双子座")),
                         DropMenuModel(text: NSLocalizedString("Libra", comment:"天秤座")),
                         DropMenuModel(text: NSLocalizedString("Aquarius", comment:"水瓶座")),
                         DropMenuModel(text: NSLocalizedString("Aries", comment:"白羊座")),
                         DropMenuModel(text: NSLocalizedString("sagittarius", comment:"射手座"))]
    
    let hobbby =  (NSArray(contentsOfFile: Bundle.main.path(forResource: "hobby", ofType: "plist")!) as! [String]).map{DropMenuModel(text: $0)}
    
    let certificate =  (NSArray(contentsOfFile: Bundle.main.path(forResource: "certificate", ofType: "plist")!) as! [String]).map{DropMenuModel(text: $0)}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "job2", ofType: "geojson")
        let JSONData = NSData(contentsOfFile: path!)
        let JSONObject = try? JSONSerialization.jsonObject(with: JSONData! as Data, options: JSONSerialization.ReadingOptions.allowFragments)
//          let s  =  (Mapper<String>().mapArray(JSONObject: JSONObject)!)
//    Mapper<String>().
      job =   (JSONObject as! [String]).map{DropMenuModel(text: $0)}
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "没有找到符合条件的镭友！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        
        do{
            var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                
                _ =  Location.reverse(location: loc, onSuccess: { (placemark) in
                    if let city =  placemark.locality{
                        UserModel.shared.city = city
                    }
                }, onError: { (_) in
                    
                })
            }) { (last, err) in
                print("err \(err)")
            }
            r.onAuthorizationDidChange = { newStatus in
                print("New status \(newStatus)")
            }
        }
        
        do{
            var city = UserModel.shared.city
            if UserModel.shared.city.hasSuffix("市"){
               city = (city as NSString).substring(to: (city as NSString).length - 1) as String
            }
            param.permanentCity = city == "定位失败" ? "北京" : city
            title = "找镭友"
            
            navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImageNamed(imageNamed: "findFrinedPlus")
            navigationItem.rightBarButtonItem!.rx.tap
                .subscribe(onNext: {[unowned self] (_) in
                    self.popover = Popover(options: self.popoverOptions, showHandler:nil, dismissHandler:nil)
                    self.popover?.show(self.popView, point: CGPoint(x: screenW - 25, y: 55))
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            

            popView.qrAction = {[unowned self] in
                self.popover?.dismiss()
                let vc = ScanViewController()
                var style = LBXScanViewStyle()
                style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
                vc.scanStyle = style
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            popView.leiAction = {[unowned self] in
                self.popover?.dismiss()
                let vc = LeiFateViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        do{
            tableView.tableFooterView = UIView()
            tableView.contentInset = UIEdgeInsetsMake(174, 0, 0, 0)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "FindFriendsViewCell", bundle: nil), forCellReuseIdentifier: "FindFriendsViewCell")
            self.view.addSubview(headerView)
            headerView.height = 130
            headerView.width = screenW
            
            headerView.btnAction = {[unowned self] (index,isSelected) in
                self.menu?.dismiss()
                switch index {
                case 0:
                   let vc = CityPickerViewController()
                   vc.delegate = self
                   vc.title = "城市选择"
                   vc.cityModels = vc.cityModelsPrepare()
                   vc.hotCities = ["成都", "深圳", "上海", "长沙", "杭州", "南京", "徐州", "北京"];
                   vc.currentCity = UserModel.shared.city
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1,2:
                    if index == 1{
                        if isSelected == true{
                            self.param.emotion = "找女友"
                        }else{
                            self.param.emotion = ""
                        }
                        self.param.changeJob = ""
                        self.param.mutualTourism = ""


                    }else if index == 2{
                        if isSelected == true{
                            self.param.emotion = "找男友"
                        }else{
                            self.param.emotion = ""
                        }
                        self.param.changeJob = ""
                        self.param.mutualTourism = ""
                    }
                case 3:
                    if self.param.changeJob == ""{
                        self.param.changeJob = "1"
                    }else{
                        self.param.changeJob = ""
                    }
                    self.param.emotion = ""
                    self.param.mutualTourism = ""
                default:
                    if self.param.mutualTourism == ""{
                        self.param.mutualTourism = "1"
                    }else{
                        self.param.mutualTourism = ""

                    }
                    self.param.emotion = ""
                    self.param.changeJob = ""

                }
                self.tableView.st_header.beginRefreshing()

            }
            self.tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
                self.page = 1
                self.fecthData()
            })
        
            
            tableView.mj_footer = footer{ [unowned self] in
                self.page += 1
                self.fecthData()
            }
        tableView.st_header.beginRefreshing()
        }
        do{ //设置选择菜单
            menu?.isRemainMenuTitle = false
            menu?.delegate = self
            menu?.dataSource = self
//            menu?.selectDefalutIndexPath()
            view.addSubview(menu!)
        
        }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsViewCell") as! FindFriendsViewCell
        if dataSource.count > indexPath.row {
            let friend = dataSource[indexPath.row]
            cell.friend = friend
            cell.btn_lei.rx.tap.subscribe(onNext: {[unowned self] (_) in
                if friend.friend {
                    let conversationVC = RCDChatViewController()
                    conversationVC.conversationType = .ConversationType_PRIVATE;
                    conversationVC.targetId = "\(friend.userId)"
                    conversationVC.title = friend.nickName
                    conversationVC.displayUserNameInCell = false
                    self.navigationController?.pushViewController(conversationVC, animated: true)
                }else{
                    let vc = UserInfoViewController()
                    vc.visitorUserId = Int(friend.userId)
//                    vc.title = friend.nickName
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
        }
         return cell
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let friend = dataSource[indexPath.row]
        let vc = UserInfoViewController()
        vc.visitorUserId = Int(friend.userId)
    
//        vc.title = friend.nickName
        navigationController?.pushViewController(vc, animated: true)

    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y;
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            if y < -10 {
                self.headerView.frame = y <= -130 ? CGRect(x: 0, y: 0, width: screenW, height: 130) :  CGRect(x: 0, y: -y-130, width: screenW, height: 130)
                self.menu?.frame = y <= -130 ? CGRect(x: 0, y: 130, width: screenW, height: 44) :  CGRect(x: 0, y: -y, width: screenW, height: 44)
                
            }else{
                self.headerView.frame = CGRect(x: 0, y: -130, width: screenW, height: 130)
                self.menu?.frame = CGRect(x: 0, y: 0, width: screenW, height: 44)
            }
        })
}
}
extension FindFriendsViewController : DOPDropDownMenuDataSource,DOPDropDownMenuDelegate{
    func numberOfColumns(in menu: DOPDropDownMenu!) -> Int {
        return 5
    }
    func menu(_ menu: DOPDropDownMenu!, numberOfRowsInColumn column: Int) -> Int {
        if column == 0 {
            return language.count
        }else if column == 1 {
            return constellation.count
        }else if column == 2 {
            return hobbby.count
        }else if column == 3 {
            return job.count
        }
        return certificate.count
    }
    func menu(_ menu: DOPDropDownMenu!, titleForRowAt indexPath: DOPIndexPath!) -> DropMenuModel! {
        if indexPath.column == 0 {
            return language[indexPath.row]
        }else if indexPath.column == 1 {
            return constellation[indexPath.row]
        }else if indexPath.column == 2 {
            return hobbby[indexPath.row]
        }else if indexPath.column == 3 {
            return job[indexPath.row]
        }
        return certificate[indexPath.row]
    }
    func menu(_ menu: DOPDropDownMenu!, numberOfItemsInRow row: Int, column: Int) -> Int {
         return 0
    }
    func menu(_ menu: DOPDropDownMenu!, titleForItemsInRowAt indexPath: DOPIndexPath!) -> DropMenuModel! {
        return DropMenuModel(text:"sdasdad")
    }
    func menu(_ menu: DOPDropDownMenu!, didSelectRowAt indexPath: DOPIndexPath!) {
        if indexPath.column == 0 {
            let model =  language[indexPath.row]
            language.forEach({ (model) in
                model?.seleted = false
            })
            model?.seleted = true
            self.param.language = model!.text == "全部" ? "" : model!.text
        }else if indexPath.column == 1 {
             let model = constellation[indexPath.row]
            constellation.forEach({ (model) in
                model?.seleted = false
            })
            model?.seleted = true
            self.param.constellation = model!.text == "全部" ? "" : model!.text
        }else if indexPath.column == 2 {
            let model = hobbby[indexPath.row]
            hobbby.forEach({ (model) in
                model?.seleted = false
            })
            model?.seleted = true
            self.param.hobby = model!.text == "全部" ? "" : model!.text

        }else if indexPath.column == 3 {
            let model = job[indexPath.row]
            job.forEach({ (model) in
                model.seleted = false
            })
            model.seleted = true
            self.param.occupation = model.text == "全部" ? "" : model.text
        }else {
            let model = certificate[indexPath.row]
            certificate.forEach({ (model) in
                model?.seleted = false
            })
            model?.seleted = true
            self.param.vocationalCertificate = model!.text == "全部" ? "" : model!.text

        }
        menu.reloadData()
    }
    func menu(_ menu: DOPDropDownMenu!, didClickeDoneButton button: UIButton!) {
        tableView.st_header.beginRefreshing()
    }
}
extension FindFriendsViewController{
    fileprivate func fecthData(){
        param.pageIndex = self.page
    let request =  RequestProvider.request(api: ParametersAPI.findRF(param: param)).mapObject(type: UserInfoModel.self)
    .shareReplay(1)
    
        request.flatMap{$0.unwarp()}.map{$0.result_data?.userInfos}
         .unwrap()
        .subscribe(onNext: { (models) in
            if self.page == 1 {
                self.dataSource = models
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.isHidden = self.dataSource.count < 10
                self.emptyDisplayCondition = true
            }else{
                if models.count == 0{
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    self.dataSource += models
                    self.tableView.mj_footer.endRefreshing()
                }
            }
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: {[unowned self] (error) in
                Drop.down(error, state: .error)
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    func cityPickerViewController(_ cityPickerViewController: CityPickerViewController!, selectedCityModel: CityModel!) {
        guard var  cityName = selectedCityModel.name else {
            return
        }
        if selectedCityModel.name.hasSuffix("市"){
            cityName = (cityName as NSString).substring(to: (cityName as NSString).length - 1)
        }
        headerView.btn_region.setTitle("\(cityName)", for: .normal)
//        headerView.w.constant = "中国大陆城市：\(cityName)".width(15, height: 31) + 20
        param.permanentCity = cityName
        tableView.st_header.beginRefreshing()
        _ = navigationController?.popViewController(animated: true)
        
    }
}



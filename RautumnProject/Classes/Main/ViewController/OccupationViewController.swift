//
//  OccupationViewController.swift
//  ObjectsProject
//
//  Created by Raychen on 2016/10/19.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import MBProgressHUD
import Eureka
// MARK: - Occupationtype

struct OccupationType {
    var name = ""
    var data: [String] = []
    var selected = Variable(false)
    init?( map: Map) {}
}

extension OccupationType: Mappable {
    mutating func mapping(map: Map) {
        name <- map["name"]
        data <- map["data"]
    }
}

final class OccupationRow : SelectorRow<PushSelectorCell<String>, OccupationViewController>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return OccupationViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        displayValueFor = {
            guard let text = $0 else { return "选择职业" }
            return text
        }
    }
}


class OccupationViewController: UIViewController,TypedRowControllerType {
    let result = PublishSubject<String>()

    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    var leftDataSource = [OccupationType]()
    var rightDataSource = [String]()
    
    public var row: RowOf<String>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(OccupationViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "职业"
        leftTableView.register(OccupationViewCell.self, forCellReuseIdentifier: "OccupationViewCell")
        rightTableView.register(OccupationViewCell.self, forCellReuseIdentifier: "OccupationViewCell")
        let path = Bundle.main.path(forResource: "job", ofType: "geojson")
        let JSONData = NSData(contentsOfFile: path!)
        let JSONObject = try? JSONSerialization.jsonObject(with: JSONData! as Data, options: JSONSerialization.ReadingOptions.allowFragments)
        self.leftDataSource  =   Mapper<OccupationType>().mapArray(JSONObject: JSONObject)!
        
    }

}
extension OccupationViewController:UITableViewDelegate,UITableViewDataSource{
    func initTableView(){
    
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "OccupationViewCell") as! OccupationViewCell
        if  tableView == leftTableView {
            cell.occupationType = leftDataSource[indexPath.row]
            return cell
        }
        cell.occupation = rightDataSource[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  tableView == leftTableView {
            return self.leftDataSource.count
        }
        return self.rightDataSource.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  tableView == leftTableView {
            let model = leftDataSource[indexPath.row]
            leftDataSource.map{$0.selected}.forEach({ (seleted) in
                seleted.value = false
            })
            model.selected.value = true
            rightDataSource = model.data
            rightTableView.reloadData()
            
        }else{
            let model = rightDataSource[indexPath.row]
           _ =  self.navigationController?.popViewController(animated: true)
            Observable.just(model).bindTo(result).addDisposableTo(rx_disposeBag)
            row.value = model
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
class OccupationViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = UIColor.colorWithHexString("#333333")
        textLabel?.font = UIFont.systemFont(ofSize: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var occupationType:OccupationType!{
        didSet{
            occupationType.selected.asObservable().map{$0 == true ? bgColor : UIColor.white}.bindTo(rx.backgroundColor).addDisposableTo(rx_reusableDisposeBag)
                textLabel?.text = occupationType.name
        }
    }
    var occupation :String!{
        didSet{
            textLabel?.text = occupation
          backgroundColor = bgColor
        }
    }
}

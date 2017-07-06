
//
//  ComplaintViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyDrop
import RxSwift
struct ComplaintModel {
    var title = ""
    var check:Variable<Bool> = Variable(false)
    init?(map: Map) {}
    mutating func mapping(map: Map) {
        title <- map["title"]
    }
    init(title : String) {
        self.title = title
    }

}
class ComplaintViewController: UIViewController {
    public var appelleeUserInfoId = 0
    var dataSource = [ComplaintModel]()
        var reason: String?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ComplaintViewCell", bundle: nil), forCellReuseIdentifier: "ComplaintViewCell")
        tableView.delegate  = self
        tableView.dataSource = self
        let model1 = ComplaintModel(title: "威胁辱骂")
        model1.check.value = true
        let model2 = ComplaintModel(title: "色情骚扰")
        let model3 = ComplaintModel(title: "血腥暴力")
        let model4 = ComplaintModel(title: "提供色情服务")
        let model5 = ComplaintModel(title: "欺诈(酒托、话费托等)")
        let model6 = ComplaintModel(title: "违法行为(诈骗、违禁品、反动等)")
        let model7 = ComplaintModel(title: "TA的账号被盗用了")
        let model8 = ComplaintModel(title: "冒充他人")
        dataSource += [model1,model2,model3,model4,model5,model6,model7,model8]
        reason = "威胁辱骂"
    }

    @IBAction func done(_ sender: Any) {
        guard let reason = reason else {
            Drop.down("请选择投诉原因！", state: .error)
            return
        }
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "提交中...", for: view)).addDisposableTo(rx_disposeBag)
     let request =  RequestProvider.request(api: ParametersAPI.complain(appelleeUserInfoId: appelleeUserInfoId, reason: reason)).mapObject(type: EmptyModel.self)
        .trackActivity(activityIndicator)
        .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        
        request.flatMap{$0.unwarp()}
        .subscribe(onNext: {[unowned self] (_) in
            _ = self.navigationController?.popViewController(animated: true)
            Drop.down("投诉用户成功！", state: .success)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    
    }
}
extension ComplaintViewController : UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplaintViewCell") as! ComplaintViewCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        dataSource.forEach { (m ) in
            m.check.value = false
        }
            model.check.value = true
        reason = model.title
    }
    
}

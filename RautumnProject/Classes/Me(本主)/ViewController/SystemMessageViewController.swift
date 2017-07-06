
//
//  SystemMessageViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
class SystemMessage: NSObject ,NSCoding{
    var title = ""
    var message = ""
    var time = ""
    override init() {
    super.init()
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(message, forKey: "message")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(time, forKey: "time")
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        message = aDecoder.decodeObject(forKey: "message") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
        time = aDecoder.decodeObject(forKey: "time") as! String
    }
}
class SystemMessageViewController: UITableViewController {
    var dataSource = [SystemMessage]()
    var emptyDisplayCondition = false
    override func viewDidLoad() {
        do{
            FORScrollViewEmptyAssistant.empty(withContentView: tableView, configerBlock: { (configer) in
                configer?.emptyTitleFont = UIFont.systemFont(ofSize: 20)
                configer?.emptySubtitle = "暂无系统消息！"
                //                configer?.emptyImage =  UIImage(named:"placeholder_instagram")
                configer?.emptySpaceHeight = 20
                configer?.shouldDisplay = {
                    return self.emptyDisplayCondition
                }
            })
        }
        tableView.separatorStyle = .none
        tableView.backgroundColor = bgColor
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "SystemMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SystemMessageTableViewCell")
        super.viewDidLoad()
        if  let messages = DBTool.shared.sysTemMessages() {
            dataSource += messages
            log.info("messsage----\(messages)")
            self.emptyDisplayCondition = true
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "清空")
        self.navigationItem.rightBarButtonItem!.rx.tap
            .subscribe(onNext: {[unowned self] (_) in
              DBTool.shared.removeAllSysTemMessages()
                self.dataSource.removeAll()
                self.tableView.reloadData()
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemMessageTableViewCell") as! SystemMessageTableViewCell
        cell.sysTemMessage = dataSource[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sysTemMessage = dataSource[indexPath.row]
        let vc = SystemMessageDetailViewController()
        vc.title = sysTemMessage.title
        vc.message = sysTemMessage.message
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
class SystemMessageDetailViewController: UIViewController {
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = UITextView(frame: view.bounds)
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textView)
       textView.isEditable = false
        textView.text = message
    }
}

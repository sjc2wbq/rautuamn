//
//  CommentViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import SwiftyDrop
class CommentViewController: UIViewController {
    let maxCount = 200
    var type = 0
    var commentType = 1
    var objId  = ""
    @IBOutlet weak var textView: KMPlaceholderTextView!

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(CommentViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "写评论"
        textView.text = "sdasdas"
        switch type {
        case 0:
            textView.placeholder = "写下您对这篇文章的看法！"
        case 1:
            textView.placeholder = "写下您对这篇图文的看法！"
        case 2:
            textView.placeholder = "写下您对这个视频的看法！"
        default:
            textView.placeholder = "写下您对这个音频的看法！"
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWithTitle(title: "取消")
        self.navigationItem.leftBarButtonItem!.rx.tap.subscribe(onNext: {[unowned self] (indexPath) in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }).addDisposableTo(rx_disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "提交")
        let count = textView.rx.text.map{$0}.shareReplay(1)
        count.map{$0!.characters.count > 0  && $0!.characters.count <= self.maxCount && $0?.isEmptyString() == false}.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)

        let activityIndicator = ActivityIndicator()
        
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)

        
        activityIndicator.asObservable()
            .do(onNext: {[unowned self] (_) in
                self.textView.text = nil
            })
            .map{!$0}.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)
        

      let request =  self.navigationItem.rightBarButtonItem!.rx.tap
        .do(onNext: {_ in
            self.textView.endEditing(true)
        })
            .withLatestFrom(textView.rx.text)
            .unwrap()
            .flatMap{RequestProvider.request(api: ParametersAPI.comment(objId: self.objId, content: $0, type: self.commentType)).mapObject(type: Rautumnfriendscirclecom.self)
            .trackActivity(activityIndicator)
        }
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}
        .unwrap()
        .subscribe(onNext: { (model) in
            Drop.down("评论成功！", state: .success)
          self.dismiss(animated: true, completion: { 
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PostCommtentNotifation"), object: model as Any?)
          })
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
         Drop.down(error, state: .error)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
    
        
    
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

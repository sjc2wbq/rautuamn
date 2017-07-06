//
//  FeedBackViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
import RxSwift
import UIKit
import SwiftyDrop
import KMPlaceholderTextView
class FeedBackViewController: UIViewController {
    @IBOutlet weak var textView: KMPlaceholderTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithTitle(title: "提交")
        let count = textView.rx.text.map{$0!.characters.count}.shareReplay(1)
        count.map{$0 > 0  && $0 <= 200}.bindTo(self.navigationItem.rightBarButtonItem!.rx.isEnabled).addDisposableTo(rx_disposeBag)
        
        let activityIndicator = ActivityIndicator()
        activityIndicator.asObservable().bindTo(isLoading(showTitle: "提交中...", for: view)).addDisposableTo(rx_disposeBag)
        
       let request = self.navigationItem.rightBarButtonItem!.rx.tap
        .do(onNext: {_ in
          self.view.endEditing(true)
        })
        .withLatestFrom(textView.rx.text)
        .unwrap()
        .flatMap{ RequestProvider.request(api: ParametersAPI.feedback(content: $0)).mapObject(type: EmptyModel.self)
            .trackActivity(activityIndicator)

        }
        .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.subscribe(onNext: {[unowned self] (_) in
            _ = self.navigationController?.popViewController(animated: true)
            Drop.down("意见反馈成功！", state: .success)
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

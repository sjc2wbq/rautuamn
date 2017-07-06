//
//  NearOpinionPollsDetailViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/4.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import SDAutoLayout
import SwiftyDrop
class NearOpinionPollsDetailViewController: UITableViewController {
      public var rfcmId = 0
    fileprivate var model:RfcmDetailsModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(NearOpinionPollsDetailViewController.self)", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        title = "镭秋民调"
        do{
        tableView.register(UINib(nibName: "NearOpinionPollsDetailViewCell", bundle: nil), forCellReuseIdentifier: "NearOpinionPollsDetailViewCell")
        }
        
               fetchData()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearOpinionPollsDetailViewCell") as! NearOpinionPollsDetailViewCell

        do{
            let activityIndicator = ActivityIndicator()
            
            activityIndicator.asObservable().bindTo(self.isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
            let request =  cell.btn_result.rx.tap
                .withLatestFrom(Observable.of(self.model))
                .unwrap()
                .filter{$0.vote == false}
                .flatMap{ _ -> Observable<Result<ResponseInfo<EmptyModel>>> in
                    RequestProvider.request(api: ParametersAPI.rfcmv(rfcmId: self.rfcmId, optionADC: cell.answer))
                        .mapObject(type: EmptyModel.self)
                        .trackActivity(activityIndicator)
                    
                }
                .shareReplay(1)
            
            request.flatMap{$0.error}.map{$0.domain}
                .subscribe(onNext: { (error) in
                    Drop.down(error, state: .error)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
            
            request.flatMap{$0.unwarp()}.map{$0.result_data}
                .subscribe(onNext: {[unowned self] (_) in
                    self.model?.option = cell.answer
                    self.model?.vote = true
                    self.tableView.reloadData()
                    let vc = NearOpinionPollsStatisticalController()
                    vc.rfcmId = self.rfcmId
                    self.navigationController?.pushViewController(vc, animated: true)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)
            
            cell.btn_result.rx.tap
                .withLatestFrom(Observable.of(self.model))
                .unwrap()
                .filter{$0.vote == true}
            .subscribe(onNext: {[unowned self] (_) in
                let vc = NearOpinionPollsStatisticalController()
                vc.rfcmId = self.rfcmId
                self.navigationController?.pushViewController(vc, animated: true)
                
            }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(cell.rx_reusableDisposeBag)

        }

        
        cell.model = model
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight(for: indexPath, cellContentViewWidth: screenW, tableView: tableView)
    }
}
extension NearOpinionPollsDetailViewController{
    fileprivate func fetchData(){
        let activityIndicator = ActivityIndicator()
   
 let request =  RequestProvider.request(api: ParametersAPI.rfcmDetails(rfcmId: rfcmId)).mapObject(type: RfcmDetailsModel.self)
    .trackActivity(activityIndicator)
        .shareReplay(1)
        request.flatMap{$0.error}.map{$0.domain}
        .subscribe(onNext: { (error) in
            Drop.down(error, state: .error)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
    
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
        .subscribe(onNext: { (model) in
            self.model = model
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

    }
}

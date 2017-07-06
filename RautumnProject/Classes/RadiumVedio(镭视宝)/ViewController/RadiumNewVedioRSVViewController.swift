//
//  RadiumNewVedioRSVViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftyDrop

class RadiumNewVedioRSVViewController: RadiumBaseVedioRSVViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        fecthData = {
            self.loadData()
        }
    }
    func loadData(){
        
        if self.page == 1{
            if let model = DBTool.shared.rav(type: 1){
                var frames = [RvUsefulFrame]()
                if self.page == 1{
                    model.data.forEach({ (rvUseful) in
                        let frame = RvUsefulFrame()
                        frame.rvUseful = rvUseful
                        frames.append(frame)
                    })
                    self.dataSource = frames
                    self.tableView.reloadData()
                }
            }
        
        }
        
        let request = RequestProvider.request(api: ParametersAPI.rvUseful(type: 1, newOrHot: 1, pageIndex: page))
            .mapObject(type: RvUsefulModel.self)
            .shareReplay(1)
        
        request.flatMap{$0.error}.map{$0.domain}
            .subscribe(onNext: { (error) in
                self.tableView.st_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                Drop.down(error, state: .error)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: { (model) in
                var frames = [RvUsefulFrame]()
                if self.page == 1{
                    DBTool.shared.saveRSV(model: model, type: 1)
                    model.data.forEach({ (rvUseful) in
                        var frame = RvUsefulFrame()
                        frame.rvUseful = rvUseful
                        frames.append(frame)
                    })
                    self.dataSource = frames
                    self.tableView.st_header.endRefreshing()
                    self.emptyDisplayCondition = true

                }else{
                    if model.data.count == 0{
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        model.data.forEach({ (rvUseful) in
                            var frame = RvUsefulFrame()
                            frame.rvUseful = rvUseful
                            frames.append(frame)
                        })
                        
                        self.dataSource += frames
                        self.tableView.mj_footer.endRefreshing()
                    }
                }
                self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
}

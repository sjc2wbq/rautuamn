//
//  NearOpinionPollsStatisticalController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
class NearOpinionPollsStatisticalController: UIViewController {
    
     let PNGreen = UIColor(red: 77.0/255.0, green: 186.0/255.0, blue: 122.0/255.0, alpha: 1.0)
     let PNLightGreen = UIColor.colorWithHexString("#ffcf47")
     let PNFreshGreen = UIColor.colorWithHexString("#5a9bef")
     let PNDeepGreen = UIColor.colorWithHexString("#ef5361")
    
     let PNGrey = UIColor(red: 186.0/255.0 , green: 186.0/255.0, blue: 186.0/255.0, alpha: 1.0)
     let PNLightGrey = UIColor(red: 246.0 / 255.0 , green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
     let PNDeepGrey = UIColor(red: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    
     let PNLightBlue = UIColor(red: 94.0/255.0, green: 147.0/255.0, blue: 246.0/255.0, alpha: 1.0)
     let PNBule = UIColor(red: 82.0/255.0, green: 116.0/255.0, blue: 188.0/255.0, alpha: 1.0)
     let PNDarkBlue = UIColor(red: 121.0/255.0, green: 134.0/255.0, blue: 142.0/255.0, alpha: 1.0)
     let PNTwitterBlue = UIColor(red: 0.0/255.0, green: 171.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    
     let PNRed = UIColor(red: 245.0/255.0, green: 94.0/255.0, blue: 78.0/255.0, alpha: 1.0)
    
    public var rfcmId = 0
    public var model:StatisticalModel?
   fileprivate let descLabel = UILabel(frame: CGRect(x: 15, y: 15, width: screenW - 30, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "查看结果"
        fetchData()
        descLabel.numberOfLines = 0
        view.addSubview(descLabel)
        view.backgroundColor = bgColor
    }
  fileprivate func fetchData(){
  let request = RequestProvider.request(api: ParametersAPI.rfcmvCount(rfcmId: rfcmId)).mapObject(type: StatisticalModel.self)
    .shareReplay(1)
    request.flatMap{$0.error}.map{$0.domain}
    .subscribe(onNext: { (error) in
        
    }, onError: nil, onCompleted: nil, onDisposed: nil)
    .addDisposableTo(rx_disposeBag)
    
    request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
    .subscribe(onNext: {[unowned self] (model) in
        self.model = model
        
        let item1 = PNPieChartDataItem(dateValue: CGFloat(model.optionACount / model.optionABCCount), dateColor:  self.PNLightGreen, description: CGFloat(model.optionACount / model.optionABCCount) == 0 ? "" : model.optionA)
        let item2 = PNPieChartDataItem(dateValue: CGFloat(model.optionBCount / model.optionABCCount), dateColor: self.PNFreshGreen, description:CGFloat(model.optionBCount / model.optionABCCount) == 0 ? "" : model.optionB)
        let item3 = PNPieChartDataItem(dateValue: CGFloat(model.optionCCount / model.optionABCCount), dateColor: self.PNDeepGreen, description:CGFloat(model.optionCCount / model.optionABCCount) == 0 ? "" : model.optionC)
        
        let frame = CGRect(x: (self.view.bounds.size.width - 240.0) / 2, y: (self.view.bounds.size.height - 240.0) / 2 - 100, width: 240.0, height: 240.0)
        let items: [PNPieChartDataItem] = [item1, item2, item3]
        let pieChart = PNPieChart(frame: frame, items: items)
        pieChart.descriptionTextColor = UIColor.white
        pieChart.descriptionTextFont = UIFont(name: "Avenir-Medium", size: 14.0)!
        pieChart.center = self.view.center
        
              self.view.addSubview(pieChart)
        self.descLabel.text = "目前有 \(Int(model.optionABCCount))位镭秋用户参与民调，\(Int(model.optionACount))人支持\(model.optionA)， \(Int(model.optionBCount))人支持\(model.optionB)，\(Int(model.optionCCount))人支持\(model.optionC)。"
    }, onError: nil, onCompleted: nil, onDisposed: nil)
    .addDisposableTo(rx_disposeBag)
    
    }
}

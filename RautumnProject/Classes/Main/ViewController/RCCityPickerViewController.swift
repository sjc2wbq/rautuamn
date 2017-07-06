

//
//  RCCityPickerViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/20.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SwiftLocation
class RCCityPickerViewController: CityPickerViewController,CityPickerViewControllerDelegate {
    var city = ""
    override func viewDidLoad() {
        cityModels = cityModelsPrepare()
        currentCity = "定位中..."
        hotCities = ["成都", "深圳", "上海", "长沙", "杭州", "南京", "徐州", "北京"];
        self.delegate = self
        super.viewDidLoad()
        title = "城市选择"
    }
    func cityPickerViewController(_ cityPickerViewController: CityPickerViewController!, selectedCityModel: CityModel!) {
//        row.value =  selectedCityModel.name
        _ = self.navigationController?.popViewController(animated: true)
    }
}

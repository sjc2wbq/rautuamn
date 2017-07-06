//
//  CityRow.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/30.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import Eureka

 final class CityRow : SelectorRow<PushSelectorCell<String>, CityViewController>, RowType {
     required init(tag: String?) {
        super.init(tag: tag)
    
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return CityViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        displayValueFor = {
            guard let text = $0 else { return "选择城市" }
            return text
        }
    }
}
class CityViewController: CityPickerViewController , TypedRowControllerType,CityPickerViewControllerDelegate {
    public var row: RowOf<String>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    override func viewDidLoad() {
        cityModels = cityModelsPrepare()
        currentCity = "成都"
        hotCities = ["成都", "深圳", "上海", "长沙", "杭州", "南京", "徐州", "北京"];
        self.delegate = self
        super.viewDidLoad()
        title = "城市选择"
    }
    func cityPickerViewController(_ cityPickerViewController: CityPickerViewController!, selectedCityModel: CityModel!) {
            row.value =  selectedCityModel.name
        _ = self.navigationController?.popViewController(animated: true)
    }
}




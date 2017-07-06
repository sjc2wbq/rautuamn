//
//  VIPOrderSettingListModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
struct VIPOrderSettingListModel {
    var vipSettings: [Vipsetting] = []
    
    init?( map: Map) {}
}

extension VIPOrderSettingListModel: Mappable {
    mutating func mapping(map: Map) {
        vipSettings <- map["vipSettings"]
    }
}

// MARK: - Vipsetting

struct Vipsetting {
    var selected  =  Variable(false)
    var preferentialQuota : Float = 0
    var month = 0
    var type = 0
    var price : Float = 0
    var discountEndDate = ""
    var id = 0
    init?( map: Map) {}
}

extension Vipsetting: Mappable {
    mutating func mapping(map: Map) {
        preferentialQuota <- map["preferentialQuota"]
        id <- map["id"]
        month <- map["month"]
        type <- map["type"]
        price <- map["price"]
        discountEndDate <- map["discountEndDate"]
    }
}


//
//  MyWalletModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import ObjectMapper
struct MyWalletModel {
    var countDate: [Wallet] = []
    var rautumnCurrency : Float = 0
    init?( map: Map) {}
}

extension MyWalletModel: Mappable {
    mutating func mapping(map: Map) {
        countDate <- map["countDate"]
        rautumnCurrency <- map["rautumnCurrency"]
    }
}
// MARK: - Wallet

struct Wallet {
    var countRautumnCurrency = ""
    var date = ""
    var typeName = ""
    init() {}
    init?( map: Map) {}
}

extension Wallet: Mappable {
    mutating func mapping(map: Map) {
        countRautumnCurrency <- map["countRautumnCurrency"]
        date <- map["date"]
        typeName <- map["type_name"]
    }
}
extension Wallet: IdentifiableType,Equatable {
    var identity: Int {
        return 1
    }
}
func ==(lhs: Wallet, rhs: Wallet) -> Bool {
    return lhs.date == rhs.date
}

//
//  PublishRFCMParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources
struct PublishRFCMParam {
    /*
     userId 	是 	int 	用户ID
     title 	是 	string 	标题
     optionA 	是 	string 	选项A
     optionB 	是 	string 	选项B
     optionC 	是 	string 	选项C
     endEffectiveDate 	是 	string 	截止有效日期（格式：yyyy-MM-dd HH:mm）
     */
    var action = "publishRFCM"
    var userId = UserModel.shared.id
    var title = ""
    var optionA = ""
    var optionB = ""
    var optionC = ""
    var endEffectiveDate = ""
    init() {}
}

extension PublishRFCMParam:Mappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    public init?(map: Map) {
        
    }


    mutating func mapping(map: Map) {
        action    <- map["action"]
        userId    <- map["userId"]
        title    <- map["title"]
        optionA    <- map["optionA"]
        optionB    <- map["optionB"]
        optionC    <- map["optionC"]
        endEffectiveDate    <- map["endEffectiveDate"]
    }
}


struct RauFriCivilMediationModel {
    var rauFriCivilMediations: [Raufricivilmediation] = []
    
    init( map: Map) {}
}

extension RauFriCivilMediationModel: Mappable {
    mutating func mapping(map: Map) {
        rauFriCivilMediations <- map["rauFriCivilMediations"]
    }
}

// MARK: - Raufricivilmediation

struct Raufricivilmediation {
    var closingDateTime = ""
    var id = 0
    var title = ""
    
    init( map: Map) {}
}

extension Raufricivilmediation: Mappable {
    mutating func mapping(map: Map) {
        closingDateTime <- map["closingDateTime"]
        id <- map["id"]
        title <- map["title"]
    }
}

extension Raufricivilmediation: IdentifiableType,Equatable {
    var identity: Int {
        return id
    }
}
func ==(lhs: Raufricivilmediation, rhs: Raufricivilmediation) -> Bool {
    return lhs.id == rhs.id
}

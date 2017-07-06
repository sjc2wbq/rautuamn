//
//  NewFriendModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/18.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import RxDataSources
struct NewFriendModel {
    var friends: [NewFriend] = []
    
    init() {}
    init( map: Map) {}
}

extension NewFriendModel: Mappable {
    mutating func mapping(map: Map) {
        friends <- map["friends"]
    }
}

// MARK: - Friend

struct NewFriend {
    var state = Variable(0)
    var applyJoinGroupId = 0
    var nickname = ""
    var userId = 0
    var headPortUrl = ""
    var fId = 0
    var msg = ""
    var isGroup = false
    
    init() {}
    
    init( map: Map) {}
}

extension NewFriend: Mappable {
    mutating func mapping(map: Map) {
        msg <- map["msg"]
        fId <- map["fId"]
        state.value <- map["state"]
        nickname <- map["nickname"]
        userId <- map["userId"]
        headPortUrl <- map["headPortUrl"]
    }
}
extension NewFriend: IdentifiableType,Equatable {
    var identity: Int {
        return userId
    }
}
func ==(lhs: NewFriend, rhs: NewFriend) -> Bool {
    return lhs.userId == rhs.userId
}



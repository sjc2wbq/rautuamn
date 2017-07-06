//
//  AppImg.swift
//  RautumnProject
//
//  Created by Kun Huang on 2017/6/1.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper

struct AppImg {
    
    var coverImageUrl = ""
    var list = [String]();
    
    init?(map: Map) {}
    
}

extension AppImg: Mappable {
    mutating func mapping(map: Map) {
        coverImageUrl <- map["coverImage"]
        list <- map["list"]
    }
}



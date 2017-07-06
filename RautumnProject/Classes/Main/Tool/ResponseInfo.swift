//
//  ResponseData.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/7/13.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
 enum Result<T> {
    case success(T)
    case failure(NSError)

    func map<V>(transform: (T) throws -> V) -> Result<V> {
        switch self {
        case let .success(value):
            do {
                return Result<V>.success(try transform(value))
            } catch {
                return Result<V>.failure(error as NSError)
            }
        case let .failure(error):
            return Result<V>.failure(error)
        }
    }
//    func mapValue<V>(transform: (T) throws -> V) -> V {
//        switch self {
//        case let .success(value):
//            do {
//                return try transform(value)
//            } catch {
//                return "" as! V
//            }
//        case .failure:
//            return "" as! V
//        }
//
//    }
    func unwarp() -> Observable<T> {
        switch self {
        case let .success(value):
            return Observable.just(value)
        case .failure:
            return Observable.empty()
        }
    }

    var error: Observable<NSError> {
        switch self {
        case .success:
            return Observable.empty()
        case let .failure(error):
            return Observable.just(error)
        }
    }
}
public struct ResponseInfo<T: Mappable>:Mappable{
    var message:String!
    var result_code:String!
    var result_data:T?
    init(){  }
     public init?(map: Map){  }
    
  mutating  public func mapping(map: Map) {
        message    <- map["message"]
        result_code   <- map["result_code"]
        result_data   <- map["result_data"]
    }
}

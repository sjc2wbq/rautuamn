//
//  RadiumFriendsAddressBooKViewModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/16.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import SwiftyDrop
import ObjectMapper
import RxSwift
enum RefreshStatus: Int {
    case headerRefreshFinish
    case noHasNextPage
    case hasNextPage
    case invalid
    case loadDataFailure
    
}

class RefreshViewModel {
    let disposeBag = DisposeBag()
    let refreshState = Variable(RefreshStatus.invalid)
    var page = Variable(1)
    
}
class RadiumFriendsAddressBooKViewModel: NSObject {
    //Friend
    typealias TableSectionModel = AnimatableSectionModel<String, Friend>
    let dataSource = RxTableViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Friend]()
  
    func fetchData(finish:((Void) -> Void)?) {
        let headerResponse  =
            RequestProvider.request(api: ParametersAPI.rauFriendRecord(pageIndex: 1)).mapObject(type: RadiumFriendsAddressBooK.self)
                .shareReplay(1)
        if let addressBook = DBTool.shared.addressBook(){
           let model =  Mapper<RadiumFriendsAddressBooK>().map(JSON: addressBook)
            
            self.sections.value = [TableSectionModel(model: "新的朋友", items:  [Friend()]),
                                   TableSectionModel(model: "镭约吧", items:  [Friend()]),
                                   TableSectionModel(model: "", items:  model!.friends),
                                   TableSectionModel(model: "您现在有\(model!.friends.count)位镭友，加油哟！", items:  [Friend()])]
        }
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { [unowned self] (model ) in
            DBTool.shared.saveAddressBook(dict: Mapper<RadiumFriendsAddressBooK>().toJSON(model))
            
            finish?()
            self.items = model.friends
            self.sections.value = [TableSectionModel(model: "新的朋友", items:  [Friend()]),
                                   TableSectionModel(model: "镭约吧", items:  [Friend()]),
                                   TableSectionModel(model: "", items:  self.items),
                                   TableSectionModel(model: "您现在有\(self.items.count)位镭友，加油哟！", items:  [Friend()])]
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
//            Drop.down("", state: .error)
            finish?()
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }


}

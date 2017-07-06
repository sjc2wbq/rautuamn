//
//  Rx+Extension.swift
//  ObjectsProject
//
//  Created by Raychen on 2016/10/20.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import MJRefresh
//import JCAlertView
import RxSwift
import RxCocoa
extension Reactive where Base: UILabel {
    
    /**
     Bindable sink for `textColor` property.
     */
    public var textColor: AnyObserver<UIColor> {
        return UIBindingObserver(UIElement: self.base) { label, textColor in
            label.textColor = textColor
            }.asObserver()
    }

    
}
extension Reactive where Base: UITableViewCell {
    

    public var backgroundColor: AnyObserver<UIColor> {
        return UIBindingObserver(UIElement: self.base) { cell, backgroundColor in
            cell.backgroundColor = backgroundColor
            }.asObserver()
    }
    
    
}
//
/*
 self.tableView.st_header = STRefreshHeader(refreshingBlock: {[unowned self] (header) in
 self.pageIndex = 1
 self.fecthData?()
 })
 */
extension Reactive where Base  : STRefreshHeader{
    var refresh:Observable<Void>{
        return  Observable.create({ [weak control = self.base]  (observer) -> Disposable in
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            control.beginRefreshing(completionBlock: { _ in 
                observer.on(.next(Void()))
                //                observer.onCompleted()
                
            })
            return Disposables.create()
        })
            .shareReplay(1)
    }
    
}
extension Reactive where Base: MJRefreshHeader {
    var refresh:Observable<Void>{
        return  Observable.create({ [weak control = self.base]  (observer) -> Disposable in
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            control.beginRefreshing(completionBlock: {
                observer.on(.next(Void()))
//                observer.onCompleted()
                
            })
            return Disposables.create()
            })
        .shareReplay(1)
    }
    
}
extension Reactive where Base: MJRefreshFooter {
    var refresh:Observable<Void>{
        return  Observable.create({ [weak control = self.base]  (observer) -> Disposable in
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            control.beginRefreshing(completionBlock: {
                observer.on(.next(Void()))
//                observer.onCompleted()
                
            })
            return Disposables.create()
            })
        .shareReplay(1)
    }

}

extension Reactive where Base: UIView {
    
    /// Bindable sink for `enabled` property.
    public var isUserInteractionEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.isUserInteractionEnabled = value
        }
    }
}

//extension Reactive where Base: JCAlertView {
//    var dismiss:Observable<Void>{
//        return  Observable.create({ [weak control = self.base]  (observer) -> Disposable in
//            guard let control = control else {
//                observer.on(.completed)
//                return Disposables.create()
//            }
//             control.dismiss(completion: {
//                observer.on(.next(Void()))
////                observer.on(.completed)
//             })
//            return Disposables.create()
//            })
//    }
//    
//}
//
extension ObservableType{
    public func subscribe(onNext: ((E) -> Void)? = nil) -> Disposable{
   return  subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }


}

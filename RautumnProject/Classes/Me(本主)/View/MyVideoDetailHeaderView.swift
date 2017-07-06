

//
//  MyVideoDetailHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/23.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class MyVideoDetailHeaderView: UIView {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_vover: UIImageView!
    @IBOutlet weak var img_paly: UIImageView!
    @IBOutlet weak var lb_timeAndPlayCount: UILabel!
    @IBOutlet weak var lb_commentCount: UILabel!
    @IBOutlet weak var lb_price: UILabel!
    
    static func headerView() -> MyVideoDetailHeaderView{
        return Bundle.main.loadNibNamed("MyVideoDetailHeaderView", owner: nil, options: nil)![0] as! MyVideoDetailHeaderView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        img_paly.addGestureRecognizer(tap)
    }
    var rsv :MyRSV!{
        didSet{
            lb_title.text = rsv.title
            img_vover.sd_setImage(with: URL(string:rsv.coverPhotoUrl), placeholderImage: placeHolderImage)

            rsv.playTimes.asObservable().map{"\(self.rsv.time)  播放：\($0)次"}.bindTo(lb_timeAndPlayCount.rx.text)
            .addDisposableTo(rx_disposeBag)
            
            lb_commentCount.text = "\(rsv.commentCount)"
            lb_price.text = "￥\(rsv.countRC.value)"

        }
    }
    
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:rsv.videoUrl.replacingOccurrences(of: "%2F", with: "/"))
        self.viewController?.present(vc, animated: true, completion: nil)
        
        let request = RequestProvider.request(api: ParametersAPI.rsvPlayTimes(rsvId: "\(self.rsv.id)"))
            .mapObject(type: EmptyModel.self)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            self.rsv.playTimes.value = self.rsv.playTimes.value + 1
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.subscribe(onNext: { (_) in
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        
    }
}

//
//  HKPlayer.swift
//  RautumnProject
//
//  Created by xilaida on 2017/5/23.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit


class HKPlayer: NSObject {

    enum PlayerStatus:String {
        case Start = "start"
        case Unknown = "unknown"
        case Failed = "failed"
    }
    
    typealias PlayEndClosure = () -> Void
    typealias StatusClosure = (_ status:String) -> Void
    typealias PlayScaleClosure = (_ scale:Int) -> Void
    
    private var player:AVPlayer?
    private var playerOfNative:AVAudioPlayer?
    var playEnd:PlayEndClosure?
    var playStatus:StatusClosure?
    var playScale:PlayScaleClosure?
    var isComeIn:Bool = false
    
    private var audioPlayer: PLAudioPlayer?
    
    var periodicTimeObserver:Any?
    
    deinit {
        remove()
        print("deinit")
    }
    
    // MARK:---Singleton
    static let instance = HKPlayer()
    private override init() {}
    
 
    func playMusic(urlString:String!) {
        
        if isComeIn {
            print("remove")
            remove()
        }
        
        let url = URL(string: urlString)!
        player = AVPlayer(playerItem: AVPlayerItem.init(url: url))
        addKVO()
        startPlay()
    }
    
    
    func playNativeMusic(pathURL: URL!) {
        
        if isComeIn {
            print("remove")
            remove()
        }
        
        player = AVPlayer(playerItem: AVPlayerItem.init(url: pathURL))
        startPlay()
        
        addKVO()

    }
    
    func addKVO() {
        
        weak var weakSelf = self
        
        periodicTimeObserver = weakSelf?.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main, using: { (time) in
            let currenTime:Float = Float(time.value.hashValue)/(Float(time.timescale.hashValue))
            
            if currenTime >= 0.0 {
                weakSelf?.playScale?(Int(currenTime))
            }

        })
        
       
        
        // 播放完后发出通知
        NotificationCenter.default.addObserver(self, selector: #selector(playDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // 添加观察者，监视播放器的状态 -- Unknown -- ReadyToPlay -- Failed
        player!.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        isComeIn = true
    }
    
    func getLyrics(URL: NSURL!) {
        
    }
    
    // MARK: ----- kvo
    func playDidEnd() {
        print("in--end")
        playEnd!()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            print(player!.status)
            if player!.status == AVPlayerStatus.readyToPlay {
                playStatus?(PlayerStatus.Start.rawValue)
            }
            
            if player!.status == AVPlayerStatus.unknown {
                playStatus?(PlayerStatus.Unknown.rawValue)
            }
            
            if player!.status == AVPlayerStatus.failed {
                playStatus?(PlayerStatus.Failed.rawValue)
            }
        }
    }
    

    func startPlay() {
        print("-------------------")
        player?.play()
    }
    
    func pausePlay() {
        player?.pause()
    }
    
    func stopPlay() {
    
        if player != nil {
            print("tingzhi")
            player?.pause()
            remove()
            player = nil
        }

    }
    
    func remove() {
        
        NotificationCenter.default.removeObserver(self)
        if player != nil {
            
            player!.removeObserver(self, forKeyPath: "status", context: nil)
            if periodicTimeObserver != nil {
                player?.removeTimeObserver(periodicTimeObserver!)
            }
        }
    
    }
}

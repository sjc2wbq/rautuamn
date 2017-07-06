//
//  RecordView.swift
//  RautumnProject
//
//  Created by xilaida on 2017/5/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

enum RecordButtonType {
    case start // 开始录音
    case stop // 停止录音
    case play // 播放
    case stopPlaying // 停止播放
}

class RecordView: UIView,AVAudioRecorderDelegate {

    typealias clickClourse = (_ sender: UIButton, _ mp3Url: URL?, _ lenth: Int) -> Void
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var mp3Url:URL?
    
    var recordTool = LVRecordTool.shared()
    
    var recordType = RecordButtonType.start
    var clourse: clickClourse?
    
    func clickButton(clourse: clickClourse?) {
        self.clourse = clourse
    }
    
    static func recordView() -> RecordView{
        return Bundle.main.loadNibNamed("RecordView", owner: nil, options: nil)!.first as! RecordView
    }
    
    override func awakeFromNib() {
        
        buildUI()

    }
    
    
    deinit {
        
        self.recordTool?.stopPlaying()
        self.recordTool?.stopRecording()
        self.recordTool = nil
    }
    
    // 创建视图
    func buildUI() {
        self.backgroundColor = UIColor.white
      
        recordButton.addTarget(self, action: #selector(handleEvent(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelOrSendEvent(sender:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(cancelOrSendEvent(sender:)), for: .touchUpInside)

    }
    

    @objc fileprivate func cancelOrSendEvent(sender: UIButton) {
        
        self.recordTool?.stopPlaying()
        self.recordTool?.stopRecording()
        
        if sender == self.cancelButton {
            self.recordTool?.destructionRecordingFile()
        }
    
        self.clourse!(sender,recordTool?.recordFileUrl, (recordTool?.time)!)
        
    }
    
    @objc fileprivate func handleEvent(sender: UIButton) {
    
        if recordType == .start {
           recordType = .play
            
            recordButton.setImage(UIImage.init(named: "recodPlay"), for: .normal)
            titleLabel.removeFromSuperview()
            self.addSubview(spectrumView)
            
            recordTool?.startRecording()
            
            weak var weaKRecordTool = self.recordTool
            self.recordTool?.beyoudMaxTimeBlock = {
                weaKRecordTool?.stopRecording()
                self.recordType = .stop
                self.cancelButton.isHidden = false
                self.sendButton.isHidden = false
                self.recordButton.setImage(UIImage.init(named: "recodStop"), for: .normal)
            }
            
            weak var weakSpectrumView = spectrumView
            
            spectrumView.itemLevelCallback = { _ in
                self.recordTool?.recorder.updateMeters()
                let power = self.recordTool?.recorder.averagePower(forChannel: 0)
                weakSpectrumView?.level = CGFloat(power!)
                weakSpectrumView?.timeLabel.text = self.recordTool?.recordTime
               
            }
            
            return
        }
        
        
        if recordType == .stop {
//            cancelButton.isHidden = true
//            sendButton.isHidden = true
            
            recordType = .stopPlaying
            self.recordTool?.playRecordingFile()
            recordButton.setImage(UIImage.init(named: "recodPlay"), for: .normal)
            return
        }
        
        if recordType == .play {
            cancelButton.isHidden = false
            sendButton.isHidden = false
            self.mp3Url = self.recordTool?.recordFileUrl
            recordType = .stop
            
            self.recordTool?.timer.invalidate()
            self.recordTool?.stopRecording()
            
            recordButton.setImage(UIImage.init(named: "recodStop"), for: .normal)
            return
        }
        
        if recordType == .stopPlaying {
            
            self.recordTool?.stopPlaying()
            recordType = .stop
            recordButton.setImage(UIImage.init(named: "recodStop"), for: .normal)
        }
 
    
    }
    
    
    // MARK: -- lazy loading
    lazy var spectrumView: SpectrumView = {
        
        let view:SpectrumView = SpectrumView.init(frame: CGRect.init(x: 15.0, y: 50.0, width:  self.bounds.width-30.0, height:  30))
        view.text = "00:00"
        
        return view
        
    }()
    
    
    
}

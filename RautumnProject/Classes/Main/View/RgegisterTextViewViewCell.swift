//
//  RgegisterMottoViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/29.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import Eureka
import RxSwift
class RgegisterTextViewViewCell: Cell<String>,CellType,UITextViewDelegate {
    let maxCount = 24
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var lb_subtitle: UILabel!

    @IBOutlet weak var lb_count: UILabel!
    @IBOutlet weak var tf: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = UITableViewCellSelectionStyle.none
        tf.rx.setDelegate(self).addDisposableTo(rx_reusableDisposeBag)
       
    }

    override func update() {
        super.update()
        
        let count = tf.rx.text.map{$0!.characters.count}.shareReplay(1)
        count.map {$0 <= self.maxCount ? UIColor.colorWithHexString("#999999") : UIColor.red}
            .bindTo(lb_count.rx.textColor).addDisposableTo(rx_reusableDisposeBag)

        textLabel?.text = nil
        
        if row.title  ==  NSLocalizedString("Motto", comment: "座右铭"){
            lb_title.text = row.title
            lb_subtitle.text = NSLocalizedString("LifeMaxim", comment: "输入您的人生格言")
        }else if row.title == "活动描述"{
            lb_title.text = row.title
            lb_subtitle.text = "输入简单的活动描述"
            lb_count.text = "120字以内"
            count.map {$0 <= 120 ? UIColor.colorWithHexString("#999999") : UIColor.red}
                .bindTo(lb_count.rx.textColor).addDisposableTo(rx_reusableDisposeBag)
        }else{
            lb_title.attributedText = row.attributeTitle
            lb_subtitle.text = NSLocalizedString("SeniorCattlePartyForExample", comment: "例如资深黄牛党")
        }
    }
    
     override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && tf.canBecomeFirstResponder
    }
    
     override func cellBecomeFirstResponder(withDirection direction: Direction) -> Bool {
        return tf.becomeFirstResponder()
    }
    
     override func cellResignFirstResponder() -> Bool {
        return tf.resignFirstResponder()
    }
    //Mark: Helpers
    
    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
            return tf.isFirstResponder ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }
    
    //MARK: TextFieldDelegate
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textView, cell: self)
        if let textAreaConformance = (row as? TextAreaConformance), let _ = textAreaConformance.formatter, textAreaConformance.useFormatterOnDidBeginEditing ?? textAreaConformance.useFormatterDuringInput {
            textView.text = self.displayValue(useFormatter: true)
        }
        else {
            textView.text = self.displayValue(useFormatter: false)
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textView, cell: self)
        textViewDidChange(textView)
        textView.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        
        if let textAreaConformance = row as? TextAreaConformance, case .dynamic = textAreaConformance.textAreaHeight, let tableView = formViewController()?.tableView {
            let currentOffset = tableView.contentOffset
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            tableView.setContentOffset(currentOffset, animated: false)
        }
        guard let textValue = textView.text else {
            row.value = nil
            return
        }
        guard let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter else {
            row.value = textValue.isEmpty ? nil : (String.init(string: textValue) ?? row.value)
            return
        }
        if fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<String>.allocate(capacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? String
                guard var selStartPos = textView.selectedTextRange?.start else { return }
                let oldVal = textView.text
                textView.text = row.displayValueFor?(row.value)
                selStartPos = (formatter as? FormatterProtocol)?.getNewPosition(forPosition: selStartPos, inTextInput: textView, oldValue: oldVal, newValue: textView.text) ?? selStartPos
                textView.selectedTextRange = textView.textRange(from: selStartPos, to: selStartPos)
                return
            }
        }
        else {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<String>.allocate(capacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? String
            }
        }
    }
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
        textView.endEditing(true)
        }
        return formViewController()?.textInput(textView, shouldChangeCharactersInRange: range, replacementString: text, cell: self) ?? true
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textView, cell: self) ?? true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textView, cell: self) ?? true
    }
    
}
//MARK: RgegisterMottoRow
final class RgegisterTextViewRow: Row<RgegisterTextViewViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<RgegisterTextViewViewCell>(nibName: "RgegisterTextViewViewCell")
    }
}

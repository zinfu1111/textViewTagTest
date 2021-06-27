//
//  ViewController.swift
//  textViewTagTest
//
//  Created by 連振甫 on 2021/6/27.
//

import UIKit

struct member {
    let name:String
    let id:String
}

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView:UITextView!
    
    let members = [member(name: "member1", id: "member1@gmail.com"),member(name: "member2", id: "111")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.delegate = self
        
        textView.text = "@member1 hi member1 @member2 hi member2"
        //刷新樣式
        refresTextView()
        
    }
    
    
    func refresTextView() {
        
        guard let msgText = textView.text else { return }
        textView.attributedText.string
        var newText = NSMutableAttributedString(string: msgText)
        for item in members {
            newText = refreshText(string: newText, username: "@\(item.name)",userid: "\(item.id)")
        }
        newText.addAttribute(NSAttributedString.Key.font, value:UIFont.systemFont(ofSize: 18.0), range: NSRange(location: 0, length: msgText.count))
        textView.attributedText = newText
    }
    
    func refreshText (string: NSMutableAttributedString, username: String, userid:String) -> NSMutableAttributedString {
        let range = (string.string as NSString).range(of: username)
        return setTagStyle(string: string, username: username, range: range, last: range, userid: userid)
    }

    func setTagStyle (string: NSMutableAttributedString, username: String, range: NSRange, last: NSRange, userid:String) -> NSMutableAttributedString {
        if range.location != NSNotFound {
            string.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range)
            string.addAttribute(NSAttributedString.Key.link, value: userid, range: range)
            let start = last.location + last.length
            let end = string.string.count - start
            let stringRange = NSRange(location: start, length: end)
            let newRange = (string.string as NSString).range(of: username, options: [], range: stringRange)
            setTagStyle(string: string, username: username, range: newRange, last: range, userid: userid)
            
        }
        return string
    }


    func textViewDidChange(_ textView: UITextView) {
        
        /**
         1,取得輸入位置
         2.想知道輸入位置是否在tag中，是的話把那段拔掉
         3.判斷輸入位置是否為第一個，如果是得不繼續下面動作
         4.找出距離輸入點最近的tag
         5.找到的話，取出那幾個字的index，看看是否等於數入點座標
         6.不在範圍內就不繼續
         7.在範圍內就把tag移除
         */
        
        //當textView變化時
        guard let message = textView.text,let selectedRange = textView.selectedTextRange  else { return }
        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)-1
        
        //最後輸入位置
        var finalPosition:Int = cursorPosition+1
        
        //想知道輸入位置是否在tag中，是的話把那段拔掉
        var cursorPositionTagStartIndexs:[Int] = []
        var cursorPositionTagEndIndexs:[Int] = []
        var userid = ""
        var nickName = ""
        
        //輸入位置在第一個也返回
        if cursorPosition == 0 {
            refresTextView()
            // and only if the new position is valid
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: finalPosition) {
                // set the new position
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            return
        }
        
        
        
        //輸入位置前面字串的處理
        for i in (0..<cursorPosition+1).reversed(){
            //找出變色的字元
            if (textView.attributedText.attribute(NSAttributedString.Key.foregroundColor, at: i, effectiveRange: nil) != nil),
               let memberid = textView.attributedText.attribute(NSAttributedString.Key.link, at: i, effectiveRange: nil) as? String{
                userid = memberid
                cursorPositionTagStartIndexs.append(i)
            }
            else{
                break
            }
        }
        
        //輸入位置後面字串的處理
        if message.count != cursorPosition  {
            for i in cursorPosition+1..<message.count {
                //找出變色的字元
                if (textView.attributedText.attribute(NSAttributedString.Key.foregroundColor, at: i, effectiveRange: nil) != nil),let memberid = textView.attributedText.attribute(NSAttributedString.Key.link, at: i, effectiveRange: nil) as? String{
                    userid = memberid
                    cursorPositionTagEndIndexs.append(i)
                }
                else{
                    break
                }
            }
        }
        
        //輸入位置不在tag的範圍要返回
        if cursorPositionTagStartIndexs.count == 0 && cursorPositionTagEndIndexs.count == 0 {
            refresTextView()
            // and only if the new position is valid
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: finalPosition) {
                // set the new position
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            return
        }
        
        //tag的範圍
        let willDropIndexs = (cursorPositionTagStartIndexs + cursorPositionTagEndIndexs)
        for index in 0..<message.count where (willDropIndexs.first(where: {index == $0}) != nil) {
            nickName += message[index]
        }
        
        //如果在tag附近做異動就把它刪除
        var newText = ""
        for index in 0..<message.count where (willDropIndexs.first(where: {index == $0}) == nil) {
            newText += message[index]
        }
        
        textView.text = newText
        finalPosition = willDropIndexs.min() ?? cursorPosition+1
        refresTextView()
        // and only if the new position is valid
        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: finalPosition) {
            // set the new position
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        
    }
    
}


extension String{
    
    
    /// 是否為整數
    /// - Returns: ture:是、false:否
    func isPurnInt() -> Bool {

        let scan: Scanner = Scanner(string: self)

        var val:Int = 0

        return scan.scanInt(&val) && scan.isAtEnd

    }
}

// 下標擷取任意位置的便捷方法
extension String {

    var length: Int {
        return self.count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

}

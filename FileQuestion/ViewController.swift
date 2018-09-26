//
//  ViewController.swift
//  FileQuestion
//
//  Created by user on 2018/09/25.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate {

    // バーボタン識別用tag番号
    enum Tag:Int {
        case doneButton = 100, actionButton = 200
    }
    
    // アウトレット
    @IBOutlet weak var fileNameTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    // 元々の大きさ
    var originalFrame:CGRect?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // titleViewのサイズは制約ではできないので、動的に生成
        fileNameTextField.frame = CGRect(x: 0, y: 0, width: self.navigationController!.navigationBar.bounds.width, height: 24)
        fileNameTextField.delegate = self
        
        textView.delegate = self
        
        self.textViewDidEndEditing(textView)
        
        
        // キーボードのイベント受け取り
        NotificationCenter.default.addObserver(self, selector: #selector(changeKeyboardFrame(_:)), name: Notification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        // キーボード隠れたら教えて
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 最初に元々の大きさを保存しておく
        originalFrame = textView.frame
    }
    
    
    // MARK: - targetAction
    // バーボタンを押した時
    @objc func tapButton(_ barButton:UIBarButtonItem ) {
        
        fileNameTextField.endEditing(true)
        textView.endEditing(true)
        
        // 種類に応じて動作を変える
        if barButton.tag == Tag.actionButton.rawValue {
            
            showActionSheet()
        }
        
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleBarButtonItem(tag: .doneButton)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleBarButtonItem(tag: .actionButton)
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        toggleBarButtonItem(tag: .doneButton)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        toggleBarButtonItem(tag: .actionButton)
    }
    
    
    // MARK: - Notificationメソッド
    @objc func changeKeyboardFrame(_ notification: Notification) {
        // キーボードの大きさを得る
        let userInfo = notification.userInfo!
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        var textViewFrame = textView.frame
        textViewFrame.size.height = keyboardFrame.minY - textViewFrame.minY - 5
        textView.frame = textViewFrame
    }
    
    // キーボードが隠れたら
    @objc func keyboardDidHide(_ notification: Notification ) {
        textView.frame = originalFrame!
    }
    
    // MARK: - 自作メソッド
    
    // アクションシートの表示処理
    func showActionSheet() {
        
        let actionSheet = UIAlertController(title: "アクション", message: "", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "保存", style: .default) { (action) in
            // 保存処理
            let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            // 先頭を得れば良い
            var path = pathArray[0]
            
            // ファイル名を付加する
            if let fileName = self.fileNameTextField.text {
                path.append("/"+fileName)
            }
            
            do {
                try self.textView.text.write(toFile: path, atomically: true, encoding: .utf8)
            }catch {
                self.showAlert(message: "保存に失敗")
            }
            
        }
        
        let action2 = UIAlertAction(title: "読み込み", style: .default) { (action) in
            // 読み込み処理
            // 保存処理
            let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            // 先頭を得れば良い
            var path = pathArray[0]
            
            // ファイル名を付加する
            if let fileName = self.fileNameTextField.text {
                path.append("/"+fileName)
            }
            
            do {
                let text = try String(contentsOfFile: path, encoding: .utf8)
                self.textView.text = text
            }catch {
                self.showAlert(message: "読み込みに失敗")
            }
        }
        
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            // 読み込み処理
        }
        
        let action4 = UIAlertAction(title: "クリア", style: .destructive) { (action) in
            self.textView.text = ""
        }
        
        
        actionSheet.addAction(action4)
        actionSheet.addAction(action2)
        actionSheet.addAction(action1)
        actionSheet.addAction(action3)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // アラート表示
    func showAlert(message:String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // バーボタンの入れ替え
    func toggleBarButtonItem(tag:Tag) {
        // ナビゲーションバーのItem
        let item = self.navigationItem
        
        if tag == .actionButton {
            // 右ボタンをActionに入れ替える
            let barButtonAction = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapButton(_:)))
            barButtonAction.tag = Tag.actionButton.rawValue
            
            item.rightBarButtonItem = barButtonAction
        } else {

            // 右ボタンをDoneに入れ替える
            let barButtonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapButton(_:)))
            barButtonDone.tag = Tag.doneButton.rawValue
            
            item.rightBarButtonItem = barButtonDone
        }
    }

}


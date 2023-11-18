//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/22.
//

import UIKit
import Firebase

class AddScheduleViewController: UIViewController, UITextFieldDelegate {

    var userUID: String? //一時的
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var schedule: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var formatDate: String = ""

    var UD: UserDefaults = UserDefaults.standard
    let fireStore = Firestore.firestore()
    
    var alreadySet: String = ""
    
    var originalTitle: String?
    var originalDate: String?
    
    var isDataChanged: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        saveButton.isHidden = true
        closeButton.isHidden = false
        
        isModalInPresentation = true
        
        titleText.delegate = self
        
        // DatePickerの値変更イベントに対して addTarget でハンドラを登録
        schedule.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        if UD.object(forKey: "alreadySet") != nil {
            
            if let alreadySelectDate = UD.object(forKey: "date") as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                
                if let selectedDate = dateFormatter.date(from: alreadySelectDate) {
                    schedule.setDate(selectedDate, animated: true)
                    originalDate = alreadySelectDate
                }
                
                if let title = UD.object(forKey: "title") as? String {
                    titleText.text = title
                    originalTitle = title
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //dateをstring型に変える&日程が入力されたか確認
    @IBAction func dateSelected(_ sender: UIDatePicker) {
            let selectedDate = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            formatDate = dateFormatter.string(from: selectedDate)
            UD.set("日程は入力された", forKey: "scheduleSelected")
        }
    
    func alert() {
            let alert: UIAlertController = UIAlertController(title: "未入力の箇所があります", message: "入力中のデータは保存されません", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default, handler: { action in
                    // 変更がない場合の処理（アラート非表示、画面を閉じる、など）
                    self.dismiss(animated: true, completion: nil)
                }))
            alert.addAction(
                UIAlertAction(title: "キャンセル", style: .cancel, handler: { action in
                    // キャンセルが押された場合の処理
                    // 例: アラートを閉じるなど
                    alert.dismiss(animated: true, completion: nil)
                }))
            present(alert, animated: true, completion: nil)
        }
    
    // UITextFieldDelegateメソッド - TextFieldのテキストが変更された時に呼ばれる
    func textFieldDidChangeSelection(_ textField: UITextField) {
            // TextFieldの値が変更されたときに実行されるコード
            saveButton.isHidden = false
            closeButton.isHidden = true
            isDataChanged = true
        }
    
    @objc func datePickerValueChanged() {
        // DatePickerの値が変更されたときに呼ばれるメソッド
        saveButton.isHidden = false
        closeButton.isHidden = true
        isDataChanged = true
    }
    
    @IBAction func save() {
            if let title = titleText.text, !title.isEmpty,
               let scheduleTouched = UD.object(forKey: "scheduleSelected") as? String, !scheduleTouched.isEmpty { //タイトル欄が変更(入力)されている&日付の値が変更されている
                print("タイトル変更あり&日付の値変更あり")
                if let currentUserUID = Auth.auth().currentUser?.uid { //ユーザーがログインしているかどうか
                    let userData = [
                        "title": title,
                        "date": formatDate
                    ]
                    let userDocRef = self.fireStore.collection("user").document(currentUserUID)
                    let scheduleCollectionRef = userDocRef.collection("schedule")

                    if let originalTitle = originalTitle, let originalDate = originalDate {
                        // 初期値が設定されている場合、Firebase上のデータを更新
                        print("初期値設定されている")
                        let query = scheduleCollectionRef
                            .whereField("title", isEqualTo: originalTitle)
                            .whereField("date", isEqualTo: originalDate)

                        query.getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("データの取得エラー: \(error.localizedDescription)")
                            } else {
                                if let document = querySnapshot?.documents.first {
                                    document.reference.updateData(userData) { (error) in
                                        if let error = error {
                                            print("データの更新エラー: \(error.localizedDescription)")
                                        } else {
                                            print("データが正常に更新されました")
                                            self.dismiss(animated: true, completion: nil)
                                            self.UD.removeObject(forKey: "scheduleSelected")
                                            print("入力したのは", title, self.formatDate)
                                        }
                                    }
                                } else {
                                    print("対象のデータが見つかりませんでした")
                                }
                            }
                        }
                    } else {
                        // 初期値が設定されていない場合、新しいデータを追加
                        print("初期値設定なし")
                        scheduleCollectionRef.addDocument(data: userData) { error in
                            if let error = error {
                                print("データを保存できませんでした: \(error.localizedDescription)")
                            } else {
                                print("データが正常に保存されました")
                                // 画面を閉じるなどの追加の処理を行うことができます
                                self.dismiss(animated: true, completion: nil)
                                self.UD.removeObject(forKey: "scheduleSelected")
                                print("入力したのは", title, self.formatDate)
                            }
                        }
                    }
                } else {
                    print("ユーザーがログインしていません")
                }
            } else { //タイトルもしくは日付の欄が変更されていない(入力されていない)
                let title = titleText.text
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                formatDate = dateFormatter.string(from: schedule.date)
                if let currentUserUID = Auth.auth().currentUser?.uid { //ユーザーがログインしているかどうか
                    let userData = [
                        "title": title!,
                        "date": formatDate
                    ] as [String : Any]
                    let userDocRef = self.fireStore.collection("user").document(currentUserUID)
                    let scheduleCollectionRef = userDocRef.collection("schedule")
                    if let originalTitle = originalTitle, let originalDate = originalDate { //初期値が設定されている場合
                    print("初期値は設定されていてタイトルを変更したい場合")
                        
                        let query = scheduleCollectionRef
                            .whereField("title", isEqualTo: originalTitle)
                            .whereField("date", isEqualTo: originalDate)
                        
                        print("初期値は\(originalTitle)と\(originalDate)")
                        query.getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("データの取得エラー: \(error.localizedDescription)")
                            } else {
                                if let document = querySnapshot?.documents.first {
                                    document.reference.updateData(userData) { (error) in
                                        if let error = error {
                                            print("データの更新エラー: \(error.localizedDescription)")
                                        } else {
                                            print("データが正常に更新されました")
                                            self.dismiss(animated: true, completion: nil)
                                            self.UD.removeObject(forKey: "scheduleSelected")
                                        }
                                    }
                                } else {
                                    print("対象のデータが見つかりませんでした")
                                }
                            }
                        }
                    } else {
                        print("ユーザーがログインしていません")
                    }
                } else { //初期値が設定されておらずタイトルか日付に変更がない場合
                    print("何も保存しません")
                    alert()
                }
            }
        }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
        self.UD.removeObject(forKey: "alreadySet")
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

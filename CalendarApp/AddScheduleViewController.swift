//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/22.
//

import UIKit
import Firebase

class AddScheduleViewController: UIViewController {

    var userUID: String? //一時的
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var schedule: UIDatePicker!
    @IBOutlet weak var closeButton: UIButton!
    
    var formatDate: String = ""

    var UD: UserDefaults = UserDefaults.standard
    let fireStore = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        
        let selectedDate = UD.object(forKey: "date")
        
        if let userUID = self.userUID {
            closeButton.isHidden = false
            
            let fireStore = Firestore.firestore()
                    let scheduleCollection = fireStore.collection("user").document(userUID).collection("schedule")
                    
                    scheduleCollection.whereField("date", isEqualTo: selectedDate).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データ取得エラー: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = querySnapshot?.documents else {
                            print("該当するドキュメントがありません")
                            return
                        }
                        
                        self.schedule.date = selectedDate as! Date
                    }
                
//                // ここにDatePickerの初期値を設定するコードを追加
//                if let date = datePicker.date {
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy年MM月dd日"
//                    let dateString = dateFormatter.string(from: date)
//                    
//                    if let selectedDate = selectedDate, selectedDate == dateString {
//                        // 選択した日付と一致する場合、DatePickerに設定
//                        datePicker.date = date
//                    }
//                }
        } else {
            closeButton.isHidden = true
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
            UIAlertAction(title: "OK", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)}))
        alert.addAction(
            UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close() {
        if let title = titleText.text, !title.isEmpty,
        let scheduleTouched = UD.object(forKey: "scheduleSelected")as?String, !scheduleTouched.isEmpty{
            if let currentUserUID = Auth.auth().currentUser?.uid {
                let userData = [
                    "title": title,
                    "date": formatDate]
                let userDocRef = self.fireStore.collection("user").document(currentUserUID)
                let scheduleCollectionRef = userDocRef.collection("schedule")
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
            } else {
                print("ユーザーがログインしていません")
            }
        } else {
            alert()
        }
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

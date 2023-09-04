//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/22.
//

import UIKit
import Firebase

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var schedule: UIDatePicker!
    
    var formatDate: String = ""

    var UD: UserDefaults = UserDefaults.standard
    let fireStore = Firestore.firestore()
    
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

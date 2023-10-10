//
//  CalendarViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/05.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var UD: UserDefaults = UserDefaults.standard
    var selectedDate: String = ""
    var schedules: [String] = [] // スケジュールを保持する配列
    var birthdays: [String] = [] // 誕生日の人の名前を保持する配列
    var plans: [String] = [] // 予定のタイトルを保持する配列

    
    override func viewDidLoad() {
        
        calendar.delegate = self
        calendar.dataSource = self
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let selectedDateStr = UD.object(forKey: "formatDate") as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"  // こちらのフォーマットは実際のフォーマットに合わせて変更してください。
                    
                    if let selectedDate = dateFormatter.date(from: selectedDateStr) {
                        calendar.select(selectedDate)
                    }
                }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSchedule" {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        } else if segue.identifier == "toProfile" {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        }
    }
    
    func fetchScheduleForSelectedDate(selectedDate: String) { //日付の部分が選択された時
            let fireStore = Firestore.firestore()
            let user = Auth.auth().currentUser // 現在のユーザーを取得
            if let userUID = user?.uid {
                // ランダムなスケジュールドキュメントIDを指定してクエリを作成
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
                    
                    // スケジュールを保持する配列をクリア
                    self.schedules.removeAll()
                    
                    // 取得したスケジュールを直接テーブルビューに表示
                    var scheduleTitles: [String] = []
                    for document in documents {
                        if let title = document.data()["title"] as? String {
                            scheduleTitles.append(title)
                        }
                    }
                    self.schedules = scheduleTitles
                    
                    // テーブルビューをリロードして表示を更新
                    self.tableView.reloadData()
                }
            }
        }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // カレンダーの日付が選択されたときの処理
        
        tableView.isHidden = false // UITableViewを表示する
        
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                selectedDate = dateFormatter.string(from: date)
                
                // Firestoreからスケジュールを取得
                fetchScheduleForSelectedDate(selectedDate: selectedDate)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // カレンダーの日付が選択解除されたときの処理
        tableView.isHidden = true // UITableViewを非表示にする
        
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        // カレンダーの日付にイベントを表示するための処理
        return 0 // イベント数
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return schedules.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            cell.textLabel?.text = schedules[indexPath.row]
            return cell
        }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        // カレンダーの日付に表示されるイベントの色を設定する処理
        return UIColor.red // 赤色のイベント
    }
    
    @IBAction func add() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
               
               // 予定を追加するボタン
               let addPlanAction = UIAlertAction(title: "予定を追加する", style: .default) { (action) in
                   // 予定を追加するボタンが選択されたときの処理
                   self.performSegue(withIdentifier: "toSchedule", sender: self)
                   // ここに予定を追加する処理を書く
               }
               
               // 誕生日の人を登録するボタン
               let addBirthdayAction = UIAlertAction(title: "誕生日の人を登録する", style: .default) { (action) in
                   // 誕生日の人を登録するボタンが選択されたときの処理
                   self.performSegue(withIdentifier: "toProfile", sender: self)
                   // ここに誕生日の人を登録する処理を書く
               }
               
               // キャンセルボタン
               let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
               
               // ボタンをアラートに追加
               alertController.addAction(addPlanAction)
               alertController.addAction(addBirthdayAction)
               alertController.addAction(cancelAction)
               
               // アラートを表示
               present(alertController, animated: true, completion: nil)
        
           }
    
    //一時的にメモ
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        return cell
//    }
    
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

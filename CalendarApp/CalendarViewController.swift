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
        
        
        // 影の設定
        tableView.layer.shadowRadius = 3
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        tableView.layer.masksToBounds = false
        

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
        } else if segue.identifier == "toAlreadySelected" {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            if let addScheduleViewController = segue.destination as? AddScheduleViewController, let userUID = sender as? String {
                        addScheduleViewController.userUID = userUID
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
                        for document in documents {
                            if let title = document.data()["title"] as? String {
                                self.schedules.append(title)
                                print(title,"追加した")
                                self.UD.set(title, forKey: "title") //次の画面遷移用
                            }
                        }
                        // テーブルビューをリロードして表示を更新
                        self.tableView.reloadData()
                    }
                    let friendBirthCollection = fireStore.collection("user").document(userUID).collection("friendProfile")
                                    friendBirthCollection.whereField("date", isEqualTo: selectedDate).getDocuments { (querySnapshot, error) in
                                        if let error = error {
                                            print("データ取得エラー:\(error.localizedDescription)")
                                            return
                                        }
                                        
                                        guard let documents = querySnapshot?.documents else {
                                            print("該当するドキュメントがありません")
                                            return
                                        }
                                        
                                        // 誕生日の人を保持する配列をクリア
                                        self.birthdays.removeAll()
                                                    
                                        // 取得した誕生日の人を直接テーブルビューに表示
                                        for document in documents {
                                            if let name = document.data()["name"] as? String {
                                                self.birthdays.append(name)
                                            }
                                        }
                                                    
                                        // テーブルビューをリロードして表示を更新
                                        self.tableView.reloadData()
                                        print("予定は",[self.schedules])
                                        print("誕生日の人は",[self.birthdays])
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
        UD.set(selectedDate, forKey: "date") //選択した日付を保存
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
        return schedules.count + birthdays.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        // インデックスに基づいてスケジュールまたは誕生日を表示するかを判断
            if indexPath.row < schedules.count {
                // スケジュールを表示
                cell.textLabel?.text = schedules[indexPath.row]
            } else {
                // 誕生日を表示
                let birthdayIndex = indexPath.row - schedules.count
                cell.textLabel?.text = birthdays[birthdayIndex]
            }
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = Auth.auth().currentUser // 現在のユーザーを取得
        let userUID = user?.uid
        if indexPath.row < schedules.count {
                // ユーザーが押したセルがscheduleコレクションのものである場合
                let selectedSchedule = schedules[indexPath.row]
                print("Selected Schedule: \(selectedSchedule)")
                // ここで適切な処理を実行する
                self.performSegue(withIdentifier: "toAlreadySelected", sender: userUID)
                UD.set("alreadySet", forKey: "alreadySet")
            UD.set(selectedSchedule, forKey: "title")
            } else {
                // ユーザーが押したセルがfriendProfileコレクションのものである場合
                let friendIndex = indexPath.row - schedules.count
                let selectedFriendName = birthdays[friendIndex]
                print("Selected Friend: \(selectedFriendName)")
                // ここで適切な処理を実行する
                UD.set(selectedFriendName, forKey: "friendName")
                self.performSegue(withIdentifier: "toProfile", sender: nil)
                UD.set("alreadySet", forKey: "alreadySet")
            }
//        let selectedSchedule = schedules[indexPath.row]
       }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        // カレンダーの日付に表示されるイベントの色を設定する処理
        return UIColor.red // 赤色のイベント
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { //スクロールが始まった時に呼ばれます
        tableView.layer.masksToBounds = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { //スクロールが終わった時に呼ばれます
        tableView.layer.masksToBounds = false
    }
    
    @IBAction func add() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
               
               // 予定を追加するボタン
               let addPlanAction = UIAlertAction(title: "予定を追加する", style: .default) { (action) in
                   self.UD.removeObject(forKey: "alreadySet")
                   self.UD.removeObject(forKey: "date")
                   self.UD.removeObject(forKey: "title")
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
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

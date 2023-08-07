//
//  CalendarViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/05.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        calendar.delegate = self
        calendar.dataSource = self
        tableView.isHidden = true
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // カレンダーの日付が選択されたときの処理
        
        tableView.isHidden = false // UITableViewを表示する
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // カレンダーの日付が選択解除されたときの処理
        tableView.isHidden = true // UITableViewを非表示にする
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        // カレンダーの日付にイベントを表示するための処理
        return 3 // イベント数
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        // カレンダーの日付に表示されるイベントの色を設定する処理
        return UIColor.red // 赤色のイベント
    }
    
    @IBAction func add() {
        
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

//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/22.
//

import UIKit

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var schedule: UIDatePicker!
    
    var formatDate: String = ""

    var UD: UserDefaults = UserDefaults.standard
    
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
        if let title = titleText.text, !title.isEmpty {
            UD.set(title, forKey: "title")
            if let scheduleTouched = UD.object(forKey: "scheduleSelected")as?String, !scheduleTouched.isEmpty {
                UD.set(formatDate, forKey: "formatDate")
                UD.removeObject(forKey: "scheduleSelected")
                print("入力したのは", title, formatDate)
                self.dismiss(animated: true, completion: nil)
            } else {
                alert()
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

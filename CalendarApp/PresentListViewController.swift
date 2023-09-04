//
//  PresentListViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/09/04.
//

import UIKit
import Firebase

class PresentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return names.count
            }
            
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "presentCell", for: indexPath)
                cell.textLabel?.text = names[indexPath.row]
                return cell
            }
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var presentList: [String] = []
    let fireStore = Firestore.firestore()
    // データを取得できた場合、TableViewに表示するためのデータを取り出します
    var names: [String] = []
    
    override func viewDidLoad() {
        
        // 画面がロードされたときにセグメントコントロールを選択
            segmentControl.selectedSegmentIndex = 0
            // actionSegmentedControlメソッドを呼び出す
            actionSegmentedControl(segmentControl)
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGive" {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        } else if segue.identifier == "toGiven" {
            let next = segue.destination
            if let sheet = next.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        }
    }
    
//    @IBAction func actionSegmentedControl(_ sender:UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            print("表示中1")
//
//        case 1:
//            print("表示中2")
//
//
//        default:
//            print("デフォルト状態")
//        }
//    }
    
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
            
        case 0:
            self.names.removeAll()
            tableView.reloadData() // TableViewをリセット
            print("表示中1")
            print("tableViewの中身は",[names])
            
        case 1:
            self.names.removeAll()
            tableView.reloadData() // TableViewをリセット
            print("表示中2")
            
            if let selectedFriendName = UserDefaults.standard.string(forKey: "selectedFriendName"),
               let currentUserUID = Auth.auth().currentUser?.uid {
                
                // Firestoreの参照を取得
                let db = Firestore.firestore()
                
                // friendProfileコレクション内で名前が一致する友達を検索
                db.collection("user").document(currentUserUID).collection("friendProfile").whereField("name", isEqualTo: selectedFriendName).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("データの取得に失敗しました: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("友達が見つかりませんでした")
                        return
                    }
                    
                    if documents.isEmpty {
                        print("友達が見つかりませんでした")
                        return
                    }
                    
                    // 名前が一致する友達が見つかった場合
                    if let friendProfileDocument = documents.first {
                        print("友達みつかった")
                        
                        // 友達のドキュメントIDを取得
                        let friendProfileID = friendProfileDocument.documentID
                        
                        // 友達のドキュメント内のgivenPresentコレクションからpresentNameを取得
                        db.collection("user").document(currentUserUID).collection("friendProfile").document(friendProfileID).collection("givenPresent").getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("データの取得に失敗しました: \(error.localizedDescription)")
                                return
                            }
                            
                            self.names.removeAll()
                            
                            for document in querySnapshot!.documents {
                                if let presentName = document.data()["presentName"] as? String {
                                    print("presentNameは", presentName)
                                    self.names.append(presentName)
                                }
                            }
                            
                            // TableViewを更新
                            self.tableView.reloadData()
                            print("tableviewの中身は", [self.names])
                            
                        }
                    }
                }
            }
            
        default:
            print("デフォルト状態")
        }
    }

    
    @IBAction func add() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
               
               // 予定を追加するボタン
               let toGiveAction = UIAlertAction(title: "渡したプレゼントを追加する", style: .default) { (action) in
                   // 予定を追加するボタンが選択されたときの処理
                   self.performSegue(withIdentifier: "toGive", sender: self)
                   // ここに予定を追加する処理を書く
               }
               
               // 誕生日の人を登録するボタン
               let toGivenAction = UIAlertAction(title: "貰ったプレゼントを追加する", style: .default) { (action) in
                   // 誕生日の人を登録するボタンが選択されたときの処理
                   self.performSegue(withIdentifier: "toGiven", sender: self)
                   // ここに誕生日の人を登録する処理を書く
               }
               
               // キャンセルボタン
               let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
               
               // ボタンをアラートに追加
               alertController.addAction(toGiveAction)
               alertController.addAction(toGivenAction)
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

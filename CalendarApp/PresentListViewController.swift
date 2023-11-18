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
                // セルにタップ ジェスチャ レコグナイザを追加
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
                cell.addGestureRecognizer(tapGesture)

                // セルを識別するためにタグを割り当てる
                cell.tag = indexPath.row

                return cell
            }

    @objc func cellTapped(sender: UITapGestureRecognizer) {
        // タップされたセルのタグを取得して対応するインデックスを得る
        guard let index = sender.view?.tag else { return }

        // 選択されたセグメントを確認
        switch segmentControl.selectedSegmentIndex {
        case 0:
            // Case 0: 1番目のセグメントのデータを処理
            if let selectedFriendName = UserDefaults.standard.string(forKey: "selectedFriendName"),
               let currentUserUID = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()

                db.collection("user").document(currentUserUID).collection("friendProfile").whereField("name", isEqualTo: selectedFriendName).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("データの取得に失敗しました: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents, let friendProfileDocument = documents.first else {
                        print("友達が見つかりませんでした")
                        return
                    }

                    let friendProfileID = friendProfileDocument.documentID

                    db.collection("user").document(currentUserUID).collection("friendProfile").document(friendProfileID).collection("gavePresent").getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データの取得に失敗しました: \(error.localizedDescription)")
                            return
                        }

                        if let presentData = querySnapshot?.documents[index].data() {
                            // Case 0用にUserDefaultsに関連するデータを保存
                            self.UD.set(presentData["date"], forKey: "selectedDate")
                            self.UD.set(presentData["toGive"], forKey: "selectedToGive")
                            self.UD.set(presentData["imageUrl"], forKey: "selectedImageUrl")
                            self.UD.set(presentData["note"], forKey: "selectedNote")
                            self.UD.set(presentData["presentName"], forKey: "selectedPresentName")

                            // 例: 保存されたデータを表示
                            print("Case 0の選択データ:", presentData)
                            self.performSegue(withIdentifier: "toGive", sender: self)
                            self.UD.set("toGiveSelected", forKey: "toGiveSelected")
                        }
                    }
                }
            }

        case 1:
            // Case 1: 2番目のセグメントのデータを処理
            if let selectedFriendName = UserDefaults.standard.string(forKey: "selectedFriendName"),
               let currentUserUID = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()

                db.collection("user").document(currentUserUID).collection("friendProfile").whereField("name", isEqualTo: selectedFriendName).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("データの取得に失敗しました: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents, let friendProfileDocument = documents.first else {
                        print("友達が見つかりませんでした")
                        return
                    }

                    let friendProfileID = friendProfileDocument.documentID

                    db.collection("user").document(currentUserUID).collection("friendProfile").document(friendProfileID).collection("givenPresent").getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データの取得に失敗しました: \(error.localizedDescription)")
                            return
                        }

                        if let presentData = querySnapshot?.documents[index].data() {
                            // Case 1用にUserDefaultsに関連するデータを保存
                            self.UD.set(presentData["date"], forKey: "selectedDate")
                            self.UD.set(presentData["givenBy"], forKey: "selectedGivenBy")
                            self.UD.set(presentData["imageUrl"], forKey: "selectedImageUrl")
                            self.UD.set(presentData["note"], forKey: "selectedNote")
                            self.UD.set(presentData["presentName"], forKey: "selectedPresentName")

                            // 例: 保存されたデータを表示
                            print("Case 1の選択データ:", presentData)
                            self.performSegue(withIdentifier: "toGiven", sender: self)
                            self.UD.set("toGivenSelected", forKey: "toGivenSelected")
                        }
                    }
                }
            }

        default:
            break
        }

        // ここで追加のアクションやナビゲーションを実行
    }
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var presentList: [String] = []
    let fireStore = Firestore.firestore()
    // データを取得できた場合、TableViewに表示するためのデータを取り出します
    var names: [String] = []
    
    var UD: UserDefaults = UserDefaults.standard
    
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
    
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            
            
        case 0:
            self.names.removeAll()
            tableView.reloadData() // TableViewをリセット
            print("表示中1")
            
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
                        db.collection("user").document(currentUserUID).collection("friendProfile").document(friendProfileID).collection("gavePresent").getDocuments { (querySnapshot, error) in
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
    
    
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

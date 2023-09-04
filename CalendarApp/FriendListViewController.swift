//
//  FriendListViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/09/03.
//

import UIKit
import Firebase

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return friends.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = friends[indexPath.row]
            return cell
        }
    
    @IBOutlet weak var tableView: UITableView!
    var friends: [String] = [] // フレンドの名前を格納する配列
    var UD: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 画面が表示されるたびにfriends配列をクリアする(重複して表示されるのを防ぐため)
        friends.removeAll()
        let fireStore = Firestore.firestore()
        if let userUID = Auth.auth().currentUser?.uid {
           let userDocumentRef = fireStore.collection("user").document(userUID)
                // "friendProfile"サブコレクションからデータを取得
                userDocumentRef.collection("friendProfile").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                    // ドキュメントから名前を取得して配列に追加
                    for document in querySnapshot!.documents {
                        if let name = document["name"] as? String {
                            self.friends.append(name)
                        }
                    }
                    // テーブルビューを更新
                       self.tableView.reloadData()
                        print([self.friends])
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルが選択されたときの処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // MainはあなたのメインのStoryboard名に置き換えてください
        if let presentListVC = storyboard.instantiateViewController(withIdentifier: "PresentListVC") as? PresentListViewController {
            // PresentListViewControllerにデータを渡す場合は、ここで渡すことができます
            // セルが選択されたときの処理
                let selectedFriendName = friends[indexPath.row]
                
                // UserDefaultsに選択した友達の名前を保存
                UD.set(selectedFriendName, forKey: "selectedFriendName")
                print(selectedFriendName)
            // PresentListViewControllerに遷移
            self.navigationController?.pushViewController(presentListVC, animated: true)
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

//
//  FriendListViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/09/03.
//

import UIKit
import Firebase
import FirebaseStorage

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return friends.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 画面が表示されるたびにfriends配列をクリアする(重複して表示されるのを防ぐため)
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! FriendListCell
            cell.friendName.text = friends[indexPath.row]
            cell.friendImage.image = friendsImage[indexPath.row]
        return cell
        }
    
    @IBOutlet weak var tableView: UITableView!
    var friends: [String] = [] // フレンドの名前を格納する配列
    var UD: UserDefaults = UserDefaults.standard
    
    var friendsImage: [UIImage] = [] //フレンドのイメージを格納する配列
    
    // Firebase Firestoreの参照を取得
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "FriendListCell", bundle: nil), forCellReuseIdentifier: "customCell")
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        friends.removeAll()
        friendsImage.removeAll()
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
                            if let imageURL = document.data()["imageUrl"] as? String {
                            print("ImageURL: \(imageURL)")
                            // 画像のURLを取得
                            // Firebase Storageから画像をダウンロード
                                let storageRef = self.storage.reference(forURL: imageURL)
                                storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] (data, error) in
                                    if let error = error {
                                        print("Error downloading image: \(error.localizedDescription)")
                                        } else {
                                            // ダウンロード成功時に画像を表示
                                            if let data = data, let image = UIImage(data: data) {
                                                self?.friendsImage.append(image)
                                                // テーブルビューを更新
                                                self?.tableView.reloadData()
                                            }
                                        }
                                }
                            }
                    }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 85
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

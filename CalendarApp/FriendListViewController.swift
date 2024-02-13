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
//            cell.friendName.text = friends[indexPath.row]
//            cell.friendImage.image = friendsImage[indexPath.row]
        let id = idarray[indexPath.row] //暫定対応策
        cell.friendName.text = dictionaryFriendName[id]
        cell.friendImage.image = dictionaryFriendImage[id]
        return cell
        
        }
    
    @IBOutlet weak var tableView: UITableView!
    var friends: [String] = [] // フレンドの名前を格納する配列
    var UD: UserDefaults = UserDefaults.standard
    
    var friendsImage: [UIImage] = [] //フレンドのイメージを格納する配列
    
    var dictionaryFriendName: Dictionary<String, String> = [:]
    var dictionaryFriendImage: Dictionary<String, UIImage> = [:]
    var idarray:[String] = []

    
    // Firebase Firestoreの参照を取得
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "FriendListCell", bundle: nil), forCellReuseIdentifier: "customCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 247/255, alpha: 1.0)
        

        // Do any additional setup after loading the view.
    }
    
    
    //dictionary型を使う！！！
    
    override func viewWillAppear(_ animated: Bool) {
        friends.removeAll()
        friendsImage.removeAll()

        let dispatchGroup = DispatchGroup() // DispatchGroupを作成

        if let userUID = Auth.auth().currentUser?.uid {
            let userDocumentRef = fireStore.collection("user").document(userUID)
            
            // "friendProfile"サブコレクションからデータを取得
            dispatchGroup.enter() // 非同期タスクを開始する前にDispatchGroupにエンター
            userDocumentRef.collection("friendProfile").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("ドキュメントの取得エラー: \(error)")
//                    dispatchGroup.leave() // エラーが発生した場合もDispatchGroupを出る
                } else {
                    // ドキュメントから名前と画像URLを取得して配列に追加
                    for document in querySnapshot!.documents {
                        if let name = document["name"] as? String {
                            self.friends.append(name)
                            self.dictionaryFriendName[document.documentID] = name
                            self.idarray.append(document.documentID)

                            // 画像のURLを取得
                            if let imageURL = document.data()["imageUrl"] as? String {
                                print(name, imageURL) //ここはname=imageURL◎
                                let storageRef = self.storage.reference(forURL: imageURL)
                                dispatchGroup.enter() // 非同期の画像ダウンロードタスクを開始する前にDispatchGroupにエンター
                                storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] (data, error) in
                                    if let error = error {
                                        print("画像のダウンロードエラー: \(error.localizedDescription)")
                                    } else {
                                        // ダウンロード成功時に画像を配列に追加
                                        if let data = data, let image = UIImage(data: data) {
                                            defer {
                                                dispatchGroup.leave()
                                                // 非同期の画像ダウンロードタスクが完了したらDispatchGroupを出る
                                            }
                                            self?.friendsImage.append(image)
                                            self?.dictionaryFriendImage[document.documentID] = image

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                dispatchGroup.leave() // ドキュメント取得が完了したらDispatchGroupを出る
            }
        }

        // DispatchGroup内のすべてのタスクが完了したら通知
        dispatchGroup.notify(queue: .main) {
            // このコードはすべての非同期タスクが完了した後に実行されます
            self.tableView.reloadData()
        } //このdispatchGroupは画像とタイトルの数が合わない！！って時に使う用
        
        guard let tabBarController = tabBarController else { return }
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor(red: 174/255, green: 197/255, blue: 235/255, alpha: 1.0)
        tabBarController.tabBar.standardAppearance = tabBarAppearance

        if #available(iOS 15.0, *) { // 新たに追加
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        guard let navigationController = navigationController else { return }
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = UIColor(red: 174/255, green: 197/255, blue: 235/255, alpha: 1.0)
        navigationController.navigationBar.standardAppearance = navigationAppearance
        
        if #available(iOS 15.0, *) {
            navigationController.navigationBar.scrollEdgeAppearance = navigationAppearance
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
        // セルの高さ
            let cellHeight: CGFloat = 85
            
//            // セルごとの間隔
//            let cellSpacing: CGFloat = 10
            
//            // 最後のセルの場合、間隔を追加しない
//            if indexPath.row == friends.count - 1 {
//                return cellHeight
//            }
            
            // それ以外の場合、セルの高さに間隔を追加して返す
            return cellHeight
        
    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            return 100 // セルの上部のスペース
//        }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//            return 100 // セルの下部のスペース
//        }
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = UIColor.clear // 透明にすることでスペースとする
//        }
//    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        view.tintColor = UIColor.clear // 透明にすることでスペースとする
//        }
//    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

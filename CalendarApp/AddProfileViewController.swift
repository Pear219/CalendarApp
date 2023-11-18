//
//  AddProfileViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/09.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseStorage

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var birthdayName: UITextField!
    @IBOutlet weak var birthday: UIDatePicker!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var UD: UserDefaults = UserDefaults.standard
    
    var formattedDate: String = ""
    
    // Firebase Firestoreの参照を取得
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITextFieldのデリゲートを設定
        birthdayName.delegate = self
        // UITextViewのデリゲートを設定
        note.delegate = self
        // UIDatePickerのイベントを設定
        birthday.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        saveButton.isHidden = true
        closeButton.isHidden = false
        
        isModalInPresentation = true
        
        if UD.object(forKey: "alreadySet") != nil {
            if let selectedFriendName = UserDefaults.standard.string(forKey: "friendName") {
                // `selectedFriendName`に対応するデータをFirestoreから取得するなどの処理を行う
                let fireStore = Firestore.firestore()
                let user = Auth.auth().currentUser // 現在のユーザーを取得

                if let userUID = user?.uid {
                    let friendProfileCollection = fireStore.collection("user").document(userUID).collection("friendProfile")

                    // `selectedFriendName`に対応するデータを取得
                    friendProfileCollection.whereField("name", isEqualTo: selectedFriendName).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データ取得エラー:\(error.localizedDescription)")
                            return
                        }

                        guard let documents = querySnapshot?.documents else {
                            print("該当するドキュメントがありません")
                            return
                        }

                        // ドキュメントが存在すれば、`date`、`note`、`imageURL`などを取得する
                        if let document = documents.first {
                            if let date = document.data()["date"] as? String {
                                print("Date: \(date)")
                                self.birthdayName.text = selectedFriendName
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy年MM月dd日"
                                if let afterDate = dateFormatter.date(from: date) {
                                    self.birthday.setDate(afterDate, animated: true)
                                }
                            }

                            if let note = document.data()["note"] as? String {
                                print("Note: \(note)")
                                self.note.text = note
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
                                                    self?.selectedPhoto.image = image
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
            }

        } else {
            birthdayName.text = ""
            note.text = ""
            selectedPhoto.image = nil
        }
    }
    
    // UITextFieldのテキストが変更されたときに呼ばれるメソッド
        func textFieldDidChangeSelection(_ textField: UITextField) {
            saveButton.isHidden = false
            closeButton.isHidden = true
        }

        // UITextViewのテキストが変更されたときに呼ばれるメソッド
        func textViewDidChange(_ textView: UITextView) {
            saveButton.isHidden = false
            closeButton.isHidden = true
        }

        // UIDatePickerの値が変更されたときに呼ばれるメソッド
        @objc func datePickerValueChanged(_ sender: UIDatePicker) {
            saveButton.isHidden = false
            closeButton.isHidden = true
        }
    
    @IBAction func imageChanged() {
        saveButton.isHidden = false
        closeButton.isHidden = true
    }
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
            let selectedDate = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            formattedDate = dateFormatter.string(from: selectedDate)
            UD.set("誕生日は入力された", forKey: "dateSelected")
        }
    
    @IBAction func selectPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    // UIImagePickerControllerDelegateメソッド: 写真が選択されたときに呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedPhoto.contentMode = .scaleAspectFit
            selectedPhoto.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func alert() {
        let alert: UIAlertController = UIAlertController(title: "未入力の箇所があります", message: "入力中のデータは保存されません", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)}))
        alert.addAction(
            UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func alreadyName() {
        let alert: UIAlertController = UIAlertController(title: "同じ名前の友達がすでに存在しています", message: "別の名前を入力してください", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (String) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                return
            }
            
            let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")

            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("画像のアップロードに失敗しました: \(error.localizedDescription)")
                } else {
                    // アップロード成功時にダウンロードURLを取得してFirestoreに保存
                    storageRef.downloadURL { (url, error) in
                        if let imageUrl = url?.absoluteString {
                            completion(imageUrl)
                        }
                    }
                }
            }
        }
    
    @IBAction func save() {
        if UD.object(forKey: "alreadySet") != nil {
            // 現在のユーザーを取得
                let user = Auth.auth().currentUser
                if let userUID = user?.uid, let selectedFriendName = UserDefaults.standard.string(forKey: "friendName") {
                    let fireStore = Firestore.firestore()
                    let friendProfileCollection = fireStore.collection("user").document(userUID).collection("friendProfile")

                    // 選択した名前の友達をクエリ
                    friendProfileCollection.whereField("name", isEqualTo: selectedFriendName).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データ取得エラー:\(error.localizedDescription)")
                            return
                        }

                        guard let documents = querySnapshot?.documents, let document = documents.first else {
                            print("該当するドキュメントがありません")
                            return
                        }

                        // 新しい値でFirestoreドキュメントを更新
                        let newName = self.birthdayName.text ?? ""
                        let newDate = self.birthday.date // 'birthday'がUIDatePickerであると仮定
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy年MM月dd日"
                        let dateString = dateFormatter.string(from: newDate)
                        
                        let newNote = self.note.text ?? "" // 'note'がUITextViewであると仮定

                        // 新しい画像をFirebase Storageにアップロード
                        if let imageData = self.selectedPhoto.image?.jpegData(compressionQuality: 0.5) {
                            let imageFileName = "\(UUID().uuidString).jpg"
                            let storageRef = Storage.storage().reference().child("images/\(imageFileName)")

                            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                                if let error = error {
                                    print("画像のアップロードエラー: \(error.localizedDescription)")
                                    return
                                }

                                // アップロードが成功したら、ダウンロードURLを取得してFirestoreに保存
                                storageRef.downloadURL { (url, error) in
                                    if let error = error {
                                        print("ダウンロードURLの取得エラー: \(error.localizedDescription)")
                                        return
                                    }

                                    if let downloadURL = url?.absoluteString {
                                        // Firestoreのドキュメントを更新
                                        document.reference.updateData([
                                            "name": newName,
                                            "date": dateString,
                                            "note": newNote,
                                            "imageUrl": downloadURL
                                        ]) { error in
                                            if let error = error {
                                                print("ドキュメントの更新エラー: \(error.localizedDescription)")
                                            } else {
                                                print("ドキュメントが正常に更新されました")
                                                self.dismiss(animated: true, completion: nil)
                                                self.UD.removeObject(forKey: "alreadySet")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        } else {
            if let name = birthdayName.text, !name.isEmpty,
               let noteText = note.text, !noteText.isEmpty,
               let selectedDate = UD.object(forKey: "dateSelected") as? String, !selectedDate.isEmpty,
               let selectImage = selectedPhoto.image { // formattedDateが空でないことを確認
                
                // Firestoreでユーザーの友達プロファイルを取得
                if let currentUserUID = Auth.auth().currentUser?.uid {
                    let userDocRef = fireStore.collection("user").document(currentUserUID)
                    let friendProfileCollectionRef = userDocRef.collection("friendProfile")
                    
                    // 同じ名前の友達が存在しないか確認
                    friendProfileCollectionRef.whereField("name", isEqualTo: name).getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("データを取得できませんでした: \(error.localizedDescription)")
                            return
                        }
                        
                        if let documents = querySnapshot?.documents, !documents.isEmpty {
                            // 同じ名前の友達が存在する場合、アラートを表示
                            self.alreadyName()
                        } else {
                            // 同じ名前の友達が存在しない場合、データを保存
                            self.uploadImageToFirebaseStorage(image: selectImage) { imageUrl in
                                let userData = [
                                    "name": name,
                                    "note": noteText,
                                    "date": self.formattedDate,
                                    "imageUrl": imageUrl
                                ]
                                
                                friendProfileCollectionRef.addDocument(data: userData) { error in
                                    if let error = error {
                                        print("データを保存できませんでした: \(error.localizedDescription)")
                                    } else {
                                        print("データが正常に保存されました")
                                        
                                        // 画面を閉じるなどの追加の処理を行うことができます
                                        self.dismiss(animated: true, completion: nil)
                                        UserDefaults.standard.removeObject(forKey: "dateSelected")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("ユーザーがログインしていません")
                }
            } else {
                alert()
            }
        }
    }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
        self.UD.removeObject(forKey: "alreadySet")
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

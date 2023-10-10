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

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var birthdayName: UITextField!
    @IBOutlet weak var birthday: UIDatePicker!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    var UD: UserDefaults = UserDefaults.standard
    
    var formattedDate: String = ""
    
    // Firebase Firestoreの参照を取得
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
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
    
    @IBAction func close() {
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

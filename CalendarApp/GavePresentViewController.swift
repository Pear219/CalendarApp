//
//  GavePresentViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/09/05.
//

import UIKit
import Firebase
import FirebaseStorage

class GavePresentViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var toGive: UITextField!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var presentName: UITextField!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!

    let UD: UserDefaults = UserDefaults.standard
    
    var formattedDate: String = ""
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
            let selectedDate = sender.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            formattedDate = dateFormatter.string(from: selectedDate)
            UD.set("日付は入力された", forKey: "gaveDateSelected")
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.contentMode = .scaleAspectFit
            photo.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
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
    
    func alert() {
        let alert: UIAlertController = UIAlertController(title: "未入力の箇所があります", message: "入力中のデータは保存されません", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)}))
        alert.addAction(
            UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func noUser() {
        let alert: UIAlertController = UIAlertController(title: "該当する名前が存在しません", message: "入力済みの友達の名前を入力してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close() {
        if let name = toGive.text, !name.isEmpty,
            let presentName = presentName.text, !presentName.isEmpty,
            let noteText = note.text, !noteText.isEmpty,
            let selectedDate = UD.object(forKey: "gaveDateSelected") as? String, !selectedDate.isEmpty,
            let selectImage = photo.image { // formattedDateが空でないことを確認

            uploadImageToFirebaseStorage(image: selectImage) { imageUrl in
                if let currentUserUID = Auth.auth().currentUser?.uid {
                    // Firestoreにデータを保存する前にfriendProfile内のnameとの比較を行う
                    let userDocRef = self.fireStore.collection("user").document(currentUserUID)
                    let friendProfileCollectionRef = userDocRef.collection("friendProfile")

                    friendProfileCollectionRef.whereField("name", isEqualTo: name).getDocuments { (snapshot, error) in
                        if let error = error {
                            print("データの取得に失敗しました: \(error.localizedDescription)")
                        } else if let documents = snapshot?.documents, !documents.isEmpty {
                            // 同じ名前の友達が存在する場合
                            if let friendUID = documents[0].documentID as? String {
                                // friendUIDを使用してgivenPresentコレクションを作成
                                let givenPresentCollectionRef = friendProfileCollectionRef.document(friendUID).collection("gavePresent")

                                // 以降のデータ保存ロジックはそのまま
                                let userData = [
                                    "toGive": name,
                                    "presentName": presentName,
                                    "note": noteText,
                                    "date": self.formattedDate,
                                    "imageUrl": imageUrl
                                ]

                                givenPresentCollectionRef.addDocument(data: userData) { error in
                                    if let error = error {
                                        print("データを保存できませんでした: \(error.localizedDescription)")
                                    } else {
                                        print("データが正常に保存されました")

                                        // 画面を閉じるなどの追加の処理を行うことができます
                                        self.dismiss(animated: true, completion: nil)
                                        UserDefaults.standard.removeObject(forKey: "gaveDateSelected")
                                    }
                                }
                            }
                        } else {
                            // 同じ名前の友達が存在しない場合、アラートを表示
                          print("該当する表示なし")
                            self.noUser()
                        }
                    }
                } else {
                    print("ユーザーがログインしていません")
                }
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

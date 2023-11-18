//
//  GivenPresentListViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/09/04.
//

import UIKit
import Firebase
import FirebaseStorage

class GivenPresentViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var givenBy: UITextField!
    @IBOutlet weak var presentName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var formattedDate: String = ""
    let fireStore = Firestore.firestore()
    let storage = Storage.storage()
    
    var UD: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        givenBy.delegate = self
        presentName.delegate = self
        // UIDatePickerのイベントを設定
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        note.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        saveButton.isHidden = true
        closeButton.isHidden = false
        isModalInPresentation = true
        if UD.object(forKey: "toGivenSelected") != nil {
            if let givenBy = UD.object(forKey: "selectedGivenBy") as? String {
                self.givenBy.text = givenBy
            }
            if let note = UD.object(forKey: "selectedNote") as? String{
                self.note.text = note
            }
            if let imageURL = UD.object(forKey: "selectedImageUrl") as? String {
//                 Firebase Storageから画像をダウンロード
                    let storageRef = self.storage.reference(forURL: imageURL)
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] (data, error) in
                        if let error = error {
                            print("Error downloading image: \(error.localizedDescription)")
                        } else {
                            // ダウンロード成功時に画像を表示
                            if let data = data, let image = UIImage(data: data) {
                                self?.photo.image = image
                            }
                        }
                    }
            }
            if let presentName = UD.object(forKey: "selectedPresentName") as? String {
                self.presentName.text = presentName
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            if let datePicker = UD.object(forKey: "selectedDate") as? String {
                if let date = dateFormatter.date(from: datePicker) {
                    self.datePicker.setDate(date, animated: true)
                }
            }
        } else {
            givenBy.text = ""
            note.text = ""
            photo.image = nil
            presentName.text = ""
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
            UD.set("日付は入力された", forKey: "givenDateSelected")
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
    
    
    @IBAction func save() {
        if UD.object(forKey: "toGivenSelected") != nil {
            if let name = givenBy.text, !name.isEmpty,
                let presentName = presentName.text, !presentName.isEmpty,
                let noteText = note.text, !noteText.isEmpty {

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日"
                let formattedDate = dateFormatter.string(from: datePicker.date)

                // 画像のアップロード
                if let selectImage = photo.image {
                    uploadImageToFirebaseStorage(image: selectImage) { imageUrl in
                        if let currentUserUID = Auth.auth().currentUser?.uid {
                            let userDocRef = self.fireStore.collection("user").document(currentUserUID)
                            let friendProfileCollectionRef = userDocRef.collection("friendProfile")

                            friendProfileCollectionRef.whereField("name", isEqualTo: name).getDocuments { (snapshot, error) in
                                if let error = error {
                                    print("データの取得に失敗しました: \(error.localizedDescription)")
                                } else if let documents = snapshot?.documents, !documents.isEmpty {
                                    // 同じ名前の友達が存在する場合
                                    if let friendUID = documents[0].documentID as? String {
                                        let givenPresentCollectionRef = friendProfileCollectionRef.document(friendUID).collection("givenPresent")

                                        // 既存のドキュメントを新しい値で更新
                                        givenPresentCollectionRef.whereField("givenBy", isEqualTo: name).getDocuments { (snapshot, error) in
                                            if let error = error {
                                                print("データの取得に失敗しました: \(error.localizedDescription)")
                                            } else if let documents = snapshot?.documents, !documents.isEmpty {
                                                let documentID = documents[0].documentID
                                                let updatedData = [
                                                    "givenBy": name,
                                                    "presentName": presentName,
                                                    "note": noteText,
                                                    "date": formattedDate,
                                                    "imageUrl": imageUrl
                                                    // 必要なら他のフィールドも追加
                                                ]

                                                givenPresentCollectionRef.document(documentID).setData(updatedData, merge: true) { error in
                                                    if let error = error {
                                                        print("データを更新できませんでした: \(error.localizedDescription)")
                                                    } else {
                                                        print("データが正常に更新されました")

                                                        // 画面を閉じるなどの追加の処理を行うことができます
                                                        self.dismiss(animated: true, completion: nil)
                                                        self.UD.removeObject(forKey: "toGivenSelected")
                                                    }
                                                }
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
        } else {
            if let name = givenBy.text, !name.isEmpty,
                let presentName = presentName.text, !presentName.isEmpty,
                let noteText = note.text, !noteText.isEmpty,
                let selectedDate = UD.object(forKey: "givenDateSelected") as? String, !selectedDate.isEmpty,
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
                                if let friendUID = documents[0].documentID as? String{
                                    // friendUIDを使用してgivenPresentコレクションを作成
                                    let givenPresentCollectionRef = friendProfileCollectionRef.document(friendUID).collection("givenPresent")

                                    // 以降のデータ保存ロジックはそのまま
                                    let userData = [
                                        "givenBy": name,
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
                                            UserDefaults.standard.removeObject(forKey: "givenDateSelected")
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
    }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
        self.UD.removeObject(forKey: "toGivenSelected")
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

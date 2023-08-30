//
//  AddProfileViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/09.
//

import UIKit
import SwiftUI
import Firebase

class AddProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var birthdayName: UITextField!
    @IBOutlet weak var birthday: UIDatePicker!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    var UD: UserDefaults = UserDefaults.standard
    
    var formattedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func close() {
        if let name = birthdayName.text, !name.isEmpty {
            print("名前は", name)
            UD.set(name, forKey: "birthdayName")
            if let noteText = note.text, !noteText.isEmpty {
                UD.set(noteText, forKey: "note")
                if let selectedDate = UD.object(forKey: "dateSelected") as? String, !selectedDate.isEmpty {//ちゃんと選択し終わったか確認
                    UD.set(formattedDate, forKey: "formattedDate")
                    UD.removeObject(forKey: "dateSelected")
                    if let selectedImage = selectedPhoto.image {
                        // 画像をDataに変換してUserDefaultsに保存する
                        if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                            UD.set(imageData, forKey: "selectedPhoto")
                        }
                            print(noteText, name, formattedDate)
                            self.dismiss(animated: true, completion: nil)
                    } else {
                        alert()
                    }
                } else {
                    alert()
                }
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

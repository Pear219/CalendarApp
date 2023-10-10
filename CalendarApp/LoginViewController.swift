//
//  LoginViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/08/29.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Firebase


class LoginViewController: UIViewController {
    
    @IBOutlet var login: UIButton!
    
    override func viewDidLoad() {
        //既にログイン時
                if let user = Auth.auth().currentUser {
                    print("user: \(user.uid)")

        //画面遷移をかく
                    let storyboard: UIStoryboard = self.storyboard!
                    let next = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                    next.modalPresentationStyle = .fullScreen
                    self.present(next, animated: true, completion: nil)
                }
        
        super.viewDidLoad()
        
        login.layer.cornerRadius = 10
        login.layer.shadowRadius = 3
        login.layer.shadowOpacity = 0.1
        login.layer.shadowColor = UIColor.black.cgColor
        login.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        // Firebase初期化
        //  FirebaseApp.configure()
        
        
        
    }
    @IBAction func login(_ sender: Any) {
        auth()
    }
    
    private func auth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
            
            guard let authentication = signInResult?.user,
                  let idToken = authentication.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken.tokenString)
            
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if  let user = signInResult?.user {
                    let name = user.profile!.name
                    let email = user.profile!.email
                    
                    Firestore.firestore().collection("user").document((authResult?.user.uid)!).setData([
                        "name": name,
                        "email": email
                    ],completion: { error in
                        if let error = error {
                            // ②が失敗した場合
                            print("Firestore 新規登録失敗 " + error.localizedDescription)
                        } else {
                            
                            print("ログイン完了 name:" + name)
                            
                            //ここに画面遷移
                            let storyboard: UIStoryboard = self.storyboard!
                            let next = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
                            next.modalPresentationStyle = .fullScreen
                            self.present(next, animated: true, completion: nil)
                        }
                    }
                    ) }
            }
        }
    }
    
    
    
    
}

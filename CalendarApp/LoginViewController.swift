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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                            
                            //ここに画面
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

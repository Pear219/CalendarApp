//
//  TabBarViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2024/02/06.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tabBar.barTintColor = .systemGray
//        tabBar.tintColor = .white
//        tabBar.unselectedItemTintColor = .systemIndigo
//
//        tabBar.layer.cornerRadius = 25.0
//        tabBar.layer.masksToBounds = true
//            tabBar.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
//        guard let tabBarController = tabBarController else { return }
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.backgroundColor = UIColor(red: 174/255, green: 197/255, blue: 235/255, alpha: 1.0)
//
//        tabBarController.tabBar.standardAppearance = tabBarAppearance
//
//        if #available(iOS 15.0, *) { // 新たに追加
//            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
//        }
//
//        guard let navigationController = navigationController else { return }
//        let navigationAppearance = UINavigationBarAppearance()
//        navigationAppearance.backgroundColor = UIColor(red: 174/255, green: 197/255, blue: 235/255, alpha: 1.0)
//        navigationController.navigationBar.standardAppearance = navigationAppearance
//
//        if #available(iOS 15.0, *) {
//            navigationController.navigationBar.scrollEdgeAppearance = navigationAppearance
//        }
        

        // TabBarの角を丸める
                self.tabBar.layer.cornerRadius = 20 // 任意の角丸の半径を設定
                
                // 必要に応じて、背景色や影などの他の外観プロパティを設定
                self.tabBar.barTintColor = UIColor.white // 背景色を設定
                self.tabBar.layer.shadowColor = UIColor.black.cgColor // 影の色を設定
                self.tabBar.layer.shadowOpacity = 0.3 // 影の不透明度を設定
                self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3) // 影のオフセットを設定
                self.tabBar.layer.cornerRadius = 25.0
        self.tabBar.layer.masksToBounds = true
                self.tabBar.layer.shadowRadius = 3 // 影のぼかしの半径を設定
                
                self.delegate = self
        
        // Do any additional setup after loading the view.
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

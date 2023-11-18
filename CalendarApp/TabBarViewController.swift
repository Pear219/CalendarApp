//
//  TabBarViewController.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/11/17.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(red: 233/255, green: 245/255, blue: 251/255, alpha: 1.0)
        UITabBar.appearance().backgroundColor = UIColor(red: 168/255, green: 198/255, blue: 239/255, alpha: 1.0)

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

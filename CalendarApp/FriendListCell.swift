//
//  FriendListCell.swift
//  CalendarApp
//
//  Created by 加藤 on 2023/11/21.
//

import UIKit

class FriendListCell: UITableViewCell {
    
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            
//            // セルのコンテンツビューの角を丸める
//            contentView.layer.cornerRadius = 30.0
//            contentView.layer.masksToBounds = true
//        
//        contentView.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 247/255, alpha: 1.0)
        
        }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

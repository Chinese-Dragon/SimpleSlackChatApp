//
//  ChatMessageTableViewCell.swift
//  Chat
//
//  Created by Yingzheng Ma on 3/3/19.
//  Copyright © 2019 Yingzheng Ma. All rights reserved.
//

import UIKit

class ChatTextMessageTableViewCell: UITableViewCell {
  static let identifier = "TextMessageCell"
  
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var timestamp: UILabel!
  @IBOutlet weak var message: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    avatar.layer.cornerRadius = 5.0
    avatar.clipsToBounds = true
    avatar.layer.masksToBounds = true
  }
}

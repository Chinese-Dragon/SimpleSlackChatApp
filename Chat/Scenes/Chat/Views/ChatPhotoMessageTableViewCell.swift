//
//  ChatPhotoMessageTableViewCell.swift
//  Chat
//
//  Created by Yingzheng Ma on 3/3/19.
//  Copyright © 2019 Yingzheng Ma. All rights reserved.
//

import UIKit

class ChatPhotoMessageTableViewCell: UITableViewCell {
  static let identifier = "PhotoMessageCell"
  
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var timestamp: UILabel!
  @IBOutlet weak var photoMessage: UIImageView!
}

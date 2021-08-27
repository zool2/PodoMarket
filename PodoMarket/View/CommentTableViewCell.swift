//
//  CommentTableViewCell.swift
//  PodoMarket
//
//  Created by TJ on 05/09/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var labelNickname: UILabel!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var labelUploadedTime: UILabel!
    @IBOutlet weak var buttonReplyComment: UIButton!

    var labelLoginID: String = ""
}

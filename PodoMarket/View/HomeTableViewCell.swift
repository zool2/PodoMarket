//
//  HomeTableViewCell.swift
//  PodoMarket
//
//  Created by TJ on 30/08/2019.
//  Copyright © 2019 zool2. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var imageProduct: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelUploadTime: UILabel!
    @IBOutlet var labelPrice: UILabel!
    @IBOutlet var buttonHeart: UIButton!
    var wishDocumentID: String? = ""

}

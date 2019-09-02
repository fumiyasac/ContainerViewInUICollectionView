//
//  EssayCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/09/02.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import WebKit

class EssayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        webView.isUserInteractionEnabled = false
    }

}

//
//  ContainerCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setCell(_ vc: UIViewController) {
        self.contentView.addSubview(vc.view)
        vc.view.frame = contentView.frame
    }
}

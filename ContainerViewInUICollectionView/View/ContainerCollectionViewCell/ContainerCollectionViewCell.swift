//
//  ContainerCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell {

    private var targetViewControllerView: UIView!

    // MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        targetViewControllerView.removeFromSuperview()
    }

    // MARK: - Function

    func setCell(_ viewController: UIViewController) {
        targetViewControllerView = viewController.view
        targetViewControllerView.frame = contentView.frame
        self.contentView.addSubview(targetViewControllerView)
    }
}

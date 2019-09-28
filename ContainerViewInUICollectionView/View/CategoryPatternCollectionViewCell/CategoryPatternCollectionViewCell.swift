//
//  CategoryPatternCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/17.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class CategoryPatternCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak private var cellButton: UIButton!

    var cellButtonTappedHandler: (() -> ())?

    // MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCategoryPatternCollectionViewCell()
    }

    // MARK: - Private Function

    @objc private func cellButtonTapped(sender: UIButton) {
        // ViewController側でクロージャー内にセットした処理を実行する
        cellButtonTappedHandler?()
    }

    private func setupCategoryPatternCollectionViewCell() {
        // ボタン押下時のアクションの設定
        cellButton.addTarget(self, action:  #selector(self.cellButtonTapped(sender:)), for: .touchUpInside)
    }
}

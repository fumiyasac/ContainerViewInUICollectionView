//
//  SubContentsTableViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/21.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class SubContentsTableViewCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!

    // MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()

        setupSubContentsTableViewCell()
    }

    // MARK: - Function

    func setCell(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }

    // MARK: - Private Function

    private func setupSubContentsTableViewCell() {

        // 特に画面遷移がないのでアクセサリとセレクションを非表示にする
        self.accessoryType = .none
        self.selectionStyle = .none
    }
}

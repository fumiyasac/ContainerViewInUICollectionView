//
//  DetailEffectiveHeaderView.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/09.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

class DetailEffectiveHeaderView: CustomViewBase {

    var headerBackButtonTappedHandler: (() -> ())?

    @IBOutlet weak private var headerBackButton: UIButton!
    @IBOutlet weak private var headerWrappedView: UIView!
    @IBOutlet weak private var headerTitleLabel: UILabel!

    // MARK: - Initializer

    required init(frame: CGRect) {
        super.init(frame: frame)

        setupDetailEffectiveHeaderView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupDetailEffectiveHeaderView()
    }

    // MARK: - Function

    func setTitle(_ title: String) {
        headerTitleLabel.text = title
    }

    func changeAlpha(_ targetAlpha: CGFloat) {
        if targetAlpha > 1 {
            headerWrappedView.alpha = 1
        } else if 0...1 ~= targetAlpha {
            headerWrappedView.alpha = targetAlpha
        } else {
            headerWrappedView.alpha = 0
        }
    }

    // MARK: - Private Function

    @objc private func headerBackButtonTapped(sender: UIButton) {
        // ViewController側でクロージャー内にセットした処理を実行する
        headerBackButtonTappedHandler?()
    }

    private func setupDetailEffectiveHeaderView() {
        // ボタン押下時のアクションの設定
        headerBackButton.addTarget(self, action:  #selector(self.headerBackButtonTapped(sender:)), for: .touchUpInside)
    }
}

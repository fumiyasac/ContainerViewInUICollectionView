//
//  ViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class ViewController: UIViewController {

    private var displayViewControllers: [UIViewController] = []

    @IBOutlet weak private var collectionView: UICollectionView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDisplayViewControllers()
        setupGalleryCollectionView()
    }
    
    // MARK: - Private Function

    private func setupDisplayViewControllers() {

        // UICollectionViewCell内に表示するUIViewControllerの設定
        let viewControllers = [
            Partial1ViewController.instantiate(),
            Partial2ViewController.instantiate(),
            Partial3ViewController.instantiate(),
            Partial4ViewController.instantiate()
        ]
        let _ = viewControllers.map{ displayViewControllers.append($0) }
    }

    private func setupGalleryCollectionView() {

        // UICollectionViewに関する初期設定
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        // UICollectionViewDelegate & UICollectionViewDataSourceに関する初期設定
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCustomCell(ContainerCollectionViewCell.self)

        // UICollectionViewに付与するアニメーションに関する設定
        let layout = AnimatedCollectionViewLayout()
        layout.animator = PageAttributesAnimator()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate {

    // MEMO: 利用しないかもしれませんが一応準備をしておく
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayViewControllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: ContainerCollectionViewCell.self, indexPath: indexPath)

        let vc = displayViewControllers[indexPath.row]
        cell.setCell(displayViewControllers[indexPath.row])

        // MEMO: セルへ適用した後に再び詰め直しを図る
        displayViewControllers[indexPath.row] = vc
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    // セルのサイズを設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    // セルの垂直方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セルの水平方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セル内のアイテム間の余白(margin)調整を行う
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

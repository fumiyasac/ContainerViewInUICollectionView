//
//  DetailSubContentsListViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailSubContentsListViewController: UIViewController {

    private var scrollBeginingPoint: CGPoint!

    @IBOutlet weak private(set) var tableView: UITableView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationCenter()
        setupTableView()
    }

    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Function (for NotificationCenter)

    // MEMO: Notification名「ActivateMainContentsScrollNotification」にて実行される処理
    @objc private func disableTableViewScroll() {
        tableView.isScrollEnabled = false
    }

    // MEMO: Notification名「ActivateSubContentsScrollNotification」にて実行される処理
    @objc private func enableTableViewScroll() {
        tableView.isScrollEnabled = true
    }

    // MEMO: Notification名「UpdateTableViewOffsetNotification」にて実行される処理
    @objc private func resetTableViewPosition() {
        tableView.contentOffset.y = 0
    }

    // MARK: - Private Function

    // 監視対象NotificationCenterの設定
    private func setupNotificationCenter() {

        // Notification名「ActivateMainContentsScrollNotification / ActivateSubContentsScrollNotification」を監視対象に登録する
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableTableViewScroll), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateMainContentsScrollNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableTableViewScroll), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateSubContentsScrollNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetTableViewPosition), name: Notification.Name(rawValue: SynchronizeScreenNotification.UpdateTableViewOffsetNotification.rawValue), object: nil)
    }

    // UITableViewの設定
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 68.0
        tableView.delaysContentTouches = false
        tableView.isScrollEnabled = false
        tableView.contentInset.bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        tableView.registerCustomCell(SubContentsTableViewCell.self)
    }
}

// MARK: - UITableViewDataSource

extension DetailSubContentsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCustomCell(with: SubContentsTableViewCell.self)
        cell.setCell(title: "Title of (\(indexPath.row))", description: "Description of (\(indexPath.row))")
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension DetailSubContentsListViewController: UIScrollViewDelegate {

    // REMARK: 現在表示中のUITableViewのY軸方向のオフセット値がマイナスになったらDetailViewController.swiftのスクロールを有効にする
    // → しかしながらこの手法では引っかかる感じになってしまっている...

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset
        if scrollBeginingPoint.y == 0 {
            // Notification名「ActivateMainContentsScrollNotification」を送信する
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateSubContentsScrollNotification.rawValue), object: self, userInfo: nil)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        if scrollView.contentOffset.y < 0 && scrollBeginingPoint.y > currentPoint.y {
            // Notification名「ActivateMainContentsScrollNotification」を送信する
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateMainContentsScrollNotification.rawValue), object: self, userInfo: nil)
            // Notification名「UpdateTableViewOffsetNotification」を送信する
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.UpdateTableViewOffsetNotification.rawValue), object: self, userInfo: nil)
        }
    }
}

// MARK: - StoryboardInstantiatable

extension DetailSubContentsListViewController: StoryboardInstantiatable {
    
    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Detail"
    }
    
    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return DetailSubContentsListViewController.className
    }
}

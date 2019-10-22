//
//  DetailSubContentsListViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailSubContentsListViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetTableViewPosition), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateMainContentsScrollNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableTableViewPosition), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateSubContentsScrollNotification.rawValue), object: nil)
    }

    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: -  Private Function

    //
    @objc private func enableTableViewPosition() {
        tableView.bounces = true
        tableView.isScrollEnabled = true
    }

    //
    @objc private func resetTableViewPosition() {
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.scrollsToTop = true
    }

    private func setupTableView() {
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.estimatedRowHeight = 86.0
        tableView.rowHeight = 60.0 //UITableView.automaticDimension
        tableView.delaysContentTouches = false
        tableView.isScrollEnabled = false
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
            cell.titleLabel.text = "Sample(\(indexPath.row))"
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension DetailSubContentsListViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0.0 {
            scrollView.contentOffset.y = 0.0
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateMainContentsScrollNotification.rawValue), object: self, userInfo: nil)
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

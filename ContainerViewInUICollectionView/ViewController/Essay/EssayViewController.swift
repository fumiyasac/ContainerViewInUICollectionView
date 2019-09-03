//
//  EssayViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import WebKit

final class EssayViewController: UIViewController {
    
    //
    private let expandedFileBinderLayout = ExpandedFileBinderCollectionViewLayout()
    private let indexFileBinderLayout = IndexFileBinderCollectionViewLayout()

    //
    private var shouldExpandCell = false

    @IBOutlet weak private var collectionView: UICollectionView!

    let sitesData = ["https://www.google.com","https://www.apple.com","https://www.yahoo.com","https://www.bing.com","https://www.msn.com","https://www.cocoacontrols.com","https://www.github.com/AfrozZaheer","https://www.google.com" ]

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerCustomCell(EssayCollectionViewCell.self)
        collectionView.setCollectionViewLayout(indexFileBinderLayout, animated: true)

        indexFileBinderLayout.height = (collectionView?.frame.size.height)! * 1.0
        indexFileBinderLayout.itemGap = 150

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }
    
}

extension EssayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sitesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: EssayCollectionViewCell.self, indexPath: indexPath)

        DispatchQueue.once(token: "\(indexPath.item)") {
            DispatchQueue.main.async {
                let site = self.sitesData[indexPath.item]
                let request = URLRequest(url: URL(string: site)!)
                cell.webView.loadRequest(request)
            }
        }
        
        cell.bgView.layer.shadowColor = UIColor.black.cgColor
        
        cell.bgView.layer.shadowOffset = CGSize(width: 0.0, height: -20.0)
        
        cell.bgView.layer.shadowOpacity = 0.6
        cell.bgView.layer.shadowRadius = 20.0
        cell.bgView.layer.shadowPath = UIBezierPath(rect: cell.contentView.bounds).cgPath
        //cell.bgView.layer.shouldRasterize = true
        cell.bgView.layer.cornerRadius = 15
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        DispatchQueue.main.async {
            if self.shouldExpandCell == false {
                collectionView.setCollectionViewLayout(self.expandedFileBinderLayout, animated: true)
                self.shouldExpandCell = true
            } else {
                collectionView.setCollectionViewLayout(self.indexFileBinderLayout, animated: true)
                self.shouldExpandCell = false
            }
        }
    }
}


public extension DispatchQueue {
    
    private static var _onceTracker: [String] = []

    // 任意の処理を一度だけ実行するためのクラスメソッド
    class func once(token: String, block: () -> Void) {

        // 排他処理用ロックの開始
        objc_sync_enter(self)

        // deferで途中で処理が中断
        defer {
            // 排他処理用ロックの解除
            objc_sync_exit(self)
        }

        // 第1引数で指定したトークンが存在したら以降の処理を実行しない
        if _onceTracker.contains(token) {
            return
        }

        // 第1引数で指定したトークンを内部変数へセットする
        _onceTracker.append(token)

        // 第2引数で排他処理用ロックをかけて実行する処理を書く
        block()
    }
}



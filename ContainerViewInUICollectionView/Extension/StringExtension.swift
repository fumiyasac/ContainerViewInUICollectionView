//
//  StringExtension.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/14.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

// Stringの拡張
extension String {

    // 文字列の長さを取得する
    var length: Int {
        return utf16.count
    }
}

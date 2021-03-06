//
//  SynchronizeScreenNotification.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation

enum SynchronizeScreenNotification: String {
    case ActivateMainContentsScrollNotification = "ActivateMainContentsScrollNotification"
    case ActivateSubContentsScrollNotification  = "ActivateSubContentsScrollNotification"
    case UpdateSliderNotification               = "UpdateSliderNotification"
    case UpdateTableViewOffsetNotification      = "UpdateTableViewOffsetNotification"
    case MoveToSelectedSubContentsNotification  = "MoveToSelectedSubContentsNotification"
}

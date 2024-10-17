//
//  RecentLinkModel.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 10/17/24.
//

import Foundation

struct RecentLinkModel {
    let toastId: Int
    let toastTitle: String
    let linkUrl: String
    let isRead: Bool
    let categoryTitle: String?
    let thumbnailUrl: String?
}

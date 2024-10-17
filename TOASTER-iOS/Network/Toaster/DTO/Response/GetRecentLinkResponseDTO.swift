//
//  GetRecentLinkResponseDTO.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 10/17/24.
//

import Foundation

struct GetRecentLinkResponseDTO: Codable {
    let code: Int
    let message: String
    let data: [GetRecentLinkResponseData]
}

struct GetRecentLinkResponseData: Codable {
    let toastId: Int
    let toastTitle: String
    let linkUrl: String
    let isRead: Bool
    let categoryTitle: String?
    let thumbnailUrl: String?
}

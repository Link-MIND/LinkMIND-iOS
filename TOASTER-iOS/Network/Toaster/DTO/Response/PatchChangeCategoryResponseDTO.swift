//
//  PatchChangeCategoryResponseDTO.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 10/8/24.
//

import Foundation

struct PatchChangeCategoryResponseDTO: Codable {
    let code: Int
    let message: String
    let data: PatchChangeCategoryResponseData
}

struct PatchChangeCategoryResponseData: Codable {
    let categoryId: Int
}

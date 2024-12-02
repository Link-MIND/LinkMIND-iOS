//
//  MypageUserModel.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 1/10/24.
//

import Foundation

struct MypageUserModel: Codable {
    let nickname: String
    let profile: String?
    let allReadToast: Int
    let thisWeekendRead: Int
    let thisWeekendSaved: Int
}

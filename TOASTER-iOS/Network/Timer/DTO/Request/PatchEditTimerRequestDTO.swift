//
//  PatchEditTimerRequestDTO.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 1/15/24.
//

import Foundation

struct PatchEditTimerRequestDTO: Codable {
    let remindTime: String
    let remindDates: [Int]
}

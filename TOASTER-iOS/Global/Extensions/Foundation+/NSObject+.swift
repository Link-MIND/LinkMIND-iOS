//
//  NSObject+.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/6/24.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

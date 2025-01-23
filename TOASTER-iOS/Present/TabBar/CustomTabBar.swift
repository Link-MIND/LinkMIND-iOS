//
//  CustomTabBar.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/13/25.
//

import UIKit

final class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height += 11
        return size
    }
}

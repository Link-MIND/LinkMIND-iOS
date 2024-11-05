//
//  UITextField+.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/29/23.
//

import UIKit

extension UITextField {
    
    /// 텍스트필드 안쪽에 패딩 추가
    /// - Parameter left: 왼쪽에 추가할 패딩 너비
    /// - Parameter right: 오른쪽에 추가할 패딩 너비
    func addPadding(left: CGFloat? = nil, right: CGFloat? = nil) {
        if let left {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: 0))
            leftViewMode = .always
        }
        if let right {
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: 0))
            rightViewMode = .always
        }
    }
    
    /// Placeholder의 색상을 바꿔주는 메서드
    func changePlaceholderColor(forPlaceHolder: String, forColor: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: forPlaceHolder, attributes: [NSAttributedString.Key.foregroundColor: forColor])
    }
}

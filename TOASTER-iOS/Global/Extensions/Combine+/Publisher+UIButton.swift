//
//  Publisher+UIButton.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 10/3/24.
//

import Combine
import UIKit

extension UIButton {
    func tapPublisher() -> AnyPublisher<Void, Never> {
        publisher(for: .touchUpInside)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

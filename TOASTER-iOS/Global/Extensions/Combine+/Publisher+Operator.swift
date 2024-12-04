//
//  Publisher+Operator.swift
//  TOASTER-iOS
//
//  Created by 민 on 12/3/24.
//

import Combine
import Foundation

public extension Publisher {
    
    /**
     `networkFlatMap`은 네트워크 함수 호출 시
     `flatMap` 연산을 수행하면서, 메모리 누수 방지와 에러 처리를 위한 반복 코드 사용을 줄이기 위한 커스텀 Operator입니다.
     */
    func networkFlatMap<SelfPublisher: AnyObject, NewPublisher: Publisher>(
        _ weakSelf: SelfPublisher?,
        _ firstTransform: @escaping (SelfPublisher, Output) -> NewPublisher,
        _ secondTransform: @escaping (Error) -> AnyPublisher<NewPublisher.Output, Never> = { _ in
            Empty().eraseToAnyPublisher()
        }
    ) -> AnyPublisher<NewPublisher.Output, Failure> {
        
        self.flatMap { [weak weakSelf] output -> AnyPublisher<NewPublisher.Output, Never> in
            guard let weakSelf else { return Empty().eraseToAnyPublisher() }
            return firstTransform(weakSelf, output)
                .catch { secondTransform($0) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

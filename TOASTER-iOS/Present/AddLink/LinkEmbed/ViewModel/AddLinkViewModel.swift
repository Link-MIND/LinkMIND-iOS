//
//  AddLinkViewModel.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 9/19/24.
//

import Combine
import UIKit

final class AddLinkViewModel: ViewModelType {
    
    private var cancelBag: CancelBag = CancelBag()
    
    let embedLinkText = PassthroughSubject<String, Never>()
    
    struct Input {
        let embedLinkText: AnyPublisher<String, Never>
        let clearButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isClearButtonHidden = PassthroughSubject<Bool, Never>()
        let isNextButtonEnabled = CurrentValueSubject<Bool, Never>(false)
        let textFieldBorderColor = PassthroughSubject<UIColor, Never>()
        let linkEffectivenessMessage = PassthroughSubject<String?, Never>()
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        let inputText = input.embedLinkText
            .merge(with: input.clearButtonTapped.map { "" })
            .eraseToAnyPublisher()
        
        inputText
            .map { $0.isEmpty }
            .sink { isHidden in
                output.isClearButtonHidden.send(isHidden)
            }
            .store(in: cancelBag)
        
        let isValid = inputText
            .map { self.isValidURL($0) }
            .share()
            .eraseToAnyPublisher()
        
        isValid
            .combineLatest(inputText.map { !$0.isEmpty })
            .map { $0 && $1 }
            .sink { isEnabled in
                output.isNextButtonEnabled.send(isEnabled)
            }
            .store(in: cancelBag)
        
        input.embedLinkText
            .map { $0.isEmpty ? "링크를 입력해주세요" : (self.isValidURL($0) ? nil : "유효하지 않은 형식의 링크입니다. " ) }
            .sink { message in
                output.linkEffectivenessMessage.send(message)
            }
            .store(in: cancelBag)
        
        return output
    }
}

private extension AddLinkViewModel {
    func isValidURL(_ urlString: String) -> Bool {
        if (urlString.prefix(8) == "https://") || (urlString.prefix(7) == "http://") {
            return true
        } else {
            return false
        }
    }
}

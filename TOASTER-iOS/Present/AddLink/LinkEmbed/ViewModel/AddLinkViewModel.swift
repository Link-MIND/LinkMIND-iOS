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
    
    struct Input {
        let embedLinkText: AnyPublisher<String, Never>
    }
    
    struct Output {
        let isClearButtonHidden = PassthroughSubject<Bool, Never>()
        let isNextButtonEnabled = CurrentValueSubject<Bool, Never>(false)
        let nextButtonBackgroundColor = CurrentValueSubject<UIColor, Never>(.gray200)
        let textFieldBorderColor = PassthroughSubject<UIColor, Never>()
        let linkEffectivenessMessage = PassthroughSubject<String?, Never>()
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        input.embedLinkText
            .map { $0.isEmpty }
            .sink { isHidden in
                output.isClearButtonHidden.send(isHidden)
            }
            .store(in: cancelBag)
        
        let isValid = input.embedLinkText
            .map { self.isValidURL($0) }
            .share()
            .eraseToAnyPublisher()
        
        isValid
            .combineLatest(input.embedLinkText.map { !$0.isEmpty })
            .map { $0 && $1 }
            .sink { isEnabled in
                print("활성화 유무 : ", isEnabled)
                output.isNextButtonEnabled.send(isEnabled)
                output.nextButtonBackgroundColor.send(isEnabled ? .black850 : .gray200)
            }
            .store(in: cancelBag)
        
        isValid
            .map { $0 ? .clear : UIColor.toasterError }
            .sink { color in
                output.textFieldBorderColor.send(color)
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

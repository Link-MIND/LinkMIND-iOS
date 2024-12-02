//
//  ShareViewModel.swift
//  ToasterShareExtension
//
//  Created by ParkJunHyuk on 9/29/24.
//

import Foundation
import Combine

final class ShareViewModel: ViewModelType {

    private let appURL = "TOASTER://"
    private var urlString = ""
    
    struct Input {
        let selectedClip: AnyPublisher<RemindClipModel, Never>
        let completeButtonTap: AnyPublisher<Void, Never>
        let closeButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isSeleted: AnyPublisher<Bool, Never>
        let completeButtonAction: AnyPublisher<Bool, Never>
        let closeButtonAction: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let categoryIDPublisher = input.selectedClip
            .map { clip in
                clip.id == 0 ? nil : clip.id
            }
            .eraseToAnyPublisher()
        
        let isSelectedPublisher = input.selectedClip
            .map { _ in true }
            .eraseToAnyPublisher()

        let saveLinkResultPublisher = input.completeButtonTap
            .combineLatest(categoryIDPublisher)
            .map { _, categoryID in categoryID }
            .flatMap { [weak self] categoryID -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                return self.postSaveLink(id: categoryID)
                    .catch { error -> AnyPublisher<Bool, Never> in
                        print("실패: \(error.localizedDescription)")
                        return Just(false).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return Output(
            isSeleted: isSelectedPublisher,
            completeButtonAction: saveLinkResultPublisher,
            closeButtonAction: input.closeButtonTap
        )
    }
    
    func bindUrl(_ url: String) {
        self.urlString = url
    }
    
    func readAppURL() -> String {
        return appURL
    }
}

// MARK: - API Methods

private extension ShareViewModel {
    func postSaveLink(id: Int?) -> AnyPublisher<Bool, Error> {
        let request = PostSaveLinkRequestDTO(linkUrl: self.urlString, categoryId: id)
        
        return Future<Bool, Error> { promise in
            NetworkService.shared.toastService.postSaveLink(requestBody: request) { result in
                switch result {
                case .success:
                    print("저장 성공")
                    promise(.success(true))
                case .networkFail, .unAuthorized, .notFound, .badRequest, .serverErr, .decodeErr, .unProcessable:
                    print("저장 실패")
                    promise(.failure(NSError(domain: "PostSaveLinkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "링크 저장에 실패했습니다."])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

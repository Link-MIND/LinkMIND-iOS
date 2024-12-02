//
//  LinkWebViewModel.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/2/24.
//

import Combine
import UIKit

final class LinkWebViewModel: ViewModelType {
    
    private var cancelBag = CancelBag()
    
    // MARK: - Input State
    
    struct Input {
        let readLinkButtonTapped: Driver<LinkReadEditModel>
    }
    
    // MARK: - Output State
    
    struct Output {
        let isRead = PassthroughSubject<Bool, Never>()
        let navigateToLogin = PassthroughSubject<Void, Never>()
    }
    
    // MARK: - Method
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        input.readLinkButtonTapped
            .flatMap { [weak self] model in
                self?.performLinkReadRequest(model, output) ?? Driver.empty()
            }
            .sink { isRead in
                output.isRead.send(!isRead)
            }.store(in: cancelBag)
        
        return output
    }
    
    func performLinkReadRequest(_ model: LinkReadEditModel, _ output: Output) -> Driver<Bool> {
        return patchOpenLinkAPI(requestBody: model)
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    output.navigateToLogin.send()
                }
            }).asDriver()
    }
}

// MARK: - Network

private extension LinkWebViewModel {
    func patchOpenLinkAPI(requestBody: LinkReadEditModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            NetworkService.shared.toastService.patchOpenLink(
                requestBody: PatchOpenLinkRequestDTO(
                    toastId: requestBody.toastId,
                    isRead: requestBody.isRead
                )
            ) { result in
               switch result {
               case .success:
                   promise(.success(!requestBody.isRead))
               case .unAuthorized, .networkFail, .notFound:
                   promise(.failure(NetworkResult<Error>.unAuthorized))
               default:
                   break
               }
           }
        }.eraseToAnyPublisher()
    }
}

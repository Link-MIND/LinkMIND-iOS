//
//  ClipViewModel.swift
//  TOASTER-iOS
//
//  Created by 민 on 2/7/24.
//

import Combine
import UIKit

final class ClipViewModel: ViewModelType {
    
    private var cancelBag = CancelBag()
    var clipList: ClipModel = ClipModel(allClipToastCount: 0, clips: [])
    
    // MARK: - Input State
    
    struct Input {
        let requestClipList: Driver<Void>
        let clipNameChanged: Driver<String>
        let addClipButtonTapped: Driver<String>
    }
    
    // MARK: - Output State
    
    struct Output {
        let needToReload = PassthroughSubject<Void, Never>()
        let addClipResult = PassthroughSubject<Bool, Never>()
        let duplicateClipName = PassthroughSubject<Bool, Never>()
    }
    
    // MARK: - Method
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        input.requestClipList
            .networkFlatMap(self) { context, _ in
                context.getAllCategoryAPI()
            }
            .sink { [weak self] clipList in
                self?.clipList = clipList
                output.needToReload.send()
            }.store(in: cancelBag)
                
        input.clipNameChanged
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .networkFlatMap(self) { context, clipTitle in
                context.getCheckCategoryAPI(categoryTitle: clipTitle)
            }
            .sink { isDuplicate in
                output.duplicateClipName.send(isDuplicate)
            }.store(in: cancelBag)
        
        input.addClipButtonTapped
            .networkFlatMap(self) { context, clipTitle in
                context.postAddCategoryAPI(requestBody: clipTitle)
            }
            .sink { isSuccess in
                output.addClipResult.send(isSuccess)
                if isSuccess {
                    output.needToReload.send()
                }
            }.store(in: cancelBag)
        
        return output
    }
}

// MARK: - Network

private extension ClipViewModel {
    func getAllCategoryAPI() -> AnyPublisher<ClipModel, Error> {
        return Future<ClipModel, Error> { promise in
            NetworkService.shared.clipService.getAllCategory { result in
                switch result {
                case .success(let response):
                    let allClipToastCount = response?.data.toastNumberInEntire
                    let clips = response?.data.categories.map {
                        AllClipModel(id: $0.categoryId,
                                     title: $0.categoryTitle,
                                     toastCount: $0.toastNum)
                    }
                    promise(.success(ClipModel(allClipToastCount: allClipToastCount ?? 0, clips: clips ?? [])))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getCheckCategoryAPI(categoryTitle: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            NetworkService.shared.clipService.getCheckCategory(categoryTitle: categoryTitle) { result in
                switch result {
                case .success(let response):
                    if let data = response?.data.isDupicated, categoryTitle.count < 16 {
                        promise(.success(data))
                    }
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func postAddCategoryAPI(requestBody: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            NetworkService.shared.clipService.postAddCategory(requestBody: PostAddCategoryRequestDTO(categoryTitle: requestBody)) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
}

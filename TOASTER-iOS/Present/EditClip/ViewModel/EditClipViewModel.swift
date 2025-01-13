//
//  EditClipViewModel.swift
//  TOASTER-iOS
//
//  Created by 민 on 2/8/24.
//

import Combine
import UIKit

final class EditClipViewModel: ViewModelType {
    
    private var cancelBag = CancelBag()
    
    private(set) var cellIndex: Int = 0
    var clipList: ClipModel = ClipModel(allClipToastCount: 0, clips: [])
    
    // MARK: - Input State
    
    struct Input {
        let requestClipList: Driver<Void>
        let deleteClipButtonTapped: Driver<Int>
        let clipNameChanged: Driver<String>
        let changeClipNameButtonTapped: Driver<ClipNameEditModel>
        let clipOrderedChanged: Driver<ClipPriorityEditModel>
    }
    
    // MARK: - Output State
    
    struct Output {
        let needToReload = PassthroughSubject<Void, Never>()
        let deleteClipResult = PassthroughSubject<Void, Never>()
        let duplicateClipName = PassthroughSubject<Bool, Never>()
        let changeClipNameResult = PassthroughSubject<Bool, Never>()
    }
    
    // MARK: - Cancellable Bag
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        input.deleteClipButtonTapped
            .networkFlatMap(self) { context, clipID in
                context.deleteCategoryAPI(deleteCategoryDto: clipID)
            }
            .sink { _ in
                output.deleteClipResult.send()
                output.needToReload.send()
            }.store(in: cancelBag)
        
        input.clipNameChanged
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .networkFlatMap(self) { context, clipTitle in
                context.getCheckCategoryAPI(categoryTitle: clipTitle)
            }
            .sink { isDuplicated in
                output.duplicateClipName.send(isDuplicated)
            }.store(in: cancelBag)
        
        input.changeClipNameButtonTapped
            .networkFlatMap(self) { context, model in
                context.patchEditNameCategoryAPI(requestBody: model)
            }
            .sink { isSuccess in
                output.changeClipNameResult.send(isSuccess)
            }.store(in: cancelBag)
        
        input.clipOrderedChanged
            .networkFlatMap(self) { context, model in
                context.patchEditPriorityCategoryAPI(requestBody: model)
            }
            .sink { _ in
                output.needToReload.send()
            }.store(in: cancelBag)
        
        return output
    }
}

// MARK: - Extension

extension EditClipViewModel {
    func setupCellIndex(_ index: Int) {
        cellIndex = index
    }
}

// MARK: - Network

private extension EditClipViewModel {
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
                    promise(.success(
                        ClipModel(allClipToastCount: allClipToastCount ?? 0, clips: clips ?? [])
                    ))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteCategoryAPI(deleteCategoryDto: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            NetworkService.shared.clipService.deleteCategory(deleteCategoryDto: deleteCategoryDto) { result in
                switch result {
                case .success:
                    promise(.success(()))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func patchEditPriorityCategoryAPI(requestBody: ClipPriorityEditModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            NetworkService.shared.clipService.patchEditPriorityCategory(
                requestBody: PatchEditPriorityCategoryRequestDTO(
                    categoryId: requestBody.id,
                    newPriority: requestBody.priority
                )
            ) { result in
                switch result {
                case .success:
                    promise(.success(()))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }

    func patchEditNameCategoryAPI(requestBody: ClipNameEditModel) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            NetworkService.shared.clipService.patchEditNameCategory(
                requestBody: PatchEditNameCategoryRequestDTO(
                    categoryId: requestBody.id,
                    newTitle: requestBody.title
                )
            ) { result in
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
}

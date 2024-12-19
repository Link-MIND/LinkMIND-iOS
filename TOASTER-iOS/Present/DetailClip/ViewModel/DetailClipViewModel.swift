//
//  DetailClipViewModel.swift
//  TOASTER-iOS
//
//  Created by 민 on 2/8/24.
//

import Combine
import UIKit

final class DetailClipViewModel: ViewModelType {
    
    private var cancelBag = CancelBag()
    
    private(set) var toastList: DetailClipModel = DetailClipModel(allToastCount: 0, toastList: [])
    
    private(set) var currentToastId: Int = 0
    private(set) var currentCategoryId: Int = 0
    private(set) var currentCategoryName: String = ""
    private(set) var segmentIndex: Int = 0
    private(set) var linkTitle: String = ""
    
    private(set) var botomHeigth: CGFloat = 0
    private(set) var collectionViewHeight: CGFloat = 0
    
    // MARK: - Input State
    
    struct Input {
        let requestToast: Driver<Bool>
        let changeSegmentIndex: Driver<Int>
        let editToastTitleButtonTap: Driver<(Int, String)>
        let changeClipButtonTap: Driver<Void>
        let selectedClip: Driver<Int>
        let changeClipCompleteButtonTap: Driver<Void>
        let deleteToastButtonTap: Driver<Int>
    }
    
    // MARK: - Output State
    
    struct Output {
        let loadToToastList = PassthroughSubject<Bool, Never>()
        let toastNameChanged = PassthroughSubject<Bool, Never>()
        let loadToClipData = PassthroughSubject<[SelectClipModel]?, Never>()
        let isCompleteButtonEnable = PassthroughSubject<Bool, Never>()
        let deleteToastComplete = PassthroughSubject<Void, Never>()
    }
    
    // MARK: - Method
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        let output = Output()
        
        input.requestToast
            .networkFlatMap(self) { context, isAll in
                if isAll {
                    context.getDetailAllCategoryAPI(filter: .all)
                } else {
                    context.getDetailCategoryAPI(categoryID: self.currentCategoryId, filter: .all)
                }
            }
            .sink { [weak self] toasts in
                self?.toastList = toasts
                output.loadToToastList.send(!toasts.toastList.isEmpty)
            }.store(in: cancelBag)

        input.changeSegmentIndex
            .networkFlatMap(self) { context, index in
                if self.currentCategoryId == 0 {
                    switch index {
                    case 0:
                        context.getDetailAllCategoryAPI(filter: .all)
                    case 1:
                        context.getDetailAllCategoryAPI(filter: .read)
                    default:
                        context.getDetailAllCategoryAPI(filter: .unread)
                    }
                } else {
                    switch index {
                    case 0:
                        context.getDetailCategoryAPI(categoryID: self.currentCategoryId, filter: .all)
                    case 1:
                        context.getDetailCategoryAPI(categoryID: self.currentCategoryId, filter: .read)
                    default:
                        context.getDetailCategoryAPI(categoryID: self.currentCategoryId, filter: .unread)
                    }
                }
            }
            .sink { [weak self] toasts in
                self?.toastList = toasts
                output.loadToToastList.send(!toasts.toastList.isEmpty)
            }.store(in: cancelBag)
        
        input.editToastTitleButtonTap
            .networkFlatMap(self) { context, toast in
                context.patchEditLinkTitleAPI(toastId: toast.0, title: toast.1)
            }
            .sink { [weak self] isSuccess in
                output.toastNameChanged.send(isSuccess)
                output.loadToToastList.send(self?.currentCategoryId == 0)
            }.store(in: cancelBag)
        
        input.selectedClip
            .networkFlatMap(self) { context, _ in
                context.getAllCategoryAPI()
                    .map { [weak self] result -> [SelectClipModel]? in
                        guard let self = self else { return [] }
                        if result.count < 2 { return nil }  // 2개 이하일 경우 nil 반환
                        let sortedResult = self.sortCurrentCategoryToTop(result)
                        self.collectionViewHeight = self.calculateCollectionViewHeight(numberOfItems: sortedResult.count)
                        return sortedResult
                    }
            }
            .sink { model in
                output.loadToClipData.send(model)
            }.store(in: cancelBag)
        
        input.changeClipCompleteButtonTap
            .zip(input.selectedClip) { _, selectedClip in
                return selectedClip
            }
            .networkFlatMap(self) { context, selectClip in
                context.patchChangeCategory(categoryId: selectClip)
            }
            .sink { _ in
                // output.loadToToastList.send()
            }.store(in: cancelBag)
        
        input.deleteToastButtonTap
            .networkFlatMap(self) { context, toastId in
                context.deleteLinkAPI(toastId: toastId)
            }
            .sink { [weak self] _ in
                output.loadToToastList.send(self?.currentCategoryId == 0)
                output.deleteToastComplete.send()
            }.store(in: cancelBag)
        
        
//        
//        /// 이동할 클립을 선택 시 버튼의 UI 를 변경하는 동작
//        let isCompleteButtonEnable = Publishers.Merge(
//            input.changeButtonTap.map { false },  // bottomSheet 열릴 때 false
//            input.selectedClip.map { _ in true }  // 클립 선택 시 true
//        ).eraseToAnyPublisher()

        
        return output
    }
    
    func setupCategory(_ id: Int) {
        currentCategoryId = id
    }
    
    func setupCategoryName(_ name: String) {
        currentCategoryName = name
    }
    
    func setupToastId(_ id: Int) {
        currentToastId = id
    }
}

// MARK: - private Extensions

private extension DetailClipViewModel {
    
    /// 현재 카테고리를 최상단에 위치하도록 정렬하는 메서드
    func sortCurrentCategoryToTop(_ clipDataList: [SelectClipModel]) -> [SelectClipModel] {
        guard let currentCategoryIndex = clipDataList.firstIndex(where: { $0.id == currentCategoryId }) else {
            return clipDataList
        }
        
        var tempClipDataList = clipDataList
        let currentCategoryData = tempClipDataList.remove(at: currentCategoryIndex)
        tempClipDataList.insert(currentCategoryData, at: 0)
        
        calculateBottomSheetHeight(clipDataList.count)
        
        return tempClipDataList
    }
    
    func calculateBottomSheetHeight(_ count: Int) {
        botomHeigth = CGFloat(count * 54 + 184 + 3)
    }
    
    func calculateCollectionViewHeight(numberOfItems: Int) -> CGFloat {
        let cellHeight: CGFloat = 54
        let lineSpacing: CGFloat = 1
        
        // 마지막 셀 다음에는 간격이 없으므로 (numberOfItems - 1)
        let totalHeight = (cellHeight * CGFloat(numberOfItems)) + (lineSpacing * CGFloat(numberOfItems - 1))
        print("높이:", totalHeight)
        return totalHeight
    }
}

// MARK: - Network

private extension DetailClipViewModel {
    func getDetailAllCategoryAPI(filter: DetailCategoryFilter) -> AnyPublisher<DetailClipModel, Error> {
        return Future<DetailClipModel, Error> { promise in
            NetworkService.shared.clipService.getDetailAllCategory(filter: filter) { result in
                switch result {
                case .success(let response):
                    let allToastCount = response?.data.allToastNum
                    let toasts = response?.data.toastListDto.map {
                        ToastListModel(
                            id: $0.toastId,
                            title: $0.toastTitle,
                            url: $0.linkUrl,
                            isRead: $0.isRead,
                            clipTitle: $0.categoryTitle,
                            imageURL: $0.thumbnailUrl
                        )
                    }
                    let detailClipModel = DetailClipModel(
                        allToastCount: allToastCount ?? 0,
                        toastList: toasts ?? []
                    )
                    promise(.success(detailClipModel))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getDetailCategoryAPI(categoryID: Int,
                              filter: DetailCategoryFilter) -> AnyPublisher<DetailClipModel, Error> {
        return Future<DetailClipModel, Error> { promise in
            NetworkService.shared.clipService.getDetailCategory(categoryID: categoryID, filter: filter) { result in
                switch result {
                case .success(let response):
                    let allToastCount = response?.data.allToastNum
                    let toasts = response?.data.toastListDto.map {
                        ToastListModel(
                            id: $0.toastId,
                            title: $0.toastTitle,
                            url: $0.linkUrl,
                            isRead: $0.isRead,
                            clipTitle: $0.categoryTitle,
                            imageURL: $0.thumbnailUrl
                        )
                    }
                    let detailClipModel = DetailClipModel(
                        allToastCount: allToastCount ?? 0,
                        toastList: toasts ?? []
                    )
                    promise(.success(detailClipModel))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    return
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func patchEditLinkTitleAPI(toastId: Int, title: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            NetworkService.shared.toastService.patchEditLinkTitle(
                requestBody: PatchEditLinkTitleRequestDTO(
                    toastId: toastId,
                    title: title
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
    
    func deleteLinkAPI(toastId: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            NetworkService.shared.toastService.deleteLink(toastId: toastId) { result in
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
    
    func getAllCategoryAPI() -> AnyPublisher<[SelectClipModel], Error> {
        return Future<[SelectClipModel], Error> { promise in
            NetworkService.shared.clipService.getAllCategory { result in
                switch result {
                case .success(let response):
                    let clipDataList = response?.data.categories.map { category in
                        SelectClipModel(
                            id: category.categoryId,
                            title: category.categoryTitle,
                            clipCount: category.toastNum
                        )
                    } ?? []
                    promise(.success(clipDataList))
                case .unAuthorized, .networkFail, .notFound:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    break
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func patchChangeCategory(categoryId: Int) -> AnyPublisher<Bool, Error> {
        let requestDTO = PatchChangeCategoryRequestDTO(toastId: currentToastId, categoryId: categoryId)
        
        return Future<Bool, Error> { promise in
            NetworkService.shared.toastService.patchChangeCategory(requestBody: requestDTO) { result in
                switch result {
                case .success:
                    promise(.success(true))
                case .unAuthorized, .networkFail, .notFound, .serverErr:
                    promise(.failure(NetworkResult<Error>.unAuthorized))
                default:
                    break
                }
            }
            
        }.eraseToAnyPublisher()
    }
}

//import Foundation
//
//protocol PatchClipDelegate: AnyObject {
//    func patchEnd()
//}
//
//final class DetailClipViewModel: NSObject {
//    
//    // MARK: - Properties
//    
//    typealias DataChangeAction = (Bool) -> Void
//    private var dataChangeAction: DataChangeAction?
//    
//    typealias NormalChangeAction = () -> Void
//    private var unAuthorizedAction: NormalChangeAction?
//    private var editLinkTitleAction: NormalChangeAction?
//    
//    weak var delegate: PatchClipDelegate?
//    
//    // MARK: - Data
//    
//    var toastId: Int = 0
//    var categoryId: Int = 0
//    var categoryName: String = ""
//    var segmentIndex: Int = 0
//    var linkTitle: String = ""
//    
//    private(set) var toastList: DetailClipModel = DetailClipModel(allToastCount: 0, toastList: []) {
//        didSet {
//            dataChangeAction?(!toastList.toastList.isEmpty)
//        }
//    }
//}
//
//// MARK: - Extensions
//
//extension DetailClipViewModel {
//    func setupDataChangeAction(changeAction: @escaping DataChangeAction,
//                               forUnAuthorizedAction: @escaping NormalChangeAction,
//                               editNameAction: @escaping NormalChangeAction) {
//        dataChangeAction = changeAction
//        unAuthorizedAction = forUnAuthorizedAction
//        editLinkTitleAction = editNameAction
//    }
//    
//    func getViewModelProperty(dataType: DetailClipPropertyType) -> Any {
//        switch dataType {
//        case .toastId:
//            return toastId
//        case .categoryId:
//            return categoryId
//        case .categoryName:
//            return categoryName
//        case .segmentIndex:
//            return segmentIndex
//        case .linkTitle:
//            return linkTitle
//        }
//    }
//    
//    func getDetailAllCategoryAPI(filter: DetailCategoryFilter) {
//        NetworkService.shared.clipService.getDetailAllCategory(filter: filter) { result in
//            switch result {
//            case .success(let response):
//                let allToastCount = response?.data.allToastNum
//                let toasts = response?.data.toastListDto.map {
//                    ToastListModel(id: $0.toastId,
//                                    title: $0.toastTitle,
//                                    url: $0.linkUrl,
//                                    isRead: $0.isRead,
//                                    clipTitle: $0.categoryTitle,
//                                    imageURL: $0.thumbnailUrl)
//                }
//                self.toastList = DetailClipModel(allToastCount: allToastCount ?? 0,
//                                                 toastList: toasts ?? [])
//            case .unAuthorized, .networkFail, .notFound:
//                self.unAuthorizedAction?()
//            default: return
//            }
//        }
//    }
//    
//    func getDetailCategoryAPI(categoryID: Int, 
//                              filter: DetailCategoryFilter,
//                              completion: (() -> Void)? = nil) {
//        NetworkService.shared.clipService.getDetailCategory(categoryID: categoryID, filter: filter) { result in
//            switch result {
//            case .success(let response):
//                let allToastCount = response?.data.allToastNum
//                let toasts = response?.data.toastListDto.map {
//                    ToastListModel(id: $0.toastId,
//                                    title: $0.toastTitle,
//                                    url: $0.linkUrl,
//                                    isRead: $0.isRead,
//                                    clipTitle: $0.categoryTitle,
//                                    imageURL: $0.thumbnailUrl)
//                }
//                self.toastList = DetailClipModel(allToastCount: allToastCount ?? 0,
//                                                 toastList: toasts ?? [])
//                completion?()
//            case .unAuthorized, .networkFail, .notFound:
//                self.unAuthorizedAction?()
//            default: return
//            }
//        }
//    }
//    
//    func deleteLinkAPI(toastId: Int) {
//        NetworkService.shared.toastService.deleteLink(toastId: toastId) { result in
//            switch result {
//            case .success:
//                if self.categoryId == 0 {
//                    switch self.segmentIndex {
//                    case 0: self.getDetailAllCategoryAPI(filter: .all)
//                    case 1: self.getDetailAllCategoryAPI(filter: .read)
//                    default: self.getDetailAllCategoryAPI(filter: .unread)
//                    }
//                } else {
//                    switch self.segmentIndex {
//                    case 0: self.getDetailCategoryAPI(categoryID: self.categoryId, filter: .all) {
//                    }
//                    case 1: self.getDetailCategoryAPI(categoryID: self.categoryId, filter: .read) {
//                    }
//                    default: self.getDetailCategoryAPI(categoryID: self.categoryId, filter: .unread) {
//                    }
//                    }
//                }
//            case .unAuthorized, .networkFail, .notFound:
//                self.unAuthorizedAction?()
//            default: return
//            }
//        }
//    }
//    
//    func patchEditLinkTitleAPI(toastId: Int, title: String) {
//        NetworkService.shared.toastService.patchEditLinkTitle(
//            requestBody: PatchEditLinkTitleRequestDTO(
//                toastId: toastId,
//                title: title)) { result in
//            switch result {
//            case .success:
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.editLinkTitleAction?()
//                }
//                self.delegate?.patchEnd()
//            case .unAuthorized, .networkFail, .notFound:
//                self.unAuthorizedAction?()
//            default: return
//            }
//        }
//    }
//}

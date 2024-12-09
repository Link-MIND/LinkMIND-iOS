//
//  ChangeClipViewModel.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 10/9/24.
//

import Combine
import Foundation

final class ChangeClipViewModel: ViewModelType {
    
    private(set) var currentToastId: Int = 0
    private(set) var currentCategoryId: Int = 0
    private(set) var botomHeigth: CGFloat = 0
    private(set) var collectionViewHeight: CGFloat = 0
    
    struct Input {
        let changeButtonTap: AnyPublisher<Void, Never>
        let selectedClip: AnyPublisher<Int, Never>
        let completeButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let clipData: AnyPublisher<[SelectClipModel]?, Never>
        let isCompleteButtonEnable: AnyPublisher<Bool, Never>
        let changeCategoryResult: AnyPublisher<Bool, Never>
    }
    
    func transform(_ input: Input, cancelBag: CancelBag) -> Output {
        
        /// 클립이동 버튼이 눌렸을때 동작
        let clipDataPublisher = input.changeButtonTap
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
        
        /// 이동할 클립을 선택 시 버튼의 UI 를 변경하는 동작
        let isCompleteButtonEnable = Publishers.Merge(
            input.changeButtonTap.map { false },  // bottomSheet 열릴 때 false
            input.selectedClip.map { _ in true }  // 클립 선택 시 true
        ).eraseToAnyPublisher()
        
        /// 완료 버튼이 눌렸을때 동작
        let changeCategoryResult = input.completeButtonTap
            .zip(input.selectedClip) { _, selectedClip in
                return selectedClip
            }
            .networkFlatMap(self) { context, selectClip in
                context.patchChagneCategory(categoryId: selectClip)
            }
        
        return Output(
            clipData: clipDataPublisher,
            isCompleteButtonEnable: isCompleteButtonEnable,
            changeCategoryResult: changeCategoryResult
        )
    }
    
    func setupCategory(_ id: Int) {
        currentCategoryId = id
    }
    
    func setupToastId(_ id: Int) {
        currentToastId = id
    }
}

// MARK: - private Extensions

private extension ChangeClipViewModel {
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

// MARK: - API Extensions

extension ChangeClipViewModel {
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
    
    func patchChagneCategory(categoryId: Int) -> AnyPublisher<Bool, Error> {
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

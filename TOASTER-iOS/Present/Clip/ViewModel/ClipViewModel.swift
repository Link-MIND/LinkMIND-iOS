//
//  ClipViewModel.swift
//  TOASTER-iOS
//
//  Created by 민 on 2/7/24.
//

import Foundation

final class ClipViewModel: NSObject {
    
    // MARK: - Properties
    
    typealias DataChangeAction = (Bool) -> Void
    private var dataChangeAction: DataChangeAction?
    private var loadingStatusAction: DataChangeAction?
    private var moveBottomAction: DataChangeAction?
    
    typealias NormalChangeAction = () -> Void
    private var unAuthorizedAction: NormalChangeAction?
    private var textFieldEditAction: NormalChangeAction?
    
    // MARK: - Data
    
    private(set) var clipList: ClipModel = ClipModel(allClipToastCount: 0, clips: []) {
        didSet {
            dataChangeAction?(!clipList.clips.isEmpty)
        }
    }
}

// MARK: - Extensions

extension ClipViewModel {
    func setupDataChangeAction(changeAction: @escaping DataChangeAction,
                               loadingAction: @escaping DataChangeAction,
                               forUnAuthorizedAction: @escaping NormalChangeAction,
                               editAction: @escaping NormalChangeAction,
                               moveAction: @escaping DataChangeAction) {
        dataChangeAction = changeAction
        loadingStatusAction = loadingAction
        unAuthorizedAction = forUnAuthorizedAction
        textFieldEditAction = editAction
        moveBottomAction = moveAction
    }
    
    func getAllCategoryAPI() {
        loadingStatusAction?(true)
        NetworkService.shared.clipService.getAllCategory { [weak self] result in
            self?.loadingStatusAction?(false)
            switch result {
            case .success(let response):
                let allClipToastCount = response?.data.toastNumberInEntire
                let clips = response?.data.categories.map {
                    AllClipModel(id: $0.categoryId,
                                 title: $0.categoryTitle,
                                 toastCount: $0.toastNum)
                }
                self?.clipList = ClipModel(allClipToastCount: allClipToastCount ?? 0,
                                           clips: clips ?? [])
            case .unAuthorized, .networkFail, .notFound:
                self?.unAuthorizedAction?()
            default: return
            }
        }
    }
    
    func postAddCategoryAPI(requestBody: String) {
        NetworkService.shared.clipService.postAddCategory(requestBody: PostAddCategoryRequestDTO(categoryTitle: requestBody)) { result in
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.textFieldEditAction?()
                }
                self.getAllCategoryAPI()
            case .unAuthorized, .networkFail, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
    
    func getCheckCategoryAPI(categoryTitle: String) {
        NetworkService.shared.clipService.getCheckCategory(categoryTitle: categoryTitle) { result in
            switch result {
            case .success(let response):
                if let data = response?.data.isDupicated {
                    if categoryTitle.count != 16 {
                        self.moveBottomAction?(data)
                    }
                }
            case .unAuthorized, .networkFail, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
}

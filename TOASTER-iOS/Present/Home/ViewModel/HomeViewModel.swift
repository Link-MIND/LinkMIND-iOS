//
//  HomeViewModel.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/02/23.
//

import Foundation

final class HomeViewModel {
    
    // MARK: - Properties
    
    typealias DataChangeAction = (Bool) -> Void
    private var dataChangeAction: DataChangeAction?
    private var dataEmptyAction: DataChangeAction?
    private var moveBottomAction: DataChangeAction?
    private var showPopupAction: DataChangeAction?
    
    typealias NormalChangeAction = () -> Void
    private var unAuthorizedAction: NormalChangeAction?
    private var textFieldEditAction: NormalChangeAction?
    
    // MARK: - Data
    
    private(set) var mainInfoList: MainInfoModel = MainInfoModel(nickname: "",
                                                    readToastNum: 0,
                                                    allToastNum: 0,
                                                    mainCategoryListDto: []) {
        didSet {
            dataChangeAction?(!mainInfoList.mainCategoryListDto.isEmpty)
        }
    }
    
    private(set) var weeklyLinkList: [WeeklyLinkModel] = [
        WeeklyLinkModel(toastId: 0,
                        toastTitle: "",
                        toastImg: "",
                        toastLink: "")
    ] {
        didSet {
            dataChangeAction?(!weeklyLinkList.isEmpty)
        }
    }
    
    private(set) var recommendSiteList: [RecommendSiteModel] = [
        RecommendSiteModel(siteId: 0,
                           siteTitle: nil ?? "",
                           siteUrl: nil ?? "",
                           siteImg: nil ?? "",
                           siteSub: nil ?? "")
    ] {
        didSet {
            dataChangeAction?(!recommendSiteList.isEmpty)
        }
    }
    
    private(set) var popupInfoList: [PopupInfoModel]? {
        didSet {
            if let isEmpty = popupInfoList?.isEmpty {
                dataChangeAction?(!isEmpty)
            }
        }
    }
}

// MARK: - extension

extension HomeViewModel {
    
    func setupDataChangeAction(changeAction: @escaping DataChangeAction,
                               forUnAuthorizedAction: @escaping NormalChangeAction,
                               editAction: @escaping NormalChangeAction,
                               moveAction: @escaping DataChangeAction,
                               popupAction: @escaping DataChangeAction) {
        dataChangeAction = changeAction
        unAuthorizedAction = forUnAuthorizedAction
        textFieldEditAction = editAction
        moveBottomAction = moveAction
        showPopupAction = popupAction
    }
    
    func fetchMainPageData() {
        NetworkService.shared.userService.getMainPage { result in
            switch result {
            case .success(let response):
                if let data = response?.data {
                    var categoryList: [CategoryList] = [CategoryList(categoryId: 0,
                                                                     categroyTitle: "전체 클립",
                                                                     toastNum: data.allToastNum)]
                    data.mainCategoryListDto.forEach {
                        categoryList.append(CategoryList(categoryId: $0.categoryId,
                                                         categroyTitle: $0.categoryTitle,
                                                         toastNum: $0.toastNum))
                    }
                    self.mainInfoList = MainInfoModel(nickname: data.nickname,
                                                      readToastNum: data.readToastNum,
                                                      allToastNum: data.allToastNum,
                                                      mainCategoryListDto: categoryList)
                }
            case .unAuthorized, .networkFail:
                self.unAuthorizedAction?()
            default:
                return
            }
        }
    }
    
    // 이주의 링크 -> GET
    func fetchWeeklyLinkData() {
        NetworkService.shared.toastService.getWeeksLink { result in
            switch result {
            case .success(let response):
                var list: [WeeklyLinkModel] = []
                if let data = response?.data {
                    for idx in 0..<data.count {
                        list.append(WeeklyLinkModel(toastId: data[idx].linkId,
                                                    toastTitle: data[idx].linkTitle,
                                                    toastImg: data[idx].linkImg ?? "",
                                                    toastLink: data[idx].linkUrl))
                    }
                    self.weeklyLinkList = list
                }
            case .unAuthorized, .networkFail:
                self.unAuthorizedAction?()
            default:
                return
            }
        }
    }
    
    // 추천 사이트 -> GET
    func fetchRecommendSiteData() {
        NetworkService.shared.searchService.getRecommendSite { result in
            switch result {
            case .success(let response):
                var list: [RecommendSiteModel] = []
                if let data = response?.data {
                    for idx in 0..<data.count {
                        list.append(RecommendSiteModel(siteId: data[idx].siteId,
                                                       siteTitle: data[idx].siteTitle,
                                                       siteUrl: data[idx].siteUrl,
                                                       siteImg: data[idx].siteImg,
                                                       siteSub: data[idx].siteSub))
                    }
                    self.recommendSiteList = list
                }
            case .unAuthorized, .networkFail:
                self.unAuthorizedAction?()
            default:
                return
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
    
    func postAddCategoryAPI(requestBody: String) {
        NetworkService.shared.clipService.postAddCategory(requestBody: PostAddCategoryRequestDTO(categoryTitle: requestBody)) { result in
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.textFieldEditAction?()
                }
                self.fetchMainPageData()
            case .networkFail, .unAuthorized, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
    
    func getPopupInfoAPI() {
        NetworkService.shared.popupService.getPopupInfo { result in
            switch result {
            case .success(let response):
                if let data = response?.data.popupList {
                    var list: [PopupInfoModel] = []
                    for idx in 0..<data.count {
                        list.append(PopupInfoModel(id: data[idx].id,
                                                   image: data[idx].image,
                                                   activeStartDate: data[idx].activeStartDate,
                                                   activeEndDate: data[idx].activeEndDate,
                                                   linkURL: data[idx].linkURL))
                    }
                    self.popupInfoList = list
                }
            case .networkFail, .unAuthorized, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
    
    func patchEditPopupHiddenAPI(popupId: Int, hideDate: Int) {
        NetworkService.shared.popupService.patchEditPopupHidden(
            requestBody: PatchPopupHiddenRequestDTO(
                popupID: popupId,
                hideDate: hideDate
            )
        ) { result in
            switch result {
            case .success(let response):
                self.popupInfoList?.removeAll()
            case .networkFail, .unAuthorized, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
}

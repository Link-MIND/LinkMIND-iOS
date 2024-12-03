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
    private var showPopupAction: DataChangeAction?
    
    typealias NormalChangeAction = () -> Void
    private var unAuthorizedAction: NormalChangeAction?
    
    // MARK: - Data
    
    private(set) var mainInfoList: MainInfoModel = MainInfoModel(nickname: "",
                                                    readToastNum: 0,
                                                    allToastNum: 0,
                                                    mainCategoryListDto: []) {
        didSet {
            dataChangeAction?(!mainInfoList.mainCategoryListDto.isEmpty)
        }
    }
    
    private(set) var recentLink: [RecentLinkModel] = [
        RecentLinkModel(toastId: 0,
                        toastTitle: "",
                        linkUrl: "",
                        isRead: true,
                        categoryTitle: nil ?? "",
                        thumbnailUrl: nil ?? "")
    ] {
        didSet {
            dataChangeAction?(!recentLink.isEmpty)
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
            guard let isEmpty = popupInfoList?.isEmpty else { return }
            showPopupAction?(!isEmpty)
        }
    }
}

// MARK: - extension

extension HomeViewModel {
    
    func setupDataChangeAction(changeAction: @escaping DataChangeAction,
                               forUnAuthorizedAction: @escaping NormalChangeAction,
                               popupAction: @escaping DataChangeAction) {
        dataChangeAction = changeAction
        unAuthorizedAction = forUnAuthorizedAction
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
                                                   linkURL: data[idx].linkUrl))
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
                popupId: popupId,
                hideDate: hideDate
            )
        ) { result in
            switch result {
            case .success:
                self.popupInfoList?.removeAll()
            case .networkFail, .unAuthorized, .notFound:
                self.unAuthorizedAction?()
            default: return
            }
        }
    }
    
    // 최근 링크  -> GET
    func fetchRecentLinkData() {
        NetworkService.shared.toastService.getRecentLink { result in
            switch result {
            case .success(let response):
                var list: [RecentLinkModel] = []
                if let data = response?.data {
                    for idx in 0..<data.count {
                        list.append(RecentLinkModel(toastId: data[idx].toastId,
                                                    toastTitle: data[idx].toastTitle,
                                                    linkUrl: data[idx].linkUrl,
                                                    isRead: data[idx].isRead,
                                                    categoryTitle: data[idx].categoryTitle,
                                                    thumbnailUrl: data[idx].thumbnailUrl))
                    }
                    self.recentLink = list
                }
            case .unAuthorized, .networkFail:
                self.unAuthorizedAction?()
            default:
                return
            }
        }
    }
}

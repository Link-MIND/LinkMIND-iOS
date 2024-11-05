//
//  HomeViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//
import UIKit

import SnapKit
import Then

final class HomeViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private let viewModel = HomeViewModel()
    private let clipViewModel = DetailClipViewModel()
    private let homeView = HomeView()
    
    private let addClipBottomSheetView = AddClipBottomSheetView()
    private lazy var addClipBottom = ToasterBottomSheetViewController(bottomType: .white,
                                                                      bottomTitle: "클립 추가",
                                                                      insertView: addClipBottomSheetView)
    
//    private lazy var firstToolTip = ToasterTipView(
//        title: "마지막으로 저장한 링크를\n확인하러 가보세요!",
//        type: .left,
//        sourceItem: navigationView.addressLabel
//    )
    
    private lazy var secondToolTip: ToasterTipView? = {
        guard let tabBarItems = tabBarController?.tabBar.items else { return nil }
        let firstTabItem = tabBarItems[3]
        let sourceItemFrame = firstTabItem.value(forKey: "view") as? UIView ?? UIView()
        
        return ToasterTipView(title: "검색이 더욱 편리해졌어요", type: .top, sourceItem: sourceItemFrame)
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.backgroundColor = .toasterBackground
        
        setupHierarchy()
        setupLayout()
        createCollectionView()
        setupDelegate()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        viewModel.fetchMainPageData()
        viewModel.fetchWeeklyLinkData()
        viewModel.fetchRecommendSiteData()
        viewModel.getPopupInfoAPI()
        viewModel.fetchRecentLinkData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolTip()
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let data = viewModel.recentLink
            if indexPath.item < data.count {
                let nextVC = LinkWebViewController()
                nextVC.hidesBottomBarWhenPushed = true
                nextVC.setupDataBind(linkURL: viewModel.recentLink[indexPath.item].linkUrl,
                                     isRead: viewModel.recentLink[indexPath.item].isRead,
                                     id: viewModel.recentLink[indexPath.item].toastId)
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else {
                addClipCellTapped()
            }
        case 2:
            let nextVC = LinkWebViewController()
            nextVC.hidesBottomBarWhenPushed = true
            let data = viewModel.weeklyLinkList[indexPath.item]
            nextVC.setupDataBind(linkURL: data.toastLink)
            self.navigationController?.pushViewController(nextVC, animated: true)
        case 3:
            let nextVC = LinkWebViewController()
            nextVC.hidesBottomBarWhenPushed = true
            let data = viewModel.recommendSiteList[indexPath.item]
            if let url = data.siteUrl {
                nextVC.setupDataBind(linkURL: url)
            }
            self.navigationController?.pushViewController(nextVC, animated: true)
        default: break
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            let count = viewModel.recentLink.count
            return count == 0 ? 1 : min(count, 3)
        case 2:
            return viewModel.weeklyLinkList.count
        case 3:
            return viewModel.recommendSiteList.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainCollectionViewCell.className,
                for: indexPath
            ) as? MainCollectionViewCell else { return UICollectionViewCell() }
            let model = viewModel.mainInfoList
            cell.bindData(forModel: model)
            return cell
        case 1:
            let lastIndex = viewModel.recentLink.count
            if lastIndex == 0 {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: UserClipEmptyCollectionViewCell.className,
                    for: indexPath
                ) as? UserClipEmptyCollectionViewCell else { return UICollectionViewCell() }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DetailClipListCollectionViewCell.className,
                    for: indexPath
                ) as? DetailClipListCollectionViewCell else { return UICollectionViewCell() }
                if indexPath.item < lastIndex {
                    let model = viewModel.recentLink
                    cell.configureCell(forModel: model[indexPath.item], isClipHidden: false)
                }
                return cell
            }
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WeeklyLinkCollectionViewCell.className,
                for: indexPath
            ) as? WeeklyLinkCollectionViewCell else { return UICollectionViewCell() }
            let model = viewModel.weeklyLinkList
            cell.bindData(forModel: model[indexPath.item])
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WeeklyRecommendCollectionViewCell.className,
                for: indexPath
            ) as? WeeklyRecommendCollectionViewCell else { return UICollectionViewCell() }
            let model = viewModel.recommendSiteList
            cell.bindData(forModel: model[indexPath.item])
            return cell
        default:
            return MainCollectionViewCell()
        }
    }
    
    // Header, Footer
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeHeaderCollectionView.className,
                for: indexPath
            ) as? HomeHeaderCollectionView else { return UICollectionReusableView() }
            switch indexPath.section {
            case 1:
                let nickName = viewModel.mainInfoList.nickname
                header.configureHeader(forTitle: nickName,
                                       num: indexPath.section)
                header.arrowButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
            case 2:
                header.configureHeader(forTitle: "이주의 링크",
                                       num: indexPath.section)
            case 3:
                header.configureHeader(forTitle: "이주의 추천 사이트",
                                       num: indexPath.section)
            default: break
            }
            return header
            
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeFooterCollectionView.className,
                for: indexPath
            ) as? HomeFooterCollectionView else { return UICollectionReusableView() }
            return footer
        default: return UICollectionReusableView()
        }
    }
    
    // Header 크기 지정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 335, height: 40)
    }
    
    // Footer 크기 지정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 4)
    }
}

// MARK: - Private Extensions

private extension HomeViewController {
    func setupHierarchy() {
        view.addSubview(homeView.collectionView)
    }
    
    func setupLayout() {
        homeView.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createCollectionView() {
        let homeCollectionView = homeView.collectionView
        homeCollectionView.backgroundColor = .toasterBackground
        homeCollectionView.alwaysBounceVertical = true
        
        homeCollectionView.do {
            $0.register(MainCollectionViewCell.self,
                        forCellWithReuseIdentifier: MainCollectionViewCell.className)
            $0.register(WeeklyLinkCollectionViewCell.self,
                        forCellWithReuseIdentifier: WeeklyLinkCollectionViewCell.className)
            $0.register(WeeklyRecommendCollectionViewCell.self,
                        forCellWithReuseIdentifier: WeeklyRecommendCollectionViewCell.className)
            $0.register(UserClipEmptyCollectionViewCell.self,
                        forCellWithReuseIdentifier: UserClipEmptyCollectionViewCell.className)
            $0.register(DetailClipListCollectionViewCell.self,
                        forCellWithReuseIdentifier: DetailClipListCollectionViewCell.className)
            
            // header
            $0.register(HomeHeaderCollectionView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: HomeHeaderCollectionView.className)
            
            // footer
            $0.register(HomeFooterCollectionView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                        withReuseIdentifier: HomeFooterCollectionView.className)
        }
        addClipBottomSheetView.addClipBottomSheetViewDelegate = self
    }
    
    func setupDelegate() {
        homeView.collectionView.delegate = self
        homeView.collectionView.dataSource = self
    }
    
    // ViewModel
    func setupViewModel() {
        viewModel.setupDataChangeAction(changeAction: reloadCollectionView,
                                        forUnAuthorizedAction: unAuthorizedAction,
                                        editAction: addClipAction,
                                        moveAction: moveBottomAction,
                                        popupAction: showPopupAction)
    }
    
    func setupToolTip() {
        guard let secondToolTip else { return }
        
        view.addSubview(secondToolTip)
        secondToolTip.showToolTipAndDismissAfterDelay(duration: 4)
//        if UserDefaults.standard.value(forKey: TipUserDefaults.isShowHomeViewToolTip) == nil {
//            UserDefaults.standard.set(true, forKey: TipUserDefaults.isShowHomeViewToolTip)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
//                guard let self else { return }
//                self.view.addSubview(self.secondToolTip)
//                self.secondToolTip.showToolTipAndDismissAfterDelay(duration: 4) {
//                    self.view.addSubview(self.firstToolTip)
//                    self.firstToolTip.showToolTipAndDismissAfterDelay(duration: 4)
//                }
//            }
//        }
    }
    
    func reloadCollectionView(isHidden: Bool) {
        homeView.collectionView.reloadData()
    }
    
    func unAuthorizedAction() {
        changeViewController(viewController: LoginViewController())
    }
    
    func moveBottomAction(isDuplicated: Bool) {
        if isDuplicated {
            addHeightBottom()
            addClipBottomSheetView.changeTextField(addButton: false,
                                                   border: true,
                                                   error: true,
                                                   clearButton: true)
            addClipBottomSheetView.setupMessage(message: "이미 같은 이름의 클립이 있어요")
        } else {
            minusHeightBottom()
        }
    }
    
    func addClipAction() {
        dismiss(animated: true) {
            self.addClipBottomSheetView.resetTextField()
            self.showToastMessage(width: 157,
                                  status: .check,
                                  message: StringLiterals.ToastMessage.completeAddClip)
        }
    }
        
    func showPopupAction(isShow: Bool) {
        if isShow {
            guard let popupId = viewModel.popupInfoList?.first?.id else { return }
            showLimitationPopup(
                forMainText: "1분 설문조사 참여하고\n스타벅스 기프티콘 받기",
                forSubText: "토스터 사용 피드백을 남겨주시면\n추첨을 통해 기프티콘을 드려요!",
                forImageURL: viewModel.popupInfoList?.first?.image,
                centerButtonTitle: "참여하기",
                bottomButtonTitle: "일주일간 보지 않기",
                centerButtonHandler: {
                    let nextVC = LinkWebViewController()
                    nextVC.hidesBottomBarWhenPushed = true
                    nextVC.setupDataBind(linkURL: self.viewModel.popupInfoList?.first?.linkURL ?? "")
                    self.viewModel.patchEditPopupHiddenAPI(popupId: popupId, hideDate: 1)
                    self.dismiss(animated: false)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                },
                bottomButtonHandler: {
                    self.viewModel.patchEditPopupHiddenAPI(popupId: popupId, hideDate: 7)
                    self.dismiss(animated: false)
                },
                closeButtonHandler: {
                    self.viewModel.patchEditPopupHiddenAPI(popupId: popupId, hideDate: 1)
                    self.dismiss(animated: false)
                }
            )
        }
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: false,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.image(.wordmark),
                                                                rightButton: StringOrImageType.image(.icSettings24),
                                                                rightButtonAction: rightButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func rightButtonTapped() {
        let settingVC = SettingViewController()
        settingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc
    func arrowButtonTapped() {
        let detailClipViewController = DetailClipViewController()
        detailClipViewController.setupCategory(id: 0, name: "전체 클립")
        navigationController?.pushViewController(detailClipViewController, animated: true)
    }
}

// MARK: - AddClipBottomSheetViewDelegate

extension HomeViewController: AddClipBottomSheetViewDelegate {
    func callCheckAPI(text: String) {
        viewModel.getCheckCategoryAPI(categoryTitle: text)
    }
    
    func addHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 219)
    }
    
    func minusHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 198)
    }
    
    func dismissButtonTapped(title: String) {
        viewModel.postAddCategoryAPI(requestBody: title)
    }
}

// MARK: - UserClipCollectionViewCellDelegate

extension HomeViewController: UserClipCollectionViewCellDelegate {
    func addClipCellTapped() {
        let nextVC = AddLinkViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

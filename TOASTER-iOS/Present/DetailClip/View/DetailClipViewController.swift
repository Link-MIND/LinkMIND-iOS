//
//  DetailClipViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class DetailClipViewController: UIViewController {
    
    var indexNumber: Int?
    
    // MARK: - UI Properties
    
    private let viewModel = DetailClipViewModel()
    private let changeClipViewModel = ChangeClipViewModel()
    private let detailClipSegmentedControlView = DetailClipSegmentedControlView()
    private let detailClipEmptyView = DetailClipEmptyView()
    private let detailClipListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var linkOptionBottomSheetView = LinkOptionBottomSheetView(currentClipType: ClipType(categoryId: viewModel.categoryId))
    private lazy var optionBottom = ToasterBottomSheetViewController(bottomType: .gray,
                                                               bottomTitle: "더보기",
                                                               insertView: linkOptionBottomSheetView)
    
    private let editLinkBottomSheetView = EditLinkBottomSheetView()
    private lazy var editLinkBottom = ToasterBottomSheetViewController(bottomType: .white,
                                                                       bottomTitle: "링크 제목 편집",
                                                                       insertView: editLinkBottomSheetView)
    
    private let changeClipBottomSheetView = ChangeClipBottomSheetView()
    private lazy var changeClipBottom = ToasterBottomSheetViewController(bottomType: .gray,
                                                                       bottomTitle: "클립을 선택해 주세요",
                                                                       insertView: changeClipBottomSheetView)
    
    private let changeClipSubject = PassthroughSubject<Void, Never>()
    private let selectedClipSubject = PassthroughSubject<Int, Never>()
    private let completeButtonSubject = PassthroughSubject<Void, Never>()
    
    private var cancelBag = CancelBag()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupRegisterCell()
        setupDelegate()
        setupViewModel()
        bindViewModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        setupAllLink()
    }
}

// MARK: - Extensions

extension DetailClipViewController {
    func setupCategory(id: Int, name: String) {
        viewModel.categoryId = id
        viewModel.categoryName = name
        changeClipViewModel.setupCategory(id)
    }
}

// MARK: - Private Extensions

private extension DetailClipViewController {
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        detailClipListCollectionView.backgroundColor = .toasterBackground
        detailClipEmptyView.isHidden = false
        editLinkBottomSheetView.editLinkBottomSheetViewDelegate = self
        
    }
    
    func setupHierarchy() {
        view.addSubviews(detailClipSegmentedControlView, 
                         detailClipListCollectionView,
                         detailClipEmptyView)
    }
    
    func setupLayout() {
        detailClipSegmentedControlView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        detailClipListCollectionView.snp.makeConstraints {
            $0.top.equalTo(detailClipSegmentedControlView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        detailClipEmptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setupRegisterCell() {
        detailClipListCollectionView.register(DetailClipListCollectionViewCell.self, forCellWithReuseIdentifier: DetailClipListCollectionViewCell.className)
        detailClipListCollectionView.register(ClipCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ClipCollectionHeaderView.className)
    }
    
    func setupDelegate() {
        detailClipListCollectionView.delegate = self
        detailClipListCollectionView.dataSource = self
        detailClipSegmentedControlView.detailClipSegmentedDelegate = self
        viewModel.delegate = self
        changeClipBottomSheetView.delegate = self
    }
    
    func setupViewModel() {
        viewModel.setupDataChangeAction(changeAction: reloadCollectionView,
                                        forUnAuthorizedAction: unAuthorizedAction,
                                        editNameAction: editLinkTitleAction)
    }
    
    func reloadCollectionView(isHidden: Bool) {
        detailClipListCollectionView.reloadData()
        detailClipEmptyView.isHidden = isHidden
    }
    
    func unAuthorizedAction() {
        changeViewController(viewController: LoginViewController())
    }
    
    func editLinkTitleAction() {
        editLinkBottomSheetView.resetTextField()
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: true,
                                                                hasRightButton: false,
                                                                mainTitle: StringOrImageType.string(viewModel.categoryName),
                                                                rightButton: StringOrImageType.string("어쩌구"), rightButtonAction: {})
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func bindViewModels() {
        let input = ChangeClipViewModel.Input(
            changeButtonTap: changeClipSubject.eraseToAnyPublisher(),
            selectedClip: selectedClipSubject.eraseToAnyPublisher(),
            completeButtonTap: completeButtonSubject.eraseToAnyPublisher()
        )
        
        let output = changeClipViewModel.transform(input, cancelBag: cancelBag)
        
        output.clipData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clipData in
                guard let self else { return }
                
                self.dismiss(animated: true) {
                    // 이동할 클립이 2개 이상일 때 (전체클립 제외)
                    if let data = clipData {
                        self.dismiss(animated: true) {
                            self.changeClipBottom.setupSheetPresentation(bottomHeight: self.changeClipViewModel.collectionViewHeight + 180)
                            self.present(self.changeClipBottom, animated: true)
                        }
                        
                        self.changeClipBottomSheetView.dataSourceHandler = { data }
                        self.changeClipBottomSheetView.reloadChangeClipBottom()
                        
                    } else { // 현재 클립이 1개 존재할 때 (전체클립 제외)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.showToastMessage(width: 284,
                                                  status: .warning,
                                                  message: "이동할 클립을 하나 이상 생성해 주세요")
                        }
                    }
                }
            }
            .store(in: cancelBag)
        
        output.isCompleteButtonEnable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.changeClipBottomSheetView.updateCompleteButtonUI(result)
            }
            .store(in: cancelBag)
            
        output.changeCategoryResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                if result == true {
                    let categoryFilter = DetailCategoryFilter.allCases[viewModel.getViewModelProperty(dataType: .segmentIndex) as? Int ?? 0]
                    
                    self.changeClipBottom.dismiss(animated: true) {
                        if self.viewModel.categoryId == 0 {
                            self.viewModel.getDetailAllCategoryAPI(filter: categoryFilter)
                        } else {
                            self.viewModel.getDetailCategoryAPI(categoryID: self.viewModel.categoryId, filter: categoryFilter)
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showToastMessage(width: 152, 
                                              status: .check,
                                              message: "링크 이동 완료")
                    }
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - CollectionView DataSource

extension DetailClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.toastList.toastList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailClipListCollectionViewCell.className, for: indexPath) as? DetailClipListCollectionViewCell else { return UICollectionViewCell() }
        
        cell.buttonAction = { [weak self] in
            self?.buttonTappedAtIndexPath(indexPath)
        }
        
        cell.detailClipListCollectionViewCellDelegate = self
        if viewModel.categoryId == 0 {
            cell.configureCell(forModel: viewModel.toastList, index: indexPath.item, isClipHidden: false)
        } else {
            cell.configureCell(forModel: viewModel.toastList, index: indexPath.item, isClipHidden: true)
        }
        
        // "수정하기" 클릭 시
        linkOptionBottomSheetView.setupEditLinkTitleBottomSheetButtonAction {
            self.dismiss(animated: true) {
                self.editLinkBottom.setupSheetPresentation(bottomHeight: 198)
                self.present(self.editLinkBottom, animated: true)
            }
        }
        
        // "클립이동" 클릭 시
        linkOptionBottomSheetView.setupChangeClipBottomSheetButtonAction {
            self.changeClipSubject.send()
        }
        
        // "삭제" 클릭 시
        linkOptionBottomSheetView.setupDeleteLinkBottomSheetButtonAction {
            self.viewModel.deleteLinkAPI(toastId: self.viewModel.toastId)
            self.dismiss(animated: true) { [weak self] in
                self?.showToastMessage(width: 152, status: .check, message: StringLiterals.ToastMessage.completeDeleteLink)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ClipCollectionHeaderView.className, for: indexPath) as? ClipCollectionHeaderView else { return UICollectionReusableView() }
        headerView.isDetailClipView(isHidden: true)
        if viewModel.segmentIndex == 0 {
            headerView.setupDataBind(title: "전체",
                                     count: viewModel.toastList.toastList.count)
        } else if viewModel.segmentIndex == 1 {
            headerView.setupDataBind(title: "열람",
                                     count: viewModel.toastList.toastList.count)
        } else {
            headerView.setupDataBind(title: "미열람",
                                     count: viewModel.toastList.toastList.count)
        }
        return headerView
    }
    
    func buttonTappedAtIndexPath(_ indexPath: IndexPath) {
        self.editLinkBottomSheetView.setupTextField(message: self.viewModel.toastList.toastList[indexPath.item].title)
    }
}

// MARK: - CollectionView Delegate

extension DetailClipViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexNumber = indexPath.item
        let nextVC = LinkWebViewController()
        nextVC.hidesBottomBarWhenPushed = true
        nextVC.setupDataBind(linkURL: viewModel.toastList.toastList[indexPath.item].url,
                             isRead: viewModel.toastList.toastList[indexPath.item].isRead,
                             id: viewModel.toastList.toastList[indexPath.item].id)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

// MARK: - CollectionView Delegate Flow Layout

extension DetailClipViewController: UICollectionViewDelegateFlowLayout {
    // sizeForItemAt: 각 Cell의 크기를 CGSize 형태로 return
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.convertByWidthRatio(335), height: 98)
    }
    
    // ContentInset: Cell에서 Content 외부에 존재하는 Inset의 크기를 결정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // minimumLineSpacing: Cell 들의 위, 아래 간격 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // referenceSizeForHeaderInSection: 각 섹션의 헤더 뷰 크기를 CGSize 형태로 return
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}

// MARK: - DetailClipSegmented Delegate

extension DetailClipViewController: DetailClipSegmentedDelegate {
    func setupAllLink() {
        viewModel.segmentIndex = 0
        if viewModel.categoryId == 0 {
            viewModel.getDetailAllCategoryAPI(filter: .all)
        } else {
            viewModel.getDetailCategoryAPI(categoryID: viewModel.categoryId, filter: .all)
        }
    }
    
    func setupReadLink() {
        viewModel.segmentIndex = 1
        if viewModel.categoryId == 0 {
            viewModel.getDetailAllCategoryAPI(filter: .read)
        } else {
            viewModel.getDetailCategoryAPI(categoryID: viewModel.categoryId, filter: .read)
        }
    }
    
    func setupNotReadLink() {
        viewModel.segmentIndex = 2
        if viewModel.categoryId == 0 {
            viewModel.getDetailAllCategoryAPI(filter: .unread)
        } else {
            viewModel.getDetailCategoryAPI(categoryID: viewModel.categoryId, filter: .unread)
        }
    }
}

// MARK: - DetailClipListCollectionViewCell Delegate

extension DetailClipViewController: DetailClipListCollectionViewCellDelegate {
    func modifiedButtonTapped(toastId: Int) {
        viewModel.toastId = toastId
        changeClipViewModel.setupToastId(toastId)
        optionBottom.setupSheetPresentation(bottomHeight: viewModel.categoryId == 0 ? 226 : 280)
        present(optionBottom, animated: true)
    }
}

// MARK: - EditLinkBottomSheetView Delegate

extension DetailClipViewController: EditLinkBottomSheetViewDelegate {
    func callCheckAPI(filter: DetailCategoryFilter) {
        viewModel.getDetailAllCategoryAPI(filter: filter)
    }
    
    func addHeightBottom() {
        editLinkBottom.setupSheetHeightChanges(bottomHeight: 219)
    }
    
    func minusHeightBottom() {
        editLinkBottom.setupSheetHeightChanges(bottomHeight: 198)
    }
    
    func dismissButtonTapped(title: String) {
        viewModel.patchEditLinkTitleAPI(toastId: viewModel.toastId,
                                        title: title)
        dismiss(animated: true) { [weak self] in
            self?.showToastMessage(width: 152, status: .check, message: StringLiterals.ToastMessage.completeEditTitle)
        }
    }
}

extension DetailClipViewController: PatchClipDelegate {
    func patchEnd() {
        viewModel.getDetailCategoryAPI(
            categoryID: self.viewModel.categoryId,
            filter: DetailCategoryFilter.allCases[self.viewModel.segmentIndex]
        ) {
            self.detailClipListCollectionView.reloadData()
        }
    }
}

extension DetailClipViewController: ChangeClipBottomSheetViewDelegate {
    func didSelectClip(selectClipId: Int) {
        selectedClipSubject.send(selectClipId)
    }
    
    func completButtonTap() {
        completeButtonSubject.send()
    }
}

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
    
    // MARK: - Data Stream
    
    private let viewModel = DetailClipViewModel()
    private var cancelBag = CancelBag()
    
    private var requestToastList = PassthroughSubject<Bool, Never>()
    
    private let requestClipList = PassthroughSubject<Void, Never>()
    private let selectedClipSubject = PassthroughSubject<Int, Never>()
    private let completeButtonSubject = PassthroughSubject<Void, Never>()
    private let requestDeleteToast = PassthroughSubject<Int, Never>()
    
    private var indexNumber: Int?
    
    // MARK: - UI Properties
    
    private let detailClipSegmentedControlView = DetailClipSegmentedControlView()
    private let detailClipEmptyView = DetailClipEmptyView()
    private let detailClipListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var linkOptionBottomSheetView = LinkOptionBottomSheetView(
        currentClipType: ClipType(categoryId: viewModel.currentCategoryId)
    )
    private lazy var optionBottom = ToasterBottomSheetViewController(
        bottomType: .gray,
        bottomTitle: "더보기",
        insertView: linkOptionBottomSheetView
    )
    
    private let editLinkBottomSheetView = EditLinkBottomSheetView()
    private lazy var editLinkBottom = ToasterBottomSheetViewController(
        bottomType: .white,
        bottomTitle: "링크 제목 편집",
        insertView: editLinkBottomSheetView
    )
    
    private let changeClipBottomSheetView = ChangeClipBottomSheetView()
    private lazy var changeClipBottom = ToasterBottomSheetViewController(
        bottomType: .gray,
        bottomTitle: "클립을 선택해 주세요",
        insertView: changeClipBottomSheetView
    )
    
    private lazy var firstToolTip = ToasterTipView(
        title: "링크를 다른 클립으로\n이동할 수 있어요!",
        type: .right,
        sourceItem: linkOptionBottomSheetView.changeClipButtonLabel
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModels()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupRegisterCell()
        setupDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupToast()
    }
}

// MARK: - Extensions

extension DetailClipViewController {
    func setupCategory(id: Int, name: String) {
        viewModel.setupCategory(id)
        viewModel.setupCategoryName(name)
    }
}

// MARK: - Private Extensions

private extension DetailClipViewController {
    func bindViewModels() {
        let segmentValueChanged = detailClipSegmentedControlView.readSegmentedControlValueChanged
            .asDriver()
        
        let textFieldValueChanged = editLinkBottomSheetView.editClipButtonTap
            .map { _ in
                (
                    self.viewModel.currentToastId,
                    self.editLinkBottomSheetView.editClipTitleTextField.text ?? ""
                )
            }
            .asDriver()
        
        let input = DetailClipViewModel.Input(
            requestToast: requestToastList.asDriver(),
            changeSegmentIndex: segmentValueChanged,
            editToastTitleButtonTap: textFieldValueChanged,
            changeClipButtonTap: requestClipList.asDriver(),
            selectedClip: selectedClipSubject.asDriver(),
            changeClipCompleteButtonTap: completeButtonSubject.asDriver(),
            deleteToastButtonTap: requestDeleteToast.asDriver()
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.loadToToastList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHidden in
                guard let self else { return }
                detailClipListCollectionView.reloadData()
                detailClipEmptyView.isHidden = isHidden
            }.store(in: cancelBag)
        
        output.toastNameChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                setupToast()
                self.editLinkBottomSheetView.resetTextField()
                self.dismiss(animated: true) { [weak self] in
                    self?.showToastMessage(
                        width: 152,
                        status: .check,
                        message: StringLiterals.ToastMessage.completeEditTitle
                    )
                }
            }.store(in: cancelBag)
        
        output.loadToClipData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clipData in
                guard let self else { return }
                
                self.dismiss(animated: true) {
                    // 이동할 클립이 2개 이상일 때 (전체클립 제외)
                    if let data = clipData {
                        self.dismiss(animated: true) {
                            self.changeClipBottom.setupSheetPresentation(bottomHeight: self.viewModel.collectionViewHeight + 180)
                            self.present(self.changeClipBottom, animated: true)
                        }
                        
                        self.changeClipBottomSheetView.dataSourceHandler = { data }
                        self.changeClipBottomSheetView.reloadChangeClipBottom()
                        
                    } else { // 현재 클립이 1개 존재할 때 (전체클립 제외)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.showToastMessage(
                                width: 284,
                                status: .warning,
                                message: "이동할 클립을 하나 이상 생성해 주세요"
                            )
                        }
                    }
                }
            }.store(in: cancelBag)
        
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
                    self.changeClipBottom.dismiss(animated: true) {
                        self.setupToast()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showToastMessage(
                            width: 152,
                            status: .check,
                            message: "링크 이동 완료"
                        )
                    }
                }
            }
            .store(in: cancelBag)
        
        output.deleteToastComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                setupToast()
                self.dismiss(animated: true) { [weak self] in
                    self?.showToastMessage(
                        width: 152,
                        status: .check,
                        message: StringLiterals.ToastMessage.completeDeleteLink
                    )
                }
            }.store(in: cancelBag)
    }
    
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        detailClipListCollectionView.backgroundColor = .toasterBackground
        detailClipEmptyView.isHidden = false
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
        changeClipBottomSheetView.delegate = self
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(
            hasBackButton: true,
            hasRightButton: false,
            mainTitle: StringOrImageType.string(viewModel.currentCategoryName),
            rightButton: StringOrImageType.string("어쩌구"), rightButtonAction: {}
        )
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func setupToast() {
        if viewModel.currentCategoryId == 0 {
            requestToastList.send(true)
        } else {
            requestToastList.send(false)
        }
    }
    
    func setupToolTip() {
        if UserDefaults.standard.value(forKey: TipUserDefaults.isShowDetailClipViewToolTip) == nil {
            UserDefaults.standard.set(true, forKey: TipUserDefaults.isShowDetailClipViewToolTip)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.linkOptionBottomSheetView.addSubview(self?.firstToolTip ?? UIView())
                self?.firstToolTip.showToolTipAndDismissAfterDelay(duration: 4)
            }
        }
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
        if viewModel.currentCategoryId == 0 {
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
            self.requestClipList.send()
        }
        
        // "삭제" 클릭 시
        linkOptionBottomSheetView.setupDeleteLinkBottomSheetButtonAction {
            self.requestDeleteToast.send(self.viewModel.currentToastId)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ClipCollectionHeaderView.className, for: indexPath) as? ClipCollectionHeaderView else { return UICollectionReusableView() }
        headerView.isDetailClipView(isHidden: true)
        if viewModel.segmentIndex == 0 {
            headerView.setupDataBind(
                title: "전체",
                count: viewModel.toastList.toastList.count
            )
        } else if viewModel.segmentIndex == 1 {
            headerView.setupDataBind(
                title: "열람",
                count: viewModel.toastList.toastList.count
            )
        } else {
            headerView.setupDataBind(
                title: "미열람",
                count: viewModel.toastList.toastList.count
            )
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
        nextVC.setupDataBind(
            linkURL: viewModel.toastList.toastList[indexPath.item].url,
            isRead: viewModel.toastList.toastList[indexPath.item].isRead,
            id: viewModel.toastList.toastList[indexPath.item].id
        )
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

// MARK: - DetailClipListCollectionViewCell Delegate

extension DetailClipViewController: DetailClipListCollectionViewCellDelegate {
    func modifiedButtonTapped(toastId: Int) {
        viewModel.setupToastId(toastId)
        optionBottom.setupSheetPresentation(bottomHeight: viewModel.currentCategoryId == 0 ? 226 : 280)
        present(optionBottom, animated: true)
        if viewModel.currentCategoryId != 0 { setupToolTip() }
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

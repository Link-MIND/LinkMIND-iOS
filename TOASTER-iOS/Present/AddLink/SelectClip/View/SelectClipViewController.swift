//
//  SelectClipViewController.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/15.
//

import Combine
import UIKit

import SnapKit
import Then

final class SelectClipViewController: UIViewController {
    
    // MARK: - Properties
    
    var linkURL = String()
    private var categoryID: Int?
    weak var delegate: SaveLinkButtonDelegate?
    
    // MARK: - UI Properties
    
    private let viewModel = SelectClipViewModel()
    private let cancelBag = CancelBag()
    private var requestClipList = PassthroughSubject<Void, Never>()
    private var requestSaveLink = PassthroughSubject<Void, Never>()
    
    private let clipSelectCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let completeButton: UIButton = UIButton()
    private let addClipBottomSheetView = AddClipBottomSheetView()
    private lazy var addClipBottom = ToasterBottomSheetViewController(bottomType: .white,
                                                                      bottomTitle: "클립 추가",
                                                                      insertView: addClipBottomSheetView)
    
    private var selectedClipTapped: RemindClipModel? {
        didSet {
            completeButton.backgroundColor = .toasterBlack
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModels()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        requestClipList.send()
    }
}

// MARK: - Private Extension

private extension SelectClipViewController {
    func bindViewModels() {
        let textFieldValueChanged = addClipBottomSheetView.textFieldValueChanged
            .compactMap { ($0.object as? UITextField)?.text }
            .asDriver()
        
        let addClipButtonTapped = addClipBottomSheetView.addClipButtonTap
            .compactMap { _ in self.addClipBottomSheetView.addClipTextField.text }
            .asDriver()
        
        let completeButtonTapped = self.requestSaveLink
            .map { (self.linkURL, self.categoryID) }
            .asDriver()
        
        let input = SelectClipViewModel.Input(
            requestClipList: requestClipList.asDriver(),
            clipNameChanged: textFieldValueChanged,
            addClipButtonTapped: addClipButtonTapped,
            completeButtonTapped: completeButtonTapped
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.needToReload
            .sink { [weak self] _ in
                self?.clipSelectCollectionView.reloadData()
            }.store(in: cancelBag)
        
        output.addClipResult
            .sink { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.addClipBottomSheetView.resetTextField()
                    self?.showToastMessage(
                        width: 157,
                        status: .check,
                        message: StringLiterals.ToastMessage.completeAddClip
                    )
                    self?.requestClipList.send()
                }
            }.store(in: cancelBag)
        
        output.duplicateClipName
            .sink { [weak self] isDuplicate in
                if isDuplicate {
                    self?.addHeightBottom()
                    self?.addClipBottomSheetView.changeTextField(
                        addButton: false,
                        border: true,
                        error: true,
                        clearButton: true
                    )
                    self?.addClipBottomSheetView.setupMessage(message: "이미 같은 이름의 클립이 있어요")
                } else {
                    self?.minusHeightBottom()
                }
            }.store(in: cancelBag)
        
        output.saveLinkResult
            .sink { [weak self] isSuccess in
                self?.navigationController?.popToRootViewController(animated: true)
                
                let width: CGFloat = isSuccess ? 157 : 200
                let status: ToastStatus = isSuccess ? .check : .warning
                let message = isSuccess ? "링크 저장 완료!" : "링크 저장에 실패했어요!"
                self?.navigationController?.showToastMessage(width: width, status: status, message: message)
                
                if isSuccess { self?.delegate?.saveLinkButtonTapped() }
            }.store(in: cancelBag)
    }
    
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        
        clipSelectCollectionView.do {
            $0.register(RemindSelectClipCollectionViewCell.self,
                        forCellWithReuseIdentifier: RemindSelectClipCollectionViewCell.className)
            
            $0.register(SelectClipHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: SelectClipHeaderView.className)
            
            $0.backgroundColor = .toasterBackground
        }
        
        completeButton.do {
            $0.makeRounded(radius: 12)
            $0.backgroundColor = .black850
            $0.setTitle(StringLiterals.Button.complete, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.titleLabel?.font = .suitBold(size: 16)
            $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(clipSelectCollectionView,
                         completeButton)
    }
    
    func setupLayout() {
        clipSelectCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(completeButton.snp.top).offset(-10)
        }
        
        completeButton.snp.makeConstraints {
            $0.height.equalTo(62)
            $0.bottom.equalToSuperview().inset(34)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    func setupDelegate() {
        clipSelectCollectionView.delegate = self
        clipSelectCollectionView.dataSource = self
        addClipBottomSheetView.addClipBottomSheetViewDelegate = self
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: true,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.string("링크 저장"),
                                                                rightButton: StringOrImageType.image(.icClose24),
                                                                rightButtonAction: closeButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func closeButtonTapped() {
        showPopup(forMainText: "링크 저장을 취소하시겠어요?",
                  forSubText: "저장 중인 링크가 사라져요",
                  forLeftButtonTitle: StringLiterals.Button.close,
                  forRightButtonTitle: StringLiterals.Button.delete,
                  forRightButtonHandler: rightButtonTapped)
    }
    
    func rightButtonTapped() {
        dismiss(animated: false)
        delegate?.cancleLinkButtonTapped()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func completeButtonTapped() {
        completeButton.loadingButtonTapped(
            loadingTitle: "저장 중...",
            loadingAnimationSize: 16,
            task: { [weak self] _ in
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    self?.requestSaveLink.send()
                }
            }
        )
    }
}

// MARK: - UICollectionViewDelegate

extension SelectClipViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item != 0 {
            if let cell = collectionView.cellForItem(at: .SubSequence(item: 0, section: 0)) {
                cell.isSelected = false
            }
        }
        categoryID = viewModel.selectedClip[indexPath.item].id
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            cell.isSelected = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SelectClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedClip.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemindSelectClipCollectionViewCell.className, for: indexPath) as? RemindSelectClipCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0 {
            cell.configureCell(forModel: viewModel.selectedClip[indexPath.item], icon: .icAllClip24)
        } else {
            cell.configureCell(forModel: viewModel.selectedClip[indexPath.item], icon: .icClip24Black)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                   withReuseIdentifier: SelectClipHeaderView.className,
                                                                                   for: indexPath) as? SelectClipHeaderView else { return UICollectionReusableView() }
            headerView.selectClipHeaderViewDelegate = self
            headerView.setupView()
            headerView.bindData(count: viewModel.selectedClip.count)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    // Header 크기 지정
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 335, height: 68)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SelectClipViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.convertByWidthRatio(335), height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension SelectClipViewController: SelectClipHeaderViewlDelegate {
    func addClipCellTapped() {
        if viewModel.selectedClip.count > 15 {
            showToastMessage(width: 243,
                             status: .warning,
                             message: StringLiterals.ToastMessage.noticeMaxClip)
        } else {
            addClipBottom.setupSheetPresentation(bottomHeight: 198)
            self.present(addClipBottom, animated: true)
        }
    }
}

extension SelectClipViewController: AddClipBottomSheetViewDelegate {
    func addHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 219)
    }
    
    func minusHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 198)
    }
}

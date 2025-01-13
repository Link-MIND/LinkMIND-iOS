//
//  ClipViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class ClipViewController: UIViewController {
    
    // MARK: - View Controllable
    
    var onEditClipSelected: ((ClipModel) -> Void)?
    var onClipItemSelected: ((Int, String) -> Void)?
    
    // MARK: - UI Properties
    
    private let viewModel: ClipViewModel
    private let cancelBag = CancelBag()
    
    private var requestClipList = PassthroughSubject<Void, Never>()
    
    private let clipEmptyView = ClipEmptyView()
    private let addClipBottomSheetView = AddClipBottomSheetView()
    private lazy var addClipBottom = ToasterBottomSheetViewController(
        bottomType: .white,
        bottomTitle: "클립 추가",
        insertView: addClipBottomSheetView
    )
    private let clipListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Life Cycle
    
    init(viewModel: ClipViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        requestClipList.send()
    }
}

// MARK: - Private Extensions

private extension ClipViewController {
    func bindViewModels() {
        let textFieldValueChanged = addClipBottomSheetView.textFieldValueChanged
            .compactMap { ($0.object as? UITextField)?.text }
            .asDriver()
        
        let addClipButtonTapped = addClipBottomSheetView.addClipButtonTap
            .compactMap { _ in self.addClipBottomSheetView.addClipTextField.text }
            .asDriver()
        
        let input = ClipViewModel.Input(
            requestClipList: requestClipList.asDriver(),
            clipNameChanged: textFieldValueChanged,
            addClipButtonTapped: addClipButtonTapped
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.needToReload
            .sink { [weak self] _ in
                self?.clipListCollectionView.reloadData()
                self?.clipEmptyView.isHidden = self?.viewModel.clipList.clips.count ?? 0 != 0
            }.store(in: cancelBag)
        
        output.addClipResult
            .sink { [weak self] _ in
                self?.requestClipList.send()
                self?.dismiss(animated: true) {
                    self?.addClipBottomSheetView.resetTextField()
                }
                self?.showToastMessage(width: 157, status: .check, message: StringLiterals.ToastMessage.completeAddClip)
            }.store(in: cancelBag)
        
        output.duplicateClipName
            .sink { [weak self] isDuplicate in
                if isDuplicate {
                    self?.addHeightBottom()
                    self?.addClipBottomSheetView.changeTextField(addButton: false, border: true, error: true, clearButton: true)
                    self?.addClipBottomSheetView.setupMessage(message: "이미 같은 이름의 클립이 있어요")
                } else {
                    self?.minusHeightBottom()
                }
            }.store(in: cancelBag)
    }
    
    func setupStyle() {
        clipListCollectionView.backgroundColor = .toasterBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(clipListCollectionView, clipEmptyView)
    }
    
    func setupLayout() {
        clipListCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        clipEmptyView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(self.view.convertByHeightRatio(280))
        }
    }
    
    func setupRegisterCell() {
        clipListCollectionView.register(ClipListCollectionViewCell.self, forCellWithReuseIdentifier: ClipListCollectionViewCell.className)
        clipListCollectionView.register(ClipCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ClipCollectionHeaderView.className)
    }
    
    func setupDelegate() {
        clipListCollectionView.delegate = self
        clipListCollectionView.dataSource = self
        addClipBottomSheetView.addClipBottomSheetViewDelegate = self
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(
            hasBackButton: false,
            hasRightButton: true,
            mainTitle: StringOrImageType.string(StringLiterals.Tabbar.clip),
            rightButton: StringOrImageType.string("편집"),
            rightButtonAction: editButtonTapped
        )
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func editButtonTapped() {
        onEditClipSelected?(viewModel.clipList)
    }
}

// MARK: - CollectionView Delegate

extension ClipViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = indexPath.item == 0 ? 0 : viewModel.clipList.clips[indexPath.item - 1].id
        let title = indexPath.item == 0 ? "전체 클립" : viewModel.clipList.clips[indexPath.item - 1].title
        onClipItemSelected?(id, title)
    }
}

// MARK: - CollectionView DataSource

extension ClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.clipList.clips.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClipListCollectionViewCell.className, for: indexPath) as? ClipListCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0 {
            cell.configureCell(forModel: viewModel.clipList, icon: .icAllClip24.withTintColor(.black900), name: "전체 클립")
        } else {
            cell.configureCell(forModel: viewModel.clipList, icon: .icClipFull24.withTintColor(.black900), index: indexPath.item - 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ClipCollectionHeaderView.className, for: indexPath) as? ClipCollectionHeaderView else { return UICollectionReusableView() }
            headerView.isDetailClipView(isHidden: false)
            headerView.setupDataBind(title: "전체",
                                     count: viewModel.clipList.clips.count + 1)
            headerView.clipCollectionHeaderViewDelegate = self
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - CollectionView Delegate Flow Layout

extension ClipViewController: UICollectionViewDelegateFlowLayout {
    // sizeForItemAt: 각 Cell의 크기를 CGSize 형태로 return
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.convertByWidthRatio(335), height: 52)
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
        return CGSize(width: collectionView.frame.width, height: 33)
    }
}

extension ClipViewController: ClipCollectionHeaderViewDelegate {
    func addClipButtonTapped() {
        if viewModel.clipList.clips.count >= 15 {
            showToastMessage(width: 243, status: .warning, message: StringLiterals.ToastMessage.noticeMaxClip)
        } else {
            addClipBottom.setupSheetPresentation(bottomHeight: 198)
            present(addClipBottom, animated: true)
        }
    }
}

extension ClipViewController: AddClipBottomSheetViewDelegate {
    func addHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 219)
    }
    
    func minusHeightBottom() {
        addClipBottom.setupSheetHeightChanges(bottomHeight: 198)
    }
}

//
//  EditClipViewController.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/11/24.
//

import UIKit

import SnapKit
import Then

final class EditClipViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private let viewModel: EditClipViewModel!
    private let editClipNoticeView = EditClipNoticeView()
    private let editClipCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let editClipBottomSheetView = AddClipBottomSheetView()
    private lazy var editClipBottom = ToasterBottomSheetViewController(
        bottomType: .white,
        bottomTitle: "클립 이름 수정",
        insertView: editClipBottomSheetView
    )
    
    // MARK: - Life Cycle
    
    init(viewModel: EditClipViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

// MARK: - Extensions

extension EditClipViewController {
    func setupDataBind(clipModel: ClipModel) {
        viewModel.clipList = clipModel
    }
}

// MARK: - Private Extensions

private extension EditClipViewController {
    func setupStyle() {
        editClipCollectionView.do {
            $0.backgroundColor = .toasterBackground
            $0.register(EditClipCollectionViewCell.self, forCellWithReuseIdentifier: EditClipCollectionViewCell.className)
            $0.dragInteractionEnabled = true
        }
        
        editClipBottomSheetView.do {
            $0.addClipBottomSheetViewDelegate = self
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(editClipNoticeView, editClipCollectionView)
    }
    
    func setupLayout() {
        editClipNoticeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        editClipCollectionView.snp.makeConstraints {
            $0.top.equalTo(editClipNoticeView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: true, hasRightButton: false, mainTitle: StringOrImageType.string("CLIP 편집"), rightButton: StringOrImageType.string(""), rightButtonAction: {})
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func setupDelegate() {
        editClipCollectionView.delegate = self
        editClipCollectionView.dataSource = self
        editClipCollectionView.dragDelegate = self
        editClipCollectionView.dropDelegate = self
    }
    
    func setupViewModel() {
        viewModel.setupDataChangeAction(changeAction: reloadCollectionView,
                                        moveAction: moveBottomAction,
                                        deleteAction: deleteClipAction,
                                        editNameAction: editClipNameAction,
                                        forUnAuthorizedAction: unAuthorizedAction)
    }
    
    func reloadCollectionView() {
        editClipCollectionView.reloadData()
    }
    
    func moveBottomAction(isDuplicated: Bool) {
        if isDuplicated {
            addHeightBottom()
            editClipBottomSheetView.changeTextField(addButton: false, border: true, error: true, clearButton: true)
            editClipBottomSheetView.setupMessage(message: "이미 같은 이름의 클립이 있어요")
        } else {
            minusHeightBottom()
        }
    }
    
    func deleteClipAction() {
        dismiss(animated: false) {
            self.showToastMessage(width: 152,
                                  status: .check,
                                  message: StringLiterals.ToastMessage.completeDeleteClip)
        }
    }
    
    func editClipNameAction() {
        showToastMessage(width: 157, status: .check, message: StringLiterals.ToastMessage.completeEditClip)
        editClipBottomSheetView.resetTextField()
    }
    
    func unAuthorizedAction() {
        changeViewController(viewController: LoginViewController())
    }
    
    func popupDeleteButtonTapped(categoryID: Int, index: Int) {
        viewModel.deleteCategoryAPI(deleteCategoryDto: categoryID)
    }
}

// MARK: - CollectionView DataSource

extension EditClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.clipList.clips.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditClipCollectionViewCell.className, for: indexPath) as? EditClipCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.row == 0 {
            cell.configureCell(forModel: AllClipModel(id: 0,
                                                      title: "전체 클립",
                                                      toastCount: 0),
                               icon: .icPin24,
                               isFirst: true)
        } else {
            cell.configureCell(forModel: viewModel.clipList.clips[indexPath.item - 1],
                               icon: .icDelete28,
                               isFirst: false)
            cell.leadingButtonTapped {
                self.showPopup(forMainText: "‘\(self.viewModel.clipList.clips[indexPath.item - 1].title)’ 클립을 삭제하시겠어요?",
                               forSubText: "지금까지 저장된 모든 링크가 사라져요",
                               forLeftButtonTitle: StringLiterals.Button.close,
                               forRightButtonTitle: StringLiterals.Button.delete,
                               forRightButtonHandler: { self.popupDeleteButtonTapped(categoryID: self.viewModel.clipList.clips[indexPath.item - 1].id,
                                                                                     index: indexPath.item - 1) })
            }
            cell.changeTitleButtonTapped {
                self.viewModel.cellIndex = indexPath.item - 1
                self.editClipBottom.setupSheetPresentation(bottomHeight: 198)
                self.present(self.editClipBottom, animated: true)
                self.editClipBottomSheetView.setupTextField(message: self.viewModel.clipList.clips[indexPath.item - 1].title)
            }
        }
        return cell
    }
}

// MARK: - CollectionView Delegate

extension EditClipViewController: UICollectionViewDelegate {}

// MARK: - CollectionView Delegate Flow Layout

extension EditClipViewController: UICollectionViewDelegateFlowLayout {
    // sizeForItemAt: 각 Cell의 크기를 CGSize 형태로 return
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.convertByWidthRatio(335), height: 54)
    }
    
    // ContentInset: Cell에서 Content 외부에 존재하는 Inset의 크기를 결정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // minimumLineSpacing: Cell 들의 위, 아래 간격 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - CollectionView Drag Delegate

extension EditClipViewController: UICollectionViewDragDelegate {
    /// 처음 드래그가 시작될 때 호출되는 함수
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return indexPath.item != 0 ? [UIDragItem(itemProvider: NSItemProvider())] : []
    }
}

// MARK: - CollectionView Drop Delegate

extension EditClipViewController: UICollectionViewDropDelegate {
    /// 드래그 하는 동안 호출되는 함수
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else { return UICollectionViewDropProposal(operation: .forbidden) }
        if destinationIndexPath?.item != 0 {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    /// 드래그가 끝나고 드랍할 때 호출되는 함수
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let item = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: item - 1, section: 0)
        }
        // 0번째 인덱스 드랍이 아닌 경우, 배열과 컬뷰 아이템 삭제, 삽입, reload까지 진행
        if destinationIndexPath.item != 0 {
            guard let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath else { return }
            collectionView.performBatchUpdates {
                let sourceItem = viewModel.clipList.clips.remove(at: sourceIndexPath.item - 1)
                viewModel.clipList.clips.insert(sourceItem, at: destinationIndexPath.item - 1)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                self.viewModel.patchEditPriorityCategoryAPI(
                    requestBody: ClipPriorityEditModel(
                        id: self.viewModel.clipList.clips[destinationIndexPath.item - 1].id,
                        priority: destinationIndexPath.item - 1
                    )
                )
            }
        }
    }
}

// MARK: - AddClipBottomSheetView Delegate

extension EditClipViewController: AddClipBottomSheetViewDelegate {
    func callCheckAPI(text: String) {
        viewModel.getCheckCategoryAPI(categoryTitle: text)
    }
    
    func addHeightBottom() {
        editClipBottom.setupSheetHeightChanges(bottomHeight: 219)
    }
    
    func minusHeightBottom() {
        editClipBottom.setupSheetHeightChanges(bottomHeight: 198)
    }
    
    func dismissButtonTapped(title: String) {
        dismiss(animated: true)
        viewModel.patchEditaNameCategoryAPI(
            requestBody: ClipNameEditModel(id: viewModel.clipList.clips[viewModel.cellIndex].id,
                                           title: title)
        )
    }
}

//
//  RemindViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import UIKit

import SnapKit
import Then

enum RemindViewType {
    case deviceOnAppOnExistData
    case deviceOnAppOnNoneData
    case deviceOffAppOn
    case deviceOnAppOff
    case deviceOffAppOff
}

final class RemindViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: RemindViewModel!
    
    private var selectedTimerID: Int?
    private var viewType: RemindViewType?
    
    // MARK: - UI Properties
    
    private let timerCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let editAlarmButton: AlarmOffStateButton = AlarmOffStateButton()
    private let emptyTimerView: RemindTimerEmptyView = RemindTimerEmptyView()
    private let offAlarmView: RemindAlarmOffView = RemindAlarmOffView(frame: .zero,
                                                                      type: .normal)
    
    // MARK: - Life Cycle
    
    init(viewModel: RemindViewModel) {
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
        setupViewWithAlarm(forType: .deviceOnAppOnExistData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        viewModel.fetchAlarmCheck()
        viewModel.fetchTimerData()
    }
}

// MARK: - Private Extensions

private extension RemindViewController {
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        
        timerCollectionView.do {
            $0.backgroundColor = .toasterBackground
            
            $0.register(CompleteTimerCollectionViewCell.self, forCellWithReuseIdentifier: CompleteTimerCollectionViewCell.className)
            $0.register(CompleteTimerEmptyCollectionViewCell.self, forCellWithReuseIdentifier: CompleteTimerEmptyCollectionViewCell.className)
            $0.register(WaitTimerCollectionViewCell.self, forCellWithReuseIdentifier: WaitTimerCollectionViewCell.className)
            
            $0.register(RemindCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RemindCollectionHeaderView.className)
            $0.register(RemindCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RemindCollectionFooterView.className)
        }
        
        editAlarmButton.do {
            $0.addTarget(self, action: #selector(editAlarmButtonTapped), for: .touchUpInside)
        }
        
        emptyTimerView.setupButtonAction(action: plusButtonTapped)
    }
    
    func setupHierarchy() {
        view.addSubviews(timerCollectionView,
                         editAlarmButton,
                         emptyTimerView,
                         offAlarmView)
    }
    
    func setupLayout() {
        timerCollectionView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        editAlarmButton.snp.makeConstraints {
            $0.height.equalTo(90)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        [emptyTimerView, offAlarmView].forEach {
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
    }
    
    func setupDelegate() {
        timerCollectionView.delegate = self
        timerCollectionView.dataSource = self
    }
    
    func setupViewModel() {
        viewModel.fetchAlarmCheck()
        viewModel.setupDataChangeAction(changeAction: reloadCollectionViewWithView,
                                        normalAction: setupAlarmBottomSheet, 
                                        forDeleteTimerAction: deleteAction,
                                        forUnAuthorizedAction: unAuthorizedAction)
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: false,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.string("TIMER"),
                                                                rightButton: StringOrImageType.image(.icPlus24),
                                                                rightButtonAction: plusButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    /// viewType에 따라 뷰를 업데이트해주는 함수
    func setupViewWithAlarm(forType: RemindViewType) {
        switch forType {
        case .deviceOnAppOnExistData:
            setupViewHidden(collectionViewHidden: false,
                            buttonHidden: true,
                            emptyViewHidden: true,
                            nonAlarmViewHidden: true)
        case .deviceOnAppOnNoneData:
            setupViewHidden(collectionViewHidden: true,
                            buttonHidden: true,
                            emptyViewHidden: false,
                            nonAlarmViewHidden: true)
            emptyTimerView.setupButtonEnable(forEnable: true)
        case .deviceOffAppOn:
            setupViewHidden(collectionViewHidden: true,
                            buttonHidden: true,
                            emptyViewHidden: true,
                            nonAlarmViewHidden: false)
        case .deviceOnAppOff:
            setupViewHidden(collectionViewHidden: true,
                            buttonHidden: false,
                            emptyViewHidden: false,
                            nonAlarmViewHidden: true)
            emptyTimerView.setupButtonEnable(forEnable: false)
        case .deviceOffAppOff:
            setupViewHidden(collectionViewHidden: true,
                            buttonHidden: false,
                            emptyViewHidden: true,
                            nonAlarmViewHidden: false)
        }
    }
    
    func setupViewHidden(collectionViewHidden: Bool,
                         buttonHidden: Bool,
                         emptyViewHidden: Bool,
                         nonAlarmViewHidden: Bool) {
        timerCollectionView.isHidden = collectionViewHidden
        editAlarmButton.isHidden = buttonHidden
        emptyTimerView.isHidden = emptyViewHidden
        offAlarmView.isHidden = nonAlarmViewHidden
    }
    
    func setupEditBottomSheet(forID: Int?) {
        let editView = RemindTimerEditBottomSheetView()
        editView.setupEditView(forDelegate: self,
                               forID: forID)
        
        let exampleBottom = ToasterBottomSheetViewController(bottomType: .gray, 
                                                             bottomTitle: "수정하기",
                                                             insertView: editView)
        exampleBottom.setupSheetPresentation(bottomHeight: 226)
        present(exampleBottom, animated: true)
    }
    
    func setupAlarmBottomSheet() {
        let alarmView = RemindAlarmOffBottomSheetView()
        alarmView.setupDelegate(forDelegate: self)
        
        let exampleBottom = ToasterBottomSheetViewController(bottomType: .white, 
                                                             bottomTitle: "알림이 꺼져있어요!",
                                                             insertView: alarmView)
        exampleBottom.setupSheetPresentation(bottomHeight: 427)
        present(exampleBottom, animated: true)
    }
    
    func reloadCollectionViewWithView(forType: RemindViewType) {
        timerCollectionView.reloadData()
        setupViewWithAlarm(forType: forType)
        viewType = forType
    }
    
    func unAuthorizedAction() {
        self.changeViewController(viewController: LoginViewController())
    }
    
    func deleteAction() {
        dismiss(animated: false)
        self.showToastMessage(width: 165, status: .check, message: StringLiterals.ToastMessage.completeDeleteTimer)
    }
    
    func plusButtonTapped() {
        if viewType != nil {
            switch viewType {
            case .deviceOnAppOff: break
            default:
                let clipAddViewController = ViewControllerFactory.shared.makeRemindSelectClipVC()
                clipAddViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(clipAddViewController, animated: true)
            }
        }
    }
    
    func deleteButtonTapped() {
        guard let selectedTimerID else { return }
        viewModel.deleteTimerData(timerID: selectedTimerID)
    }
    
    func toggleAction(forTimerID: Int?) {
        guard let forTimerID else { return }
        viewModel.patchTimerData(timerID: forTimerID)
    }
    
    @objc func editAlarmButtonTapped() {
        let settingVC = ViewControllerFactory.shared.makeSettingVC()
        settingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingVC, animated: true)
        tabBarController?.selectedIndex = 0
    }
}

// MARK: - RemindAlarmOffBottomSheetViewDelegate

extension RemindViewController: RemindAlarmOffBottomSheetViewDelegate {
    func alarmButtonTapped() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                self.dismiss(animated: false)
                self.viewModel.fetchAlarmCheck()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RemindViewController: RemindEditViewDelegate {
    func editTimer(forID: Int?) {
        selectedTimerID = forID
        dismiss(animated: true)
        if let forID {
            let editViewController = ViewControllerFactory.shared.makeRemindTimerAddVC()
            editViewController.configureView(forTimerID: forID)
            navigationController?.pushViewController(editViewController, animated: true)
        }
    }
    
    func deleteTimer(forID: Int?) {
        selectedTimerID = forID
        dismiss(animated: true)
        showPopup(forMainText: "타이머를 삭제하시겠어요?",
                  forSubText: "더 이상 해당 클립의 리마인드를 \n받을 수 없어요",
                  forLeftButtonTitle: StringLiterals.Button.cancel,
                  forRightButtonTitle: StringLiterals.Button.delete,
                  forRightButtonHandler: deleteButtonTapped)
    }
}

// MARK: - UICollectionViewDelegate

extension RemindViewController: UICollectionViewDelegate { 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clipViewController = ViewControllerFactory.shared.makeDetailClipVC()
        switch indexPath.section {
        case 0:
            let data = viewModel.timerData.completeTimerModelList[indexPath.item]
            clipViewController.setupCategory(id: data.clipID,
                                             name: data.clipName)
        case 1:
            let data = viewModel.timerData.waitTimerModelList[indexPath.item]
            clipViewController.setupCategory(id: data.clipID,
                                             name: data.clipName)
        default: break
        }
        navigationController?.pushViewController(clipViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension RemindViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return max(viewModel.timerData.completeTimerModelList.count, 1)
        case 1: return viewModel.timerData.waitTimerModelList.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if viewModel.timerData.completeTimerModelList.count == 0 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompleteTimerEmptyCollectionViewCell.className, for: indexPath) as? CompleteTimerEmptyCollectionViewCell else { return UICollectionViewCell() }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompleteTimerCollectionViewCell.className, for: indexPath) as? CompleteTimerCollectionViewCell else { return UICollectionViewCell() }
                cell.configureCell(forModel: viewModel.timerData.completeTimerModelList[indexPath.item])
                return cell
            }
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WaitTimerCollectionViewCell.className, for: indexPath) as? WaitTimerCollectionViewCell else { return UICollectionViewCell() }
            cell.configureCell(forModel: viewModel.timerData.waitTimerModelList[indexPath.item],
                               forEditAction: setupEditBottomSheet,
                               forToggleAction: toggleAction)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            // header
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RemindCollectionHeaderView.className, for: indexPath) as? RemindCollectionHeaderView else { return UICollectionReusableView() }
            switch indexPath.section {
            case 0:
                header.configureHeader(forTitle: "완료된 타이머",
                                       forTimerCount: viewModel.timerData.completeTimerModelList.count)
            case 1:
                header.configureHeader(forTitle: "타이머 대기 중..")
            default: break
            }
            return header
            // footer
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RemindCollectionFooterView.className, for: indexPath) as? RemindCollectionFooterView else { return UICollectionReusableView() }
            return footer
        default: return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: view.getDeviceWidth(), height: 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 0: return CGSize(width: view.getDeviceWidth(), height: 28)
        default: return .zero
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RemindViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0: return CGSize(width: collectionView.convertByWidthRatio(335), height: 100)
        case 1: return CGSize(width: collectionView.convertByWidthRatio(335), height: 109)
        default: return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 20, bottom: 24, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0: return 18
        case 1: return 12
        default: return 0
        }
    }
}

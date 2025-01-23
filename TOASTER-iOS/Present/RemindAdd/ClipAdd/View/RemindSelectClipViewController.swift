//
//  RemindSelectClipViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 1/11/24.
//

import UIKit

import SnapKit
import Then

final class RemindSelectClipViewController: UIViewController {
    
    // MARK: - View Controllable
    
    var onEditTimerSelected: ((RemindClipModel?) -> Void)?
    var onPopToRoot: (() -> Void)?

    // MARK: - Properties
    
    private let viewModel: RemindSelectClipViewModel!
    
    private var selectedClip: RemindClipModel? {
        didSet {
            nextButton.backgroundColor = .toasterBlack
        }
    }
    
    // MARK: - UI Properties
    
    private let clipSelectCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let nextButton: UIButton = UIButton()
    
    // MARK: - Life Cycle
    
    init(viewModel: RemindSelectClipViewModel) {
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
        viewModel.fetchClipData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
}

// MARK: - Private Extension

private extension RemindSelectClipViewController {
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        
        clipSelectCollectionView.do {
            $0.register(RemindSelectClipCollectionViewCell.self, forCellWithReuseIdentifier: RemindSelectClipCollectionViewCell.className)
            $0.backgroundColor = .toasterBackground
        }
        
        nextButton.do {
            $0.makeRounded(radius: 12)
            $0.backgroundColor = .gray200
            $0.setTitle(StringLiterals.Button.next, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.titleLabel?.font = .suitBold(size: 16)
            $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(clipSelectCollectionView, nextButton)
    }
    
    func setupLayout() {
        clipSelectCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-10)
        }
        
        nextButton.snp.makeConstraints {
            $0.height.equalTo(62)
            $0.bottom.equalToSuperview().inset(34)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    func setupDelegate() {
        clipSelectCollectionView.delegate = self
        clipSelectCollectionView.dataSource = self
    }
    
    func setupViewModel() {
        viewModel.setupDataChangeAction {
            self.clipSelectCollectionView.reloadData()
        }
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: false,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.string("알림받을 클립 선택"),
                                                                rightButton: StringOrImageType.image(.icClose24),
                                                                rightButtonAction: closeButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func closeButtonTapped() {
        showPopup(forMainText: "타이머 설정을 취소할까요?",
                  forSubText: "지금까지 진행한 타이머 설정이\n사라져요",
                  forLeftButtonTitle: StringLiterals.Button.close,
                  forRightButtonTitle: StringLiterals.Button.cancel,
                  forRightButtonHandler: makeTimerCancel)
    }
        
    func makeTimerCancel() {
        onPopToRoot?()
    }
    
    @objc func nextButtonTapped() {
        onEditTimerSelected?(selectedClip)
    }
}

// MARK: - UICollectionViewDelegate

extension RemindSelectClipViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedClip = viewModel.clipData[indexPath.item]
    }
}

// MARK: - UICollectionViewDataSource

extension RemindSelectClipViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.clipData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemindSelectClipCollectionViewCell.className, for: indexPath) as? RemindSelectClipCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0 {
            cell.configureCell(forModel: viewModel.clipData[indexPath.item], icon: .icAllClip24)
        } else {
            cell.configureCell(forModel: viewModel.clipData[indexPath.item], icon: .icClip24Black)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RemindSelectClipViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.convertByWidthRatio(335), height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

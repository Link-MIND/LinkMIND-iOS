//
//  DeleteLinkBottomSheetView.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/24.
//

import UIKit

import SnapKit
import Then

enum ClipType {
    case allClip
    case anthoerClip
    
    init(categoryId: Int) {
        self = categoryId == 0 ? .allClip : .anthoerClip
    }
}

final class LinkOptionBottomSheetView: UIView {
    
    // MARK: - Properties
    
    private let currentClipType: ClipType
    
    private var deleteLinkBottomSheetViewButtonAction: (() -> Void)?
    private var editLinkTitleBottomSheetViewButtonAction: (() -> Void)?
    private var confirmBottomSheetViewButtonAction: (() -> Void)?
    private var changeClipBottomSheetViewButtonAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let deleteButton = UIButton()
    private let editButton = UIButton()
    private let changeClipButton = UIButton()
    private let deleteButtonLabel = UILabel()
    private let editButtonLabel = UILabel()
    private let changeClipButtonLabel = UILabel()
    
    // MARK: - Life Cycles
    
    init(currentClipType: ClipType, frame: CGRect = .zero) {
        self.currentClipType = currentClipType
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension LinkOptionBottomSheetView {
    func setupDeleteLinkBottomSheetButtonAction(_ action: (() -> Void)?) {
        deleteLinkBottomSheetViewButtonAction = action
    }
    
    func setupEditLinkTitleBottomSheetButtonAction(_ action: (() -> Void)?) {
        editLinkTitleBottomSheetViewButtonAction = action
    }
    
    func setupConfirmBottomSheetButtonAction(_ action: (() -> Void)?) {
        confirmBottomSheetViewButtonAction = action
    }
    
    func setupChangeClipBottomSheetButtonAction(_ action: (() -> Void)?) {
        changeClipBottomSheetViewButtonAction = action
    }
}

// MARK: - Private Extensions

private extension LinkOptionBottomSheetView {
    func setupStyle() {
        backgroundColor = .gray50
  
        editButton.do {
            $0.backgroundColor = .toasterWhite
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.makeRounded(radius: 12)
        }
        
        deleteButton.do {
            $0.backgroundColor = .toasterWhite
            $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            $0.makeRounded(radius: 12)
        }
        
        changeClipButton.do {
            $0.backgroundColor = .toasterWhite
        }
        
        editButtonLabel.do {
            $0.text = "제목 편집"
            $0.textColor = .black900
            $0.font = .suitMedium(size: 16)
        }
        
        deleteButtonLabel.do {
            $0.text = StringLiterals.Button.delete
            $0.textColor = .toasterError
            $0.font = .suitMedium(size: 16)
        }
        
        changeClipButtonLabel.do {
            $0.text = "클립 이동"
            $0.textColor = .black900
            $0.font = .suitMedium(size: 16)
        }
    }
    
    func setupHierarchy() {
        addSubviews(editButton, deleteButton)
        editButton.addSubview(editButtonLabel)
        deleteButton.addSubview(deleteButtonLabel)
        
        if case .anthoerClip = currentClipType {
            addSubview(changeClipButton)
            changeClipButton.addSubview(changeClipButtonLabel)
        }
    }
    
    func setupLayout() {
        switch currentClipType {
        case .allClip:
            setupAllClipLayout()
        case .anthoerClip:
            setupAnthoerClipLayout()
        }
    }
    
    func setupAllClipLayout() {
        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(editButton.snp.bottom).offset(1)
            $0.height.equalTo(54)
        }
        
        [editButtonLabel, deleteButtonLabel].forEach {
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().inset(20)
            }
        }
    }
    
    func setupAnthoerClipLayout() {
        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        changeClipButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(editButton.snp.bottom).offset(1)
            $0.height.equalTo(54)
        }
        
        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(changeClipButton.snp.bottom).offset(1)
            $0.height.equalTo(54)
        }
        
        [editButtonLabel, changeClipButtonLabel, deleteButtonLabel].forEach {
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().inset(20)
            }
        }
    }
    
    func setupAddTarget() {
        editButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        changeClipButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc
    func buttonTapped(_ sender: UIButton) {
        switch sender {
        case editButton:
            editLinkTitleBottomSheetViewButtonAction?()
        case deleteButton:
            deleteLinkBottomSheetViewButtonAction?()
        case changeClipButton:
            changeClipBottomSheetViewButtonAction?()
        default:
            break
        }
    }
}

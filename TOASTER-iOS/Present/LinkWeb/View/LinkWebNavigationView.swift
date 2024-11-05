//
//  LinkWebNavigationView.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/11/24.
//

import UIKit

import SnapKit
import Then

final class LinkWebNavigationView: UIView {
    
    // MARK: - Properties
    
    private var popButtonAction: (() -> Void)?
    private var reloadButtonAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let popButton = UIButton()
    private let addressLabel = UITextField()
    private let reloadButton = UIButton()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension LinkWebNavigationView {
    func setupLinkAddress(link: String) {
        addressLabel.text = link
    }
    
    func popButtonTapped(_ action: @escaping () -> Void) {
        popButtonAction = action
    }
    
    func reloadButtonTapped(_ action: @escaping () -> Void) {
        reloadButtonAction = action
    }
}

// MARK: - Private Extensions

private extension LinkWebNavigationView {
    func setupStyle() {
        backgroundColor = .toasterWhite
        
        popButton.do {
            $0.tintColor = .gray800
            $0.setImage(.icArrowLeft24, for: .normal)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        addressLabel.do {
            $0.font = .suitSemiBold(size: 14)
            $0.textColor = .black900
            $0.textAlignment = .center
            $0.inputView = UIView()
        }
        
        reloadButton.do {
            $0.tintColor = .gray800
            $0.setImage(.icReload24, for: .normal)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        addSubviews(popButton, addressLabel, reloadButton)
    }
    
    func setupLayout() {
        popButton.snp.makeConstraints {
            $0.size.equalTo(25)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(6)
        }
        
        addressLabel.snp.makeConstraints {
            $0.centerY.equalTo(popButton)
            $0.leading.equalTo(popButton.snp.trailing).offset(13)
            $0.trailing.equalTo(reloadButton.snp.leading).inset(-13)
            $0.height.equalTo(36)
        }
        
        reloadButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(6)
        }
    }
    
    @objc
    func buttonTapped(_ sender: UIButton) {
        switch sender {
        case popButton:
            popButtonAction?()
        case reloadButton:
            reloadButtonAction?()
        default:
            break
        }
    }
}

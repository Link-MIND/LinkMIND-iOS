//
//  ClipCollectionHeaderView.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/4/24.
//

import UIKit

import SnapKit
import Then

protocol ClipCollectionHeaderViewDelegate: AnyObject {
    func addClipButtonTapped()
}

final class ClipCollectionHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    
    weak var clipCollectionHeaderViewDelegate: ClipCollectionHeaderViewDelegate?
    
    // MARK: - UI Components
    
    private let clipCountLabel = UILabel()
    private let addClipButton = UIButton()
    
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

extension ClipCollectionHeaderView {
    func isDetailClipView(isHidden: Bool) {
        addClipButton.isHidden = isHidden
        
        if isHidden {
            clipCountLabel.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().inset(20)
            }
        }
    }
    
    func setupDataBind(title: String, count: Int) {
        clipCountLabel.text = "\(title) (\(count))"
    }
}

// MARK: - Private Extensions

private extension ClipCollectionHeaderView {
    func setupStyle() {
        backgroundColor = .toasterBackground
        
        clipCountLabel.do {
            $0.textColor = .gray500
            $0.font = .suitBold(size: 12)
            $0.text = "전체 (n)"
        }
        
        addClipButton.do {
            $0.setImage(.icPlus18Orange, for: .normal)
            $0.setTitle("클립 추가", for: .normal)
            $0.setTitleColor(.toasterPrimary, for: .normal)
            $0.titleLabel?.font = .suitBold(size: 12)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        addSubviews(clipCountLabel, addClipButton)
    }
    
    func setupLayout() {
        
        clipCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(20)
        }
        
        addClipButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc
    func buttonTapped(_ sender: UIButton) {
        switch sender {
        case addClipButton:
            clipCollectionHeaderViewDelegate?.addClipButtonTapped()
        default:
            break
        }
    }
}

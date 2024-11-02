//
//  UserClipCollectionReusableView.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/09.
//
import UIKit

import SnapKit
import Then

final class HomeHeaderCollectionView: UICollectionReusableView {
    
    // MARK: - Properties
    
    private let titleLabel = UILabel()
    let arrowButton = UIButton()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setView() {
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
    
    // MARK: - set up Style
    
    private func setupStyle() {
        titleLabel.do {
            $0.textColor = .black900
            $0.font = .suitMedium(size: 18)
        }
        
        arrowButton.do {
            $0.setImage(.icArrow20, for: .normal)
            $0.isUserInteractionEnabled = true
            $0.isHidden = false
        }
    }
    
    // MARK: - set up Hierarchy
    
    private func setupHierarchy() {
        addSubviews(titleLabel, arrowButton)
    }
    
    // MARK: - set up Layout
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        arrowButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top).inset(1)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
}

extension HomeHeaderCollectionView {
    func configureHeader(forTitle: String, num: Int) {
        if num == 1 {
            titleLabel.text = forTitle + "님이 최근 저장한 링크"
            titleLabel.font = .suitMedium(size: 18)
            titleLabel.asFont(targetString: forTitle, font: .suitBold(size: 18))
        } else {
            titleLabel.text = forTitle
            titleLabel.asFont(targetString: forTitle, font: .suitBold(size: 18))
            arrowButton.isHidden = true
        }
    }
}

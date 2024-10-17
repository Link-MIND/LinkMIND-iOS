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
    }
    
    // MARK: - set up Hierarchy
    
    private func setupHierarchy() {
        addSubview(titleLabel)
    }
    
    // MARK: - set up Layout
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(5)
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
        }
    }
}

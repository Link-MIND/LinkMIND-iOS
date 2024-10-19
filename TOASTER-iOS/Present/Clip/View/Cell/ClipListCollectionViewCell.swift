//
//  ClipListCollectionViewCell.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/4/24.
//

import UIKit

import SkeletonView
import SnapKit
import Then

final class ClipListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let clipImage = UIImageView()
    private let clipNameLabel = UILabel()
    private let countLabel = UILabel()
    private let arrowImage = UIImageView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension ClipListCollectionViewCell {
    func configureCell(forModel: ClipModel, icon: UIImage, name: String) {
        clipNameLabel.text = name
        countLabel.text = "\(forModel.allClipToastCount)개"
        clipImage.image = icon
    }
    
    func configureCell(forModel: ClipModel, icon: UIImage, index: Int) {
        clipNameLabel.text = forModel.clips[index].title
        countLabel.text = "\(forModel.clips[index].toastCount)개"
        clipImage.image = icon
    }
    
    func configureCell(forModel: SearchResultClipModel, forText: String) {
        clipNameLabel.text = forModel.title
        clipNameLabel.asFont(targetString: forText, font: .suitBold(size: 16))
        countLabel.text = "\(forModel.numberOfDetailClip)개"
        clipImage.image = .icClip24Black
    }
}

// MARK: - Private Extensions

private extension ClipListCollectionViewCell {
    func setupStyle() {
        self.backgroundColor = .toasterWhite
        self.makeRounded(radius: 12)
        
        clipNameLabel.do {
            $0.font = .suitSemiBold(size: 16)
            $0.textColor = .black850
        }
        
        countLabel.do {
            $0.font = .suitSemiBold(size: 14)
            $0.textColor = .gray600
        }
        
        arrowImage.do {
            $0.image = .icArrow18
        }
    }
    
    func setupHierarchy() {
        addSubviews(clipImage, clipNameLabel, countLabel, arrowImage)
    }
    
    func setupLayout() {
        clipImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(14)
            $0.size.equalTo(24)
        }
        
        clipNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(clipImage)
            $0.leading.equalTo(clipImage.snp.trailing).offset(4)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerY.equalTo(clipImage)
            $0.trailing.equalTo(arrowImage.snp.leading).inset(2)
        }
        
        arrowImage.snp.makeConstraints {
            $0.centerY.equalTo(clipImage)
            $0.trailing.equalToSuperview().inset(14)
            $0.size.equalTo(20)
        }
    }
    
    func setupSkeleton() {
        isSkeletonable = true
        [clipImage, clipNameLabel, countLabel, arrowImage].forEach {
            $0.isSkeletonable = true
        }
    }
}

//
//  RemindSelectClipCollectionViewCell.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 1/11/24.
//

import UIKit

import SnapKit
import Then

enum ClipCellType {
    case remind
    case shareExtension
    case chagneClip
}

final class RemindSelectClipCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private var currentCategoryTitle: String?

    override var isSelected: Bool {
        didSet {
            if clipTitleLabel.text != currentCategoryTitle {
                if isSelected {
                    setupSelected()
                } else {
                    setupDeselected()
                }
            }
        }
    }

    var isRounded = true {
        didSet {
            updateRoundedStyle()
        }
    }
    
    // MARK: - UI Properties
    
    private let clipImageView: UIImageView = UIImageView(image: .icClip24Black)
    private let clipTitleLabel: UILabel = UILabel()
    private let clipCountLabel: UILabel = UILabel()
    private let separatorView = UIView()
    
    // MARK: - Life Cycle
        
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupStyle()
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extension

extension RemindSelectClipCollectionViewCell {
    func configureCell(forModel: RemindClipModel, icon: UIImage) {
        clipTitleLabel.text = forModel.title
        clipCountLabel.text = "\(forModel.clipCount)개"
        clipImageView.image = isSelected == true ? icon.withTintColor(.toasterPrimary) : icon
    }
    
    func configureCell(forModel: SelectClipModel, icon: UIImage) {
        clipTitleLabel.text = forModel.title
        clipCountLabel.text = "\(forModel.clipCount)개"
        clipImageView.image = isSelected == true ? icon.withTintColor(.toasterPrimary) : icon
    }
    
    func configureCell(forModel: RemindClipModel, icon: UIImage, isRounded: Bool) {
        clipTitleLabel.text = forModel.title
        clipCountLabel.text = "\(forModel.clipCount)개"
        clipTitleLabel.textColor = isSelected == true ? .toasterPrimary : .black850
        clipCountLabel.textColor = isSelected == true ? .toasterPrimary : .gray600
        clipImageView.image = isSelected == true ? icon.withTintColor(.toasterPrimary) : icon
        self.isRounded = isRounded
    }

    /// 이동 할 카테고리 Cell 을 초기화 시키는 메서드
    func configureChangeClipCell(forModel: SelectClipModel, canSelect: Bool, icon: UIImage) {
        
        if canSelect == false {
            currentCategoryTitle = forModel.title
        }
        
        clipTitleLabel.text = forModel.title
        clipCountLabel.text = "\(forModel.clipCount)개"
        clipImageView.image = icon.withTintColor(canSelect ? .toasterBlack : .gray200)

        clipTitleLabel.textColor = canSelect ? .black850 : .gray200
        clipCountLabel.textColor = canSelect ? .gray600 : .gray200
        
        self.isRounded = false
    }
}

// MARK: - Private Extension

private extension RemindSelectClipCollectionViewCell {
    func setupStyle() {
        backgroundColor = .toasterWhite
        
        clipTitleLabel.do {
            $0.font = .suitSemiBold(size: 16)
            $0.textColor = .black850
        }
        
        clipCountLabel.do {
            $0.font = .suitSemiBold(size: 14)
            $0.textColor = .gray600
        }
        
        updateRoundedStyle()
    }
    
    func setupHierarchy() {
        addSubviews(clipImageView, clipTitleLabel, clipCountLabel)
    }
    
    func setupLayout() {
        clipImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(14)
        }
        
        clipTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(clipImageView.snp.trailing).offset(4)
        }
        
        clipCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(14)
        }
    }
    
    func setupSelected() {
        if clipTitleLabel.text == "전체 클립" {
            clipImageView.image = .icAllClip24.withTintColor(.toasterPrimary)
        } else {
            clipImageView.image = .icClip24Black.withTintColor(.toasterPrimary)
        }
        
        [clipTitleLabel, clipCountLabel].forEach {
            $0.textColor = .toasterPrimary
        }
    }
    
    func setupDeselected() {
        if clipTitleLabel.text == "전체 클립" {
            clipImageView.image = .icAllClip24
        } else {
            clipImageView.image = .icClip24Black
        }

        clipTitleLabel.textColor = .toasterBlack
        clipCountLabel.textColor = .gray600
    }
    
    func updateRoundedStyle() {
        if isRounded {
            makeRounded(radius: 12)
        } else {
            makeRounded(radius: 0)
        }
    }
}

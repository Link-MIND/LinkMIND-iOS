//
//  MypageHeaderView.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 1/10/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class MypageHeaderView: UIView {

    // MARK: - UI Components
    
    private let profileImageView = UIImageView()
    
    private let subTitleStackView = UIStackView()
    private let topSubTitleLabel = UILabel()
    private let bottomSubTitleLabel = UILabel()
    
    private let readLinkStackView = UIStackView()
    private let readLinkCountLabel = UILabel()
    private let readLinkCountUnitLabel = UILabel()
    
    let weakLinkDataView = UIView()
    private let weakLinkDivider = UIView()
    private let openLinkLabel = UILabel()
    private let saveLinkLabel = UILabel()
    private let thisWeakOpenLinkCountLabel = UILabel()
    private let thisWeakSaveLinkCountLabel = UILabel()
    
    let seperatorView = UIView()
    
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

extension MypageHeaderView {
    func bindModel(model: MypageUserModel) {
        
        topSubTitleLabel.text = "\(model.nickname)님이"
        
        topSubTitleLabel.asFont(targetString: model.nickname, font: UIFont.suitBold(size: 18))
        
        readLinkCountLabel.text = "\(model.allReadToast)"
        thisWeakOpenLinkCountLabel.text = "\(model.thisWeekendRead)"
        thisWeakSaveLinkCountLabel.text = "\(model.thisWeekendSaved)"
        profileImageView.image = .profile
    }
}

// MARK: - Private Extensions

private extension MypageHeaderView {
    func setupStyle() {
        backgroundColor = .toasterBackground
        
        profileImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        subTitleStackView.do {
            $0.spacing = 2
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .leading
        }
        
        topSubTitleLabel.do {
            $0.font = .suitRegular(size: 18)
            $0.textColor = .black900
        }
        
        bottomSubTitleLabel.do {
            $0.text = "지금까지 읽은 링크 수"
            $0.font = .suitRegular(size: 18)
            $0.textColor = .black900
        }
        
        readLinkCountLabel.do {
            $0.font = .suitBold(size: 28)
            $0.textColor = .toasterPrimary
        }
        
        readLinkCountUnitLabel.do {
            $0.text = "개"
            $0.font = .suitMedium(size: 16)
            $0.textColor = .black900
        }
        
        weakLinkDataView.do {
            $0.backgroundColor = .gray50
            $0.makeRounded(radius: 12)
        }
        
        weakLinkDivider.do {
            $0.backgroundColor = .gray100
        }
        
        openLinkLabel.do {
            $0.textColor = .gray400
            $0.text = "이번주 열람한 링크"
            $0.font = .suitMedium(size: 14)
        }
        
        saveLinkLabel.do {
            $0.textColor = .gray400
            $0.text = "이번주 저장한 링크"
            $0.font = .suitMedium(size: 14)
        }
        
        [thisWeakOpenLinkCountLabel, thisWeakSaveLinkCountLabel].forEach {
            $0.do {
                $0.textColor = .black900
                $0.font = .suitBold(size: 24)
                $0.text = "nn"
            }
        }
        
        seperatorView.do {
            $0.backgroundColor = .gray50
        }
    }
    
    func setupHierarchy() {
        addSubviews(profileImageView, subTitleStackView, weakLinkDataView, readLinkCountLabel, readLinkCountUnitLabel, seperatorView)
        
        subTitleStackView.addArrangedSubviews(topSubTitleLabel, bottomSubTitleLabel)
        
        weakLinkDataView.addSubviews(openLinkLabel, thisWeakOpenLinkCountLabel, weakLinkDivider, saveLinkLabel, thisWeakSaveLinkCountLabel)
    }
    
    func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        subTitleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(1)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(readLinkCountLabel.snp.leading).inset(-5)
            $0.bottom.equalTo(weakLinkDataView.snp.top).offset(-19)
        }
        
        weakLinkDataView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(24)
            $0.height.equalTo(83)
        }
        
        openLinkLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(14)
        }
        
        thisWeakOpenLinkCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(39)
            $0.trailing.equalTo(weakLinkDivider.snp.trailing).inset(14)
        }

        weakLinkDivider.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(83)
            $0.center.equalToSuperview()
        }
        
        saveLinkLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(weakLinkDivider.snp.trailing).offset(14)
        }
        
        thisWeakSaveLinkCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(39)
            $0.trailing.equalToSuperview().inset(14)
        }
        
        readLinkCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.trailing.equalTo(readLinkCountUnitLabel.snp.leading).offset(-3)
        }
            
        readLinkCountUnitLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview()
        }
        
        seperatorView.snp.makeConstraints {
            $0.top.equalTo(weakLinkDataView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(4)
        }
    }
    
    func changeFontColor(text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        attributedString.addAttribute(.foregroundColor, value: UIColor.black900, range: NSRange(location: 0, length: 5))
        // 유저 이름에 다른 폰트 적용
        attributedString.addAttribute(.font, value: UIFont.suitBold(size: 18), range: NSRange(location: 0, length: 3))
        // '님이'에 다른 폰트 적용
        attributedString.addAttribute(.font, value: UIFont.suitRegular(size: 18), range: NSRange(location: 3, length: 2))
        return attributedString
    }
}

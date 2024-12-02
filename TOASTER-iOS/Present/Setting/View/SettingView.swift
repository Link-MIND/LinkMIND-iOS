//
//  SettingView.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 9/29/24.
//

import UIKit

import Kingfisher
import Then
import SnapKit

final class SettingView: UIView {
    
    let settingList = ["알림 설정", "1:1 문의", "이용약관", "로그아웃"]
    
    // MARK: - UI Properties
    
    let alertWarningView = UIView()
    private let warningStackView = UIStackView()
    private let warningImage = UIImageView()
    private let warningLabel = UILabel()
    let settingTableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Life Cycle
    
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

private extension SettingView {
    func setupStyle() {
        self.backgroundColor = .toasterBackground
        
        alertWarningView.do {
            $0.backgroundColor = .gray50
            $0.makeRounded(radius: 12)
        }
        
        warningStackView.do {
            $0.spacing = 5
        }
        
        warningImage.do {
            $0.image = .icAlert18Dark
            $0.contentMode = .scaleAspectFit
        }
        
        warningLabel.do {
            $0.text = "알림 설정을 끄면 타이머 기능을 이용할 수 없어요"
            $0.font = .suitBold(size: 12)
            $0.textColor = .gray400
        }
        
        settingTableView.do {
            $0.backgroundColor = .toasterBackground
            $0.isScrollEnabled = false
            $0.separatorStyle = .none
            $0.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.className)
        }
    }
    
    func setupHierarchy() {
        addSubviews(alertWarningView, settingTableView)
        alertWarningView.addSubview(warningStackView)
        warningStackView.addArrangedSubviews(warningImage, warningLabel)
    }
    
    func setupLayout() {
        alertWarningView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(42)
        }
        
        warningStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        warningImage.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(18)
        }
        
        warningLabel.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
        }
        
        settingTableView.snp.makeConstraints {
            $0.top.equalTo(alertWarningView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

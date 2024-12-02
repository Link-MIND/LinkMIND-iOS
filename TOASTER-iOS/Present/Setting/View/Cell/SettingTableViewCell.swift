//
//  SettingTableViewCell.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/14/24.
//

import UIKit

import SnapKit
import Then

final class SettingTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private var switchValueChangedHandler: ((Bool) -> Void)?
    
    // MARK: - UI Components
    
    private let settingLabel = UILabel()
    private let settingSwitch = UISwitch()
    
    // MARK: - Life Cycles
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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

extension SettingTableViewCell {
    func configureCell(name: String, sectionNumber: Int) {
        switch sectionNumber {
        case 0:
            settingLabel.do {
                $0.text = name
                $0.font = .suitMedium(size: 18)
                $0.textColor = .black900
            }
            if name == "알림 설정" {
                if let isOn = UserDefaults.standard.object(forKey: "isAppAlarmOn") as? Bool {
                    settingSwitch.isOn = isOn
                } else {
                    settingSwitch.isOn = false
                }
            }
        default:
            settingLabel.do {
                $0.text = name
                $0.font = .suitMedium(size: 16)
                $0.textColor = .gray400
            }
        }
    }
    
    func showSwitch() {
        settingSwitch.isHidden = false
    }
    
    func hiddenSwitch() {
        settingSwitch.isHidden = true
    }
    
    func setSwitchValueChangedHandler(_ handler: @escaping (Bool) -> Void) {
        switchValueChangedHandler = handler
    }
}

// MARK: - Private Extensions

private extension SettingTableViewCell {
    func setupStyle() {
        backgroundColor = .toasterBackground
        settingSwitch.isHidden = true
        
        settingSwitch.do {
            $0.onTintColor = .toasterPrimary
            $0.isUserInteractionEnabled = true
            $0.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            if let isOn = UserDefaults.standard.object(forKey: "isAppAlarmOn") as? Bool {
                $0.isOn = isOn
            }
        }
    }
    
    func setupHierarchy() {
        contentView.addSubviews(settingLabel, settingSwitch)
    }
    
    func setupLayout() {
        settingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        settingSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(30)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(24)
        }
    }
    
    @objc
    func switchValueChanged(_ sender: UISwitch) {
        switchValueChangedHandler?(sender.isOn)
        UserDefaults.standard.set(sender.isOn, forKey: "isAppAlarmOn")
    }
}

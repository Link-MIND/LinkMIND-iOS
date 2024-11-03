//
//  ToasterBottomSheetViewController.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/2/24.
//

import UIKit

import SnapKit
import Then

final class ToasterBottomSheetViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private var insertView: UIView
    
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    
    // MARK: - Life Cycle
    
    init(bottomType: BottomType,
         bottomTitle: String,
         insertView: UIView) {
        self.insertView = insertView
        super.init(nibName: nil, bundle: nil)
        setupInitialStyle(bottomType: bottomType, bottomTitle: bottomTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
}

extension ToasterBottomSheetViewController {
    func setupSheetPresentation(bottomHeight: CGFloat) {
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in bottomHeight - (self.view.hasNotch ? 34 : 0)})]
            sheet.preferredCornerRadius = 20
        }
    }
    
    func setupSheetHeightChanges(bottomHeight: CGFloat) {
        if let sheet = self.sheetPresentationController {
            sheet.animateChanges {
                sheet.detents = [.custom(resolver: { _ in bottomHeight - (self.view.hasNotch ? 34 : 0)})]
            }
        }
    }
}

// MARK: - Private Extensions

private extension ToasterBottomSheetViewController {
    func setupInitialStyle(bottomType: BottomType, bottomTitle: String) {
        self.view.backgroundColor = bottomType.color
        self.titleLabel.textAlignment = bottomType.alignment
        self.titleLabel.text = bottomTitle
    }
    
    func setupStyle() {
        titleLabel.do {
            $0.font = .suitBold(size: 18)
            $0.textColor = .toasterBlack
        }
        
        closeButton.do {
            $0.setImage(.icClose24, for: .normal)
            $0.addAction(
                UIAction { [weak self] _ in self?.dismiss(animated: true) },
                for: .touchUpInside
            )
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(titleLabel, closeButton, insertView)
    }
    
    func setupLayout() {
        insertView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(64)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
        }
    }
}

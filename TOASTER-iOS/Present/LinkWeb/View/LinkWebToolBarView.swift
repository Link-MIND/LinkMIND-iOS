//
//  LinkWebToolBarView.swift
//  TOASTER-iOS
//
//  Created by 민 on 9/4/24.
//

import UIKit

import SnapKit

final class LinkWebToolBarView: UIView {
    
    // MARK: - Properties
    
    private var canGoBack: Bool = false {
        didSet {
            backButton.isEnabled = canGoBack
            backButton.tintColor = canGoBack ? .gray700 : .gray200
        }
    }
    
    private var canGoForward: Bool = false {
        didSet {
            forwardButton.isEnabled = canGoForward
            forwardButton.tintColor = canGoForward ? .gray700 : .gray200
        }
    }
    
    private(set) var isRead: Bool = false {
        didSet {
            readLinkCheckButton.tintColor = isRead ? .toasterPrimary : .gray200
            toolBar.setItems([backButton, flexibleSpace, forwardButton, flexibleSpace, readLinkCheckButton, flexibleSpace, shareLinkButton, flexibleSpace, safariButton], animated: false)
        }
    }
    
    private var backButtonAction: (() -> Void)?
    private var forwardButtonAction: (() -> Void)?
    private var shareButtonAction: (() -> Void)?
    private var safariButtonAction: (() -> Void)?
    
    lazy var readLinkButtonTap = readLinkCheckButton.publisher()
    
    // MARK: - UI Components
    
    private let toolBar = UIToolbar()
    
    private let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let backButton = UIBarButtonItem()
    private let forwardButton = UIBarButtonItem()
    private(set) var readLinkCheckButton = UIBarButtonItem()
    private let shareLinkButton = UIBarButtonItem()
    private let safariButton = UIBarButtonItem()
      
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupAddTarget()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension LinkWebToolBarView {
    func backButtonTapped(_ action: @escaping () -> Void) {
        backButtonAction = action
    }
    
    func forwardButtonTapped(_ action: @escaping () -> Void) {
        forwardButtonAction = action
    }
    
    func shareButtonTapped(_ action: @escaping () -> Void) {
        shareButtonAction = action
    }
    
    func safariButtonTapped(_ action: @escaping () -> Void) {
        safariButtonAction = action
    }
    
    func updateCanGoBack(_ canGoBack: Bool) {
        self.canGoBack = canGoBack
    }
    
    func updateCanGoForward(_ canGoForward: Bool) {
        self.canGoForward = canGoForward
    }
    
    func updateIsRead(_ isRead: Bool) {
        self.isRead = isRead
    }
}

// MARK: - Private Extensions

private extension LinkWebToolBarView {
    func setupStyle() {
        toolBar.do {
            $0.backgroundColor = .toasterWhite
            $0.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
            $0.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        }

        backButton.do {
            $0.tintColor = .gray700
            $0.image = .icArrow2Back24
            $0.style = .plain
        }
        
        forwardButton.do {
            $0.tintColor = .gray700
            $0.image = .icArrow2Forward24
            $0.style = .plain
        }
        
        readLinkCheckButton.do {
            $0.image = .icRead
            $0.style = .plain
        }
        
        shareLinkButton.do {
            $0.tintColor = .gray700
            $0.image = .icShare
            $0.style = .plain
        }
        
        safariButton.do {
            $0.tintColor = .gray700
            $0.image = .icSafari24
            $0.style = .plain
        }
    }
    
    func setupHierarchy() {
        addSubview(toolBar)
        toolBar.setItems([backButton, flexibleSpace, forwardButton, flexibleSpace, shareLinkButton, flexibleSpace, safariButton], animated: false)
    }
    
    func setupLayout() {
        toolBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupAddTarget() {
        [backButton, forwardButton, readLinkCheckButton, shareLinkButton, safariButton].forEach {
            $0.target = self
            $0.action = #selector(barButtonTapped)
        }
    }
    
    @objc
    func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender {
        case backButton:
            backButtonAction?()
        case forwardButton:
            forwardButtonAction?()
        case shareLinkButton:
            shareButtonAction?()
        case safariButton:
            safariButtonAction?()
        default:
            break
        }
    }
}

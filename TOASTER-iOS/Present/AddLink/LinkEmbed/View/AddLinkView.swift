//
//  AddLinkView.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/12.
//

import UIKit

import SnapKit
import Then

final class AddLinkView: UIView {
    
    // MARK: - Property

    private var keyboardHeight: CGFloat = 100
    
    // MARK: - UI Components
    
    private let descriptLabel = UILabel()
    private(set) var linkEmbedTextField = UITextField()
    let clearButton = UIButton()
    
    let nextBottomButton = UIButton()
    let nextTopButton = UIButton()
    
    lazy var accessoryView: UIView = { return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 56.0)) }()
    
    private let errorLabel = UILabel()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLinkEmbedTextField()
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Make View
    
    func setupView() {
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
    
    func setLinkEmbedTextField() {
        linkEmbedTextField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange() {
        nextBottomButton.backgroundColor = .black850
        nextBottomButton.isEnabled = true
    }
}

// MARK: - Private extension

private extension AddLinkView {
    func setupStyle() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.backgroundColor = .toasterBackground
        
        descriptLabel.do {
            $0.text = "링크를 입력해주세요"
            $0.font = .suitMedium(size: 18)
        }
        
        linkEmbedTextField.do {
            $0.placeholder = StringLiterals.Placeholder.copyLink
            $0.tintColor = .toasterPrimary
            $0.backgroundColor = .gray50
            $0.makeRounded(radius: 12)
            $0.inputAccessoryView = accessoryView
            $0.addPadding(left: 14, right: 42)
            $0.addTarget(self, action: #selector(self.textFieldDidChange), for: .touchUpInside)
        }
        
        clearButton.do {
            $0.setImage(.icCancle24, for: .normal)
            $0.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            $0.isHidden = true
        }
        
        nextBottomButton.do {
            $0.setTitle(StringLiterals.Button.next, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.backgroundColor = .gray200
            $0.makeRounded(radius: 12)
        }
        
        nextTopButton.do {
            $0.setTitle(StringLiterals.Button.next, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.backgroundColor = .black850
        }
        
        errorLabel.do {
            $0.textColor = .toasterError
            $0.font = .suitMedium(size: 12)
        }
    }
    
    func setupHierarchy() {
        addSubviews(descriptLabel, linkEmbedTextField, nextBottomButton, clearButton)
        accessoryView.addSubview(nextTopButton)
    }
    
    func setupLayout() {
        descriptLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(20)
        }
        
        linkEmbedTextField.snp.makeConstraints {
            $0.top.equalTo(descriptLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        clearButton.snp.makeConstraints {
            $0.top.equalTo(linkEmbedTextField.snp.top).inset(15)
            $0.trailing.equalTo(linkEmbedTextField.snp.trailing).inset(14)
        }
        
        nextBottomButton.snp.makeConstraints {
            $0.top.equalTo(super.snp.bottom).inset(96)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(62)
        }
        
        // 키보드 위의 버튼
        nextTopButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(56)
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    @objc 
    func cancelButtonTapped() {
        linkEmbedTextField.text = ""
        linkEmbedTextField.becomeFirstResponder()
    }
}

// MARK: - Extension

extension AddLinkView {
    func isValidLinkError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        addSubview(errorLabel)
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(linkEmbedTextField.snp.bottom).offset(6)
            $0.leading.equalTo(linkEmbedTextField.snp.leading)
        }
    }
    
    func resetError() {
        errorLabel.isHidden = true
    }
}

//
//  EditLinkBottomSheetView.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/04/12.
//

import UIKit

import SnapKit
import Then

protocol EditLinkBottomSheetViewDelegate: AnyObject {
    func dismissButtonTapped(title: String)
    func addHeightBottom()
    func minusHeightBottom()
    func callCheckAPI(filter: DetailCategoryFilter)
}

final class EditLinkBottomSheetView: UIView {
    
    // MARK: - Properties
    
    weak var editLinkBottomSheetViewDelegate: EditLinkBottomSheetViewDelegate?
    private var confirmBottomSheetViewButtonAction: (() -> Void)?
    
    private var isButtonClicked: Bool = false {
        didSet {
            setupButtonColor()
        }
    }
    
    private var isBorderColor: Bool = false {
        didSet {
            setupTextFieldBorder()
        }
    }
    
    private var isError: Bool = false {
        didSet {
            setupErrorMessage()
        }
    }
    
    private var isClearButtonShow: Bool = true {
        didSet {
            setupClearButton()
        }
    }
    
    // MARK: - UI Components
    
    let editClipTitleTextField = UITextField()
    private let editClipButton = UIButton()
    private let errorMessage = UILabel()
    private let clearButton = UIButton()
    
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
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupKeyboard()
    }
}

// MARK: - Extensions

extension EditLinkBottomSheetView {
    func resetTextField() {
        editClipTitleTextField.text = nil
        editClipTitleTextField.becomeFirstResponder()
        isButtonClicked = true
    }
    
    func changeTextField(addButton: Bool, border: Bool, error: Bool, clearButton: Bool) {
        isButtonClicked = addButton
        isBorderColor = border
        isError = error
        isClearButtonShow = clearButton
    }
    
    func setupMessage(message: String) {
        errorMessage.text = message
    }
    
    func setupTextField(message: String) {
        editClipTitleTextField.text = message
        editClipTitleTextField.placeholder = message
    }
    
    func setupConfirmBottomSheetButtonAction(_ action: (() -> Void)?) {
        confirmBottomSheetViewButtonAction = action
    }
}

// MARK: - Private Extensions

private extension EditLinkBottomSheetView {
    func setupStyle() {
        backgroundColor = .toasterWhite
        
        editClipTitleTextField.do {
            $0.attributedPlaceholder = NSAttributedString(string: StringLiterals.Placeholder.addClip,
                                                          attributes: [.foregroundColor: UIColor.gray400,
                                                                       .font: UIFont.suitRegular(size: 16)])
            $0.addPadding(left: 14, right: 44)
            $0.backgroundColor = .gray50
            $0.textColor = .black900
            $0.makeRounded(radius: 12)
            $0.borderStyle = .none
            $0.isUserInteractionEnabled = true
            $0.delegate = self
        }
        
        editClipButton.do {
            isButtonClicked = false
            $0.setTitle(StringLiterals.Button.okay, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.titleLabel?.font = .suitBold(size: 16)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        errorMessage.do {
            $0.isHidden = true
            $0.font = .suitMedium(size: 12)
            $0.textColor = .toasterError
        }
        
        clearButton.do {
            $0.isHidden = true
            $0.setImage(.icSearchCancle, for: .normal)
            $0.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        addSubviews(editClipTitleTextField, editClipButton, errorMessage)
        editClipTitleTextField.addSubview(clearButton)
    }
    
    func setupLayout() {
        editClipTitleTextField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        errorMessage.snp.makeConstraints {
            $0.top.equalTo(editClipTitleTextField.snp.bottom).offset(6)
            $0.leading.equalTo(editClipTitleTextField)
        }
        
        editClipButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
        
        clearButton.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
    
    func setupKeyboard() {
        if !editClipTitleTextField.isFirstResponder {
            editClipTitleTextField.becomeFirstResponder()
        }
    }
    
    func setupButtonColor() {
        if isButtonClicked {
            editClipButton.isEnabled = true
            editClipButton.backgroundColor = .toasterPrimary
        } else {
            editClipButton.isEnabled = false
            editClipButton.backgroundColor = .gray200
        }
    }
    
    func setupTextFieldBorder() {
        if isBorderColor {
            editClipTitleTextField.layer.borderColor = UIColor.toasterError.cgColor
            editClipTitleTextField.layer.borderWidth = 1.0
        } else {
            editClipTitleTextField.layer.borderColor = UIColor.clear.cgColor
            editClipTitleTextField.layer.borderWidth = 0.0
        }
    }
    
    func setupErrorMessage() {
        if isError {
            editLinkBottomSheetViewDelegate?.addHeightBottom()
            errorMessage.isHidden = false
        } else {
            editLinkBottomSheetViewDelegate?.minusHeightBottom()
            errorMessage.isHidden = true
        }
    }
    
    func setupClearButton() {
        if isClearButtonShow {
            clearButton.isHidden = false
        } else {
            clearButton.isHidden = true
        }
    }
    
    @objc
    func buttonTapped() {
        confirmBottomSheetViewButtonAction?()
        editLinkBottomSheetViewDelegate?.dismissButtonTapped(title: editClipTitleTextField.text ?? "")
    }
    
    @objc
    func clearButtonTapped() {
        resetTextField()
    }
}

// MARK: - UITextField Delegate

extension EditLinkBottomSheetView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        if currentText.isEmpty {
            changeTextField(addButton: false, border: false, error: false, clearButton: false)
        } else {
            changeTextField(addButton: true, border: false, error: false, clearButton: true)
        }
    }
}

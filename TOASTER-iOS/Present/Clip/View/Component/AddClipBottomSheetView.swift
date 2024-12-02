//
//  AddClipBottomSheetView.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/4/24.
//

import UIKit

import SnapKit
import Then

protocol AddClipBottomSheetViewDelegate: AnyObject {
    // func dismissButtonTapped(title: String)
    func addHeightBottom()
    func minusHeightBottom()
    // func callCheckAPI(text: String)
}

final class AddClipBottomSheetView: UIView {
    
    // MARK: - Properties
    
    weak var addClipBottomSheetViewDelegate: AddClipBottomSheetViewDelegate?
    
    private var timer: Timer?
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
    
    private let addClipTextField = UITextField()
    private let addClipButton = UIButton()
    private let errorMessage = UILabel()
    private let clearButton = UIButton()
    
    lazy var textFieldValueChanged = NotificationCenter.default
        .publisher(for: UITextField.textDidChangeNotification, object: self.addClipTextField)
    lazy var addClipButtonTap = addClipButton.publisher(for: .touchUpInside)
    
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

// MARK: - Private Extensions

extension AddClipBottomSheetView {
    func resetTextField() {
        addClipTextField.text = nil
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
        addClipTextField.text = message
    }
}

// MARK: - Private Extensions

private extension AddClipBottomSheetView {
    func setupStyle() {
        backgroundColor = .toasterWhite
        
        addClipTextField.do {
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
        
        addClipButton.do {
            isButtonClicked = false
            $0.setTitle(StringLiterals.Button.okay, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.titleLabel?.font = .suitBold(size: 16)
            // $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
        addSubviews(addClipTextField, addClipButton, errorMessage)
        addClipTextField.addSubview(clearButton)
    }
    
    func setupLayout() {
        addClipTextField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
        
        errorMessage.snp.makeConstraints {
            $0.top.equalTo(addClipTextField.snp.bottom).offset(6)
            $0.leading.equalTo(addClipTextField)
        }
        
        addClipButton.snp.makeConstraints {
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
        if !addClipTextField.isFirstResponder {
            addClipTextField.becomeFirstResponder()
        }
    }
    
    func setupButtonColor() {
        if isButtonClicked {
            addClipButton.isEnabled = true
            addClipButton.backgroundColor = .toasterPrimary
        } else {
            addClipButton.isEnabled = false
            addClipButton.backgroundColor = .gray200
        }
    }
    
    func setupTextFieldBorder() {
        if isBorderColor {
            addClipTextField.layer.borderColor = UIColor.toasterError.cgColor
            addClipTextField.layer.borderWidth = 1.0
        } else {
            addClipTextField.layer.borderColor = UIColor.clear.cgColor
            addClipTextField.layer.borderWidth = 0.0
        }
    }
    
    func setupErrorMessage() {
        if isError {
            addClipBottomSheetViewDelegate?.addHeightBottom()
            errorMessage.isHidden = false
        } else {
            addClipBottomSheetViewDelegate?.minusHeightBottom()
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            if let urlText = self?.addClipTextField.text {
                // self?.addClipBottomSheetViewDelegate?.callCheckAPI(text: urlText)
            }
        }
    }
    
    /// 타이머 재시작
    func restartTimer() {
        timer?.invalidate()
        startTimer()
    }
    
//    @objc
//    func buttonTapped() {
//        addClipBottomSheetViewDelegate?.dismissButtonTapped(title: addClipTextField.text ?? "")
//    }
    
    @objc
    func clearButtonTapped() {
        resetTextField()
    }
}

// MARK: - UITextField Delegate

extension AddClipBottomSheetView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        restartTimer()
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        let currentText = textField.text ?? ""
        let maxLength = 16
        
        // 길이가 16에서 15로 돌아갈 때
        if currentText.count == maxLength && newText.count == 15 {
            addClipBottomSheetViewDelegate?.minusHeightBottom()
            restartTimer()
        }
        return newText.count <= maxLength
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        if currentText.isEmpty {
            changeTextField(addButton: false, border: false, error: false, clearButton: false)
        } else if currentText.count > 15 {
            changeTextField(addButton: false, border: true, error: true, clearButton: true)
            setupMessage(message: "클립의 이름은 최대 15자까지 입력 가능해요")
        } else {
            changeTextField(addButton: true, border: false, error: false, clearButton: true)
        }
    }
}

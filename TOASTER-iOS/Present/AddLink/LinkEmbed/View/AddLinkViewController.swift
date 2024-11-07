//
//  AddLinkViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import UIKit

import SnapKit
import Then

protocol SaveLinkButtonDelegate: AnyObject {
    func saveLinkButtonTapped()
    func cancleLinkButtonTapped()
}

protocol AddLinkViewControllerPopDelegate: AnyObject {
    func changeTabBarIndex()
}

protocol SelectClipViewControllerDelegate: AnyObject {
    func sendEmbedUrl()
}

final class AddLinkViewController: UIViewController {
    
    // MARK: - Properties
    
    private weak var delegate: AddLinkViewControllerPopDelegate?
    private weak var urldelegate: SelectClipViewControllerDelegate?
    
    // MARK: - UI Components
    
    private var addLinkView = AddLinkView()
    private var viewModel = AddLinkViewModel()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupAddLinkVew()
        hideKeyboard()
        
        setupBinding()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        navigationBarHidden(forHidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationBarHidden(forHidden: false)
    }
}

// MARK: - extension

extension AddLinkViewController {
    func setupDelegate(forDelegate: AddLinkViewControllerPopDelegate) {
        delegate = forDelegate
    }
    
    /// 클립보드 붙여넣기 Alert -> 붙여넣기 허용 클릭 후 자동 링크 임베드를 위한 함수
    func embedURL(url: String) {
        addLinkView.linkEmbedTextField.becomeFirstResponder()
        addLinkView.linkEmbedTextField.text = url   // 텍스트필드에 text 채우기
        viewModel.inputs.embedLinkText(url)         // 관리중 ViewModel에도 String 수정 -> UI 반영
        UIPasteboard.general.url = nil
    }
}

// MARK: - Private extension

private extension AddLinkViewController {
    func setupStyle() {
        view.backgroundColor = .toasterBackground
    }
    
    func setupAddLinkVew() {
       view.addSubview(addLinkView)
       
       addLinkView.snp.makeConstraints {
           $0.edges.equalTo(view.safeAreaLayoutGuide)
       }
       
       addLinkView.nextBottomButton.addTarget(self, action: #selector(tappedNextBottomButton), for: .touchUpInside)
       addLinkView.nextTopButton.addTarget(self, action: #selector(tappedNextBottomButton), for: .touchUpInside)
   }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: false,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.string("링크 저장"),
                                                                rightButton: StringOrImageType.image(.icClose24),
                                                                rightButtonAction: closeButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func navigationBarHidden(forHidden: Bool) {
        tabBarController?.tabBar.isHidden = forHidden
    }
    
    func closeButtonTapped() {
        showPopup(forMainText: "링크 저장을 취소하시겠어요?",
                  forSubText: "저장 중인 링크가 사라져요",
                  forLeftButtonTitle: StringLiterals.Button.close,
                  forRightButtonTitle: StringLiterals.Button.delete,
                  forRightButtonHandler: rightButtonTapped)
    }
    
    func rightButtonTapped() {
        dismiss(animated: false)
        delegate?.changeTabBarIndex()
        navigationController?.popViewController(animated: false)
    }
    
    @objc func tappedNextBottomButton() {
        let selectClipViewController = SelectClipViewController()
        selectClipViewController.linkURL = addLinkView.linkEmbedTextField.text ?? ""
        selectClipViewController.delegate = self
        self.navigationController?.pushViewController(selectClipViewController, animated: true)
    }
    
}

// ViewModel
extension AddLinkViewController {
    private func setupBinding() {
        addLinkView.linkEmbedTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.inputs.embedLinkText(textField.text ?? "")
        updateUI()
    }
    
    private func updateUI() {
        addLinkView.clearButton.isHidden = viewModel.outputs.isClearButtonHidden
        addLinkView.nextTopButton.isEnabled = viewModel.outputs.isNextButtonEnabled
        addLinkView.nextTopButton.backgroundColor = viewModel.outputs.nextButtonBackgroundColor
        addLinkView.nextBottomButton.isEnabled = viewModel.outputs.isNextButtonEnabled
        addLinkView.nextBottomButton.backgroundColor = viewModel.outputs.nextButtonBackgroundColor
        addLinkView.linkEmbedTextField.layer.borderColor = viewModel.outputs.textFieldBorderColor.cgColor
        addLinkView.linkEmbedTextField.layer.borderWidth = 1
        
        if let errorMessage = viewModel.outputs.linkEffectivenessMessage {
            addLinkView.isValidLinkError(errorMessage)
        } else {
            addLinkView.resetError()
        }
    }
}

extension AddLinkViewController: SaveLinkButtonDelegate {
    func saveLinkButtonTapped() {
        delegate?.changeTabBarIndex()
        navigationController?.showToastMessage(width: 157,
                                               status: .check,
                                               message: "링크 저장 완료!")
    }
    
    func cancleLinkButtonTapped() {
        delegate?.changeTabBarIndex()
    }
}

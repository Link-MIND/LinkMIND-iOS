//
//  AddLinkViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import Combine
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
    
    private var addLinkView = AddLinkView()
    private var viewModel: AddLinkViewModel!
    private var cancelBag = CancelBag()
    
    // MARK: - Life Cycle
    
    init(viewModel: AddLinkViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModels()
        setupStyle()
        setupAddLinkVew()
        hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
        addLinkView.linkEmbedTextField.text = url
        viewModel.embedLinkText.send(url)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addLinkView.linkEmbedTextField.sendActions(for: .editingChanged)
        }
        
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
        let type: ToasterNavigationType = ToasterNavigationType(
            hasBackButton: false,
            hasRightButton: true,
            mainTitle: StringOrImageType.string("링크 저장"),
            rightButton: StringOrImageType.image(.icClose24),
            rightButtonAction: closeButtonTapped
        )
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
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
        let selectClipViewController = ViewControllerFactory.shared.makeSelectClipVC()
        selectClipViewController.linkURL = addLinkView.linkEmbedTextField.text ?? ""
        selectClipViewController.delegate = self
        self.navigationController?.pushViewController(selectClipViewController, animated: true)
    }
    
}

extension AddLinkViewController {
    private func bindViewModels() {
        let embedLinkText = addLinkView.linkEmbedTextField
            .publisher(for: .editingChanged)
            .compactMap { [weak self] _ in self?.addLinkView.linkEmbedTextField.text ?? "" }
            .eraseToAnyPublisher()
        
        let clearButtonTapped = addLinkView.clearButton.publisher(for: .touchUpInside)
            .mapVoid()
        
        let input = AddLinkViewModel.Input(embedLinkText: embedLinkText, clearButtonTapped: clearButtonTapped)
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.isClearButtonHidden
            .sink { [weak self] isHidden in
                self?.addLinkView.clearButton.isHidden = isHidden
            }
            .store(in: cancelBag)
        
        output.isNextButtonEnabled
            .sink { [weak self] isEnabled in
                self?.addLinkView.nextTopButton.isEnabled = isEnabled
                self?.addLinkView.nextTopButton.backgroundColor = isEnabled ? .black850 : .gray200
                self?.addLinkView.nextBottomButton.isEnabled = isEnabled
                self?.addLinkView.nextBottomButton.backgroundColor = isEnabled ? .black850 : .gray200
            }
            .store(in: cancelBag)
        
        output.linkEffectivenessMessage
            .sink { [weak self] message in
                if let errorMessage = message {
                    self?.addLinkView.isValidLinkError(errorMessage)
                    self?.addLinkView.linkEmbedTextField.layer.borderColor = UIColor.toasterError.cgColor
                    self?.addLinkView.linkEmbedTextField.layer.borderWidth = 1
                } else {
                    self?.addLinkView.resetError()
                    self?.addLinkView.linkEmbedTextField.layer.borderColor = UIColor.clear.cgColor
                }
            }
            .store(in: cancelBag)
    }
}

extension AddLinkViewController: SaveLinkButtonDelegate {
    func saveLinkButtonTapped() {
        delegate?.changeTabBarIndex()
    }
    
    func cancleLinkButtonTapped() {
        delegate?.changeTabBarIndex()
    }
}

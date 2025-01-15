//
//  RemindTimerAddViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 1/11/24.
//

import UIKit

import SnapKit
import Then

enum RemindTimerAddButtonType {
    case add, edit
}

final class RemindTimerAddViewController: UIViewController {
    
    // MARK: - View Controllable

    var onPopToRoot: (() -> Void)?
    
    // MARK: - Properties
    
    private let viewModel: RemindTimerAddViewModel!
    
    private let labelDateformatter = DateFormatter()
    private let networkDateformatter = DateFormatter()
    private var buttonType: RemindTimerAddButtonType = .add
    private var timerID: Int?
    private var categoryID: Int?
    private var selectedIndex: Set<Int> = [] {
        didSet {
            repeatButtonLabel.text = selectedIndex.fetchDaysString()
            repeatButtonLabel.textColor = .toasterPrimary
            repeatButtonLabel.font = .suitBold(size: 16)
            setupButton(forEnable: !selectedIndex.isEmpty)
        }
    }
    
    // MARK: - UI Properties
    
    private lazy var verticalStackView: UIStackView = createStackView(forAxis: .vertical, forSpacing: 18)
    
    private lazy var labelStackView: UIStackView = createStackView(forAxis: .vertical, forSpacing: 8, forAlignment: .leading)
    private let mainLabel: UILabel = UILabel()
    
    private lazy var subLabelStackView: UIStackView = createStackView(forAxis: .horizontal, forSpacing: 2)
    private let subLabel: UILabel = UILabel()
    private let timerView: UIView = UIView()
    private let timerLabel: UILabel = UILabel()
    
    private lazy var pickerStackView: UIStackView = createStackView(forAxis: .vertical, forSpacing: 0, forAlignment: .center)
    private let firstDividingView: UIView = UIView()
    private let datePickerView: UIDatePicker = UIDatePicker()
    private let secondDividingView: UIView = UIView()
    
    private lazy var repeatStackView: UIStackView = createStackView(forAxis: .vertical, forSpacing: 12, forAlignment: .fill)
    private let repeatLabel: UILabel = UILabel()
    private let setupRepeatButton: UIButton = UIButton()
    private let repeatButtonLabel: UILabel = UILabel()
    private let repeatButtonImageView: UIImageView = UIImageView(image: .icArrow18)
    
    private let completeButton: UIButton = UIButton()
    
    // MARK: - Life Cycle
    
    init(viewModel: RemindTimerAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
}

// MARK: - Extension

extension RemindTimerAddViewController {
    func configureView(forModel: RemindClipModel?) {
        buttonType = .add
        if let forModel {
            mainLabel.text = "\(forModel.title) 클립을"
            mainLabel.font = .suitMedium(size: 18)
            mainLabel.asFont(targetString: forModel.title,
                             font: .suitSemiBold(size: 18))
            categoryID = forModel.id
        }
    }
    
    func configureView(forTimerID: Int) {
        buttonType = .edit
        viewModel.fetchClipData(forID: forTimerID)
        timerID = forTimerID
    }
}

// MARK: - Private Extension

private extension RemindTimerAddViewController {
    func setupStyle() {
        view.backgroundColor = .toasterBackground
        selectedIndex = []
        
        labelDateformatter.do {
            $0.dateFormat = "a hh시 mm분"
            $0.locale = Locale(identifier: "ko_KR")
        }
        
        networkDateformatter.do {
            $0.dateFormat = "HH:mm"
            $0.locale = Locale(identifier: "ko_KR")
        }
        
        mainLabel.do {
            $0.textColor = .toasterBlack
        }
        
        timerView.do {
            $0.makeRounded(radius: 4)
            $0.backgroundColor = .toaster100
        }
        
        timerLabel.do {
            $0.font = .suitBold(size: 18)
            $0.textColor = .toasterPrimary
            $0.text = labelDateformatter.string(from: Date())
        }
        
        subLabel.do {
            $0.text = "에 리마인드 해드릴게요"
            $0.font = .suitMedium(size: 18)
            $0.textColor = .toasterBlack
        }
        
        [firstDividingView, secondDividingView].forEach {
            $0.do {
                $0.backgroundColor = .gray50
            }
        }
        
        datePickerView.do {
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            $0.locale = Locale(identifier: "ko_KR")
            $0.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
        }
        
        repeatLabel.do {
            $0.text = "반복 주기를 정해주세요"
            $0.font = .suitMedium(size: 18)
            $0.textColor = .toasterBlack
        }
        
        setupRepeatButton.do {
            $0.makeRounded(radius: 12)
            $0.backgroundColor = .toasterWhite
            $0.titleLabel?.font = .suitSemiBold(size: 16)
            $0.addTarget(self, action: #selector(repeatButtonTapped), for: .touchUpInside)
        }
        
        repeatButtonLabel.do {
            $0.text = "반복"
            $0.font = .suitSemiBold(size: 16)
            $0.textColor = .black850
        }
        
        completeButton.do {
            $0.makeRounded(radius: 12)
            $0.setTitle(StringLiterals.Button.complete, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.titleLabel?.font = .suitSemiBold(size: 16)
            
            $0.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(verticalStackView, completeButton)
        
        verticalStackView.addArrangedSubviews(labelStackView, pickerStackView, repeatStackView)
        
        labelStackView.addArrangedSubviews(mainLabel, subLabelStackView)
        pickerStackView.addArrangedSubviews(firstDividingView, datePickerView, secondDividingView)
        repeatStackView.addArrangedSubviews(repeatLabel, setupRepeatButton)
        subLabelStackView.addArrangedSubviews(timerView, subLabel)
        setupRepeatButton.addSubviews(repeatButtonLabel, repeatButtonImageView)
        timerView.addSubview(timerLabel)
    }
    
    func setupLayout() {
        verticalStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        setupRepeatButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        completeButton.snp.makeConstraints {
            $0.height.equalTo(62)
            $0.bottom.equalToSuperview().inset(34)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        timerView.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalTo(134)
        }
        
        timerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        [labelStackView, repeatStackView].forEach {
            $0.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(20)
            }
        }
        
        pickerStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
        }
        
        datePickerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        [firstDividingView, secondDividingView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(4)
                $0.horizontalEdges.equalToSuperview()
            }
        }
        
        repeatButtonLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(14)
        }
        
        repeatButtonImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(14)
        }
    }
    
    func setupViewModel() {
        viewModel.setupDataChangeAction(changeAction: configureView, 
                                        forSuccessAction: patchSuccessAction, 
                                        forEditSuccessAction: editSuccessAction,
                                        forUnAuthorizedAction: unAuthorizedAction,
                                        forUnProcessableAction: unProcessableAction, 
                                        forBadRequestAction: badRequestAction)
    }
    
    func configureView() {
        if let data = self.viewModel.remindAddData {
            self.mainLabel.text = "\(data.clipTitle) 클립을"
            self.mainLabel.asFont(targetString: data.clipTitle,
                                  font: .suitSemiBold(size: 18))
            self.selectedIndex = Set(data.remindDates)
            
            let date = networkDateformatter.date(from: data.remindTime) ?? Date()
            timerLabel.text = labelDateformatter.string(from: date)
            datePickerView.date = date
        }
    }
    
    func unAuthorizedAction() {
        self.changeViewController(viewController: LoginViewController())
    }
    
    func patchSuccessAction() {
        onPopToRoot?()
        self.navigationController?.showToastMessage(width: 169, status: .check, message: StringLiterals.ToastMessage.completeSetTimer)
    }
    
    func editSuccessAction() {
        onPopToRoot?()
        self.navigationController?.showToastMessage(width: 169, status: .check, message: StringLiterals.ToastMessage.completeEditTimer)
    }
    
    func unProcessableAction() {
        self.showToastMessage(width: 297, status: .warning, message: StringLiterals.ToastMessage.noticeSetTimer)
    }
    
    func badRequestAction() {
        self.showToastMessage(width: 297, status: .warning, message: StringLiterals.ToastMessage.noticeMaxTimer)
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: true,
                                                                hasRightButton: true,
                                                                mainTitle: StringOrImageType.string("타이머 설정"),
                                                                rightButton: StringOrImageType.image(.icClose24),
                                                                rightButtonAction: closeButtonTapped)
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func createStackView(forAxis: NSLayoutConstraint.Axis,
                         forSpacing: CGFloat,
                         forAlignment: UIStackView.Alignment = .center) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = forAxis
        stackView.spacing = forSpacing
        stackView.alignment = forAlignment
        return stackView
    }
    
    /// 반복 설정 값에 따라 Button의 상태를 바꿔주는 함수
    func setupButton(forEnable: Bool) {
        completeButton.isEnabled = forEnable
        if forEnable {
            completeButton.backgroundColor = .toasterBlack
        } else {
            completeButton.backgroundColor = .gray200
        }
    }
    
    func closeButtonTapped() {
        showPopup(forMainText: "타이머 설정을 취소할까요?",
                  forSubText: "지금까지 진행한 타이머 설정이\n사라져요",
                  forLeftButtonTitle: StringLiterals.Button.close,
                  forRightButtonTitle: StringLiterals.Button.cancel,
                  forRightButtonHandler: makeTimerCancel)
    }
    
    func makeTimerCancel() {
        onPopToRoot?()
    }
    
    /// 매일, 주중, 주말 -> 요일 값으로 바꿔주기 위한 함수
    func setSelectedIndex(contains: Int,
                          deleteFirst: Int,
                          deleteSecond: Int) {
        if selectedIndex.contains(contains) {
            for i in deleteFirst...deleteSecond {
                self.selectedIndex.insert(i)
            }
            selectedIndex.remove(contains)
        }
    }
    
    @objc func pickerValueChanged() {
        let date = labelDateformatter.string(from: datePickerView.date)
        timerLabel.text = date
    }
    
    @objc func repeatButtonTapped() {
        let repeatView = TimerRepeatBottomSheetView()
        repeatView.setupDelegate(forDelegate: self)
        repeatView.setupSelectedIndex(forIndexList: selectedIndex)
        let exampleBottom = ToasterBottomSheetViewController(bottomType: .gray, 
                                                             bottomTitle: "반복설정",
                                                             insertView: repeatView)
        exampleBottom.setupSheetPresentation(bottomHeight: view.convertByHeightRatio(720))
        self.present(exampleBottom, animated: true)
    }
    
    @objc func completeButtonTapped() {
        let dateString = networkDateformatter.string(from: datePickerView.date)
        
        switch buttonType {
        case .add:
            guard let categoryID else { return }
            self.viewModel.postClipData(
                forClipID: categoryID,
                forModel: RemindTimerAddModel(
                    clipTitle: "",
                    remindTime: dateString,
                    remindDates: Array(selectedIndex)
                )
            )
        case .edit:
            guard let timerID else { return }
            self.viewModel.editClipData(
                forModel: RemindTimerEditModel(
                    remindID: timerID,
                    remindTime: dateString,
                    remindDates: Array(selectedIndex)
                )
            )
        }
    }
}

// MARK: - TimerRepeatBottomSheetDelegate

extension RemindTimerAddViewController: TimerRepeatBottomSheetDelegate {
    func nextButtonTapped(selectedList: Set<Int>) {
        selectedIndex = selectedList
        setSelectedIndex(contains: 8, deleteFirst: 1, deleteSecond: 7)
        setSelectedIndex(contains: 9, deleteFirst: 1, deleteSecond: 5)
        setSelectedIndex(contains: 10, deleteFirst: 6, deleteSecond: 7)
        
        dismiss(animated: true)
    }
}

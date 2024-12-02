//
//  SettingViewController.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/14/24.
//

import UIKit

import SnapKit
import Then

final class SettingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let userInfoView = MypageHeaderView()
    private let settingView = SettingView()

    private var isToggle: Bool? = UserDefaults.standard.object(forKey: "isAppAlarmOn") as? Bool {
        didSet {
            settingView.settingTableView.reloadData()
            setupWarningView()
            UserDefaults.standard.set(isToggle, forKey: "isAppAlarmOn")
        }
    }
    
    private var userName: String = "" {
        didSet {
            settingView.settingTableView.reloadData()
        }
    }

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
        setupWarningView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        fetchMysettings()
        fetchMypageInformation()
    }
}

// MARK: - Private Extensions

private extension SettingViewController {
    func setupStyle() {
        self.view.backgroundColor = .toasterBackground
    }

    func setupHierarchy() {
        view.addSubviews(userInfoView, settingView)
    }
    
    func setupLayout() {
        userInfoView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        userInfoView.seperatorView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        settingView.snp.makeConstraints {
            $0.top.equalTo(userInfoView.seperatorView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupDelegate() {
        settingView.settingTableView.dataSource = self
        settingView.settingTableView.delegate = self
    }
    
    func setupNavigationBar() {
        let type: ToasterNavigationType = ToasterNavigationType(hasBackButton: true,
                                                                hasRightButton: false,
                                                                mainTitle: StringOrImageType.string("설정"),
                                                                rightButton: StringOrImageType.image(.icSettings24),
                                                                rightButtonAction: {})
        
        if let navigationController = navigationController as? ToasterNavigationController {
            navigationController.setupNavigationBar(forType: type)
        }
    }
    
    func setupWarningView() {
        if let isToggle {
            if isToggle {
                settingView.settingTableView.snp.remakeConstraints {
                    $0.top.equalTo(userInfoView.seperatorView.snp.bottom)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            } else {
                settingView.settingTableView.snp.remakeConstraints {
                    $0.top.equalTo(settingView.alertWarningView.snp.bottom)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            }
        }
    }
    
    func fetchMysettings() {
        NetworkService.shared.userService.getSettingPage { [weak self] result in
            switch result {
            case .success(let response):
                if let responseData = response?.data {
                    self?.userName = responseData.nickname
                }
            case .unAuthorized, .networkFail:
                self?.changeViewController(viewController: LoginViewController())
            default:
                self?.changeViewController(viewController: LoginViewController())
            }
        }
    }
    
    func fetchSignOut() {
        NetworkService.shared.authService.postLogout { [weak self] result in
            switch result {
            case .success:
                let result = KeyChainService.deleteTokens(accessKey: Config.accessTokenKey, refreshKey: Config.refreshTokenKey)
                
                if result.access && result.refresh {
                    self?.showConfirmationPopup(forMainText: "로그아웃", forSubText: "로그아웃이 완료되었습니다", centerButtonTitle: StringLiterals.Button.okay, centerButtonHandler: self?.popupConfirmationButtonTapped)
                }
            case .notFound, .networkFail:
                print("🍞⛔️로그아웃 실패⛔️🍞")
                self?.showConfirmationPopup(forMainText: "네트워크 연결 오류", forSubText: "네트워크 오류로 로그아웃이 실패하였습니다", centerButtonTitle: StringLiterals.Button.okay, centerButtonHandler: nil)
            default:
                self?.showConfirmationPopup(forMainText: "네트워크 연결 오류", forSubText: "네트워크 오류로 로그아웃이 실패하였습니다", centerButtonTitle: StringLiterals.Button.okay, centerButtonHandler: nil)
                print("🍞⛔️로그아웃 실패⛔️🍞")
            }
        }
    }
    
    func deleteAccount() {
        NetworkService.shared.authService.deleteWithdraw { [weak self] result in
            switch result {
            case .success:
                let result = KeyChainService.deleteTokens(accessKey: Config.accessTokenKey, refreshKey: Config.refreshTokenKey)
                
                if result.access && result.refresh {
                    self?.changeViewController(viewController: LoginViewController())
                }
            case .notFound, .unProcessable, .networkFail:
                print("🍞⛔️회원탈퇴 실패⛔️🍞")
                self?.showConfirmationPopup(forMainText: "네트워크 연결 오류", forSubText: "네트워크 오류로 회원탈퇴가 실패하였습니다", centerButtonTitle: StringLiterals.Button.okay, centerButtonHandler: nil)
            default:
                print("🍞⛔️회원탈퇴 실패⛔️🍞")
                self?.showConfirmationPopup(forMainText: "네트워크 연결 오류", forSubText: "네트워크 오류로 회원탈퇴가 실패하였습니다", centerButtonTitle: StringLiterals.Button.okay, centerButtonHandler: nil)
            }
        }
    }
    
    func patchAlarmSetting(toggle: Bool) {
        NetworkService.shared.userService.patchPushAlarm(requestBody: PatchPushAlarmRequestDTO(allowedPush: toggle)) { result in
            switch result {
            case .success(let response):
                self.isToggle = response?.data?.isAllowed
                self.setupWarningView()
            case .notFound, .networkFail:
                self.changeViewController(viewController: LoginViewController())
            default: break
            }
        }
    }
    
    func fetchMypageInformation() {
        NetworkService.shared.userService.getMyPage { [weak self] result in
            switch result {
            case .success(let response):
                if let responseData = response?.data {
                    DispatchQueue.main.async { [weak self] in
                        self?.userInfoView.bindModel(model: MypageUserModel(nickname: responseData.nickname,
                                                                                profile: responseData.profile,
                                                                                allReadToast: responseData.allReadToast,
                                                                                thisWeekendRead: responseData.thisWeekendRead,
                                                                                thisWeekendSaved: responseData.thisWeekendSaved))
                    }
                }
            case .unAuthorized, .networkFail:
                self?.changeViewController(viewController: LoginViewController())
            default:
                print("default Fail")
            }
        }
    }
    
    func popupDeleteButtonTapped() {
        deleteAccount()
    }
    
    func popupConfirmationButtonTapped() {
        self.changeViewController(viewController: LoginViewController())
    }
}

// MARK: - TableView Delegate

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 4))
        sectionHeaderView.backgroundColor = .gray50
        if section != 0 { return sectionHeaderView }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                let urlString = "https://open.kakao.com/o/sfN9Fr4f"
                
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            case 2:
                let urlString = "https://hill-agenda-2b0.notion.site/0f83855ea17f4a67a3ff66b6507b229f"
                
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            case 3:
                fetchSignOut()
            default:
                return
            }
        } else if indexPath.section == 1 {
            self.showPopup(forMainText: "정말로 탈퇴하시겠어요?", forSubText: "회원 탈퇴 시 지금까지\n저장한 모든 링크가 사라져요.", forLeftButtonTitle: "네, 탈퇴할래요", forRightButtonTitle: "더 써볼래요", forLeftButtonHandler: self.popupDeleteButtonTapped, forRightButtonHandler: nil)
        }
    }
}

// MARK: - TableView DataSource

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.className, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            cell.configureCell(name: settingView.settingList[indexPath.row], sectionNumber: indexPath.section)
            if indexPath.row == 0 {
                cell.showSwitch()
                cell.setSwitchValueChangedHandler { isOn in
                    self.patchAlarmSetting(toggle: isOn)
                }
            }
        default:
            cell.hiddenSwitch()
            cell.configureCell(name: "탈퇴하기", sectionNumber: indexPath.section)
        }
        return cell
    }
}

//
//  LoginViewController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import UIKit

import SnapKit
import Then

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var onLoginCompleted: (() -> Void)?
    
    var loginUseCase: LoginUseCase?
    private var currentIndex = 0
    
    // MARK: - UI Properties
    
    private let kakaoSocialLoginButtonView = SocialLoginButtonView(type: .kakao)
    private let appleSocialLoginButtonView = SocialLoginButtonView(type: .apple)
    private let socialLoginButtonStackView = UIStackView()
    private let onboardingPageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private let customPageIndicatorView = CustomPageIndicatorView()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
        setupAddTarget()
        selectedViewControllerSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
}

// MARK: - Private Extensions

private extension LoginViewController {
    func setupStyle() {
        view.backgroundColor = .gray50

        socialLoginButtonStackView.do {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 12
        }
    }
    
    func setupHierarchy() {
        addChild(onboardingPageViewController)
        view.addSubviews(onboardingPageViewController.view, customPageIndicatorView, socialLoginButtonStackView)
        socialLoginButtonStackView.addArrangedSubviews(appleSocialLoginButtonView, kakaoSocialLoginButtonView)
    }

    func setupLayout() {
        onboardingPageViewController.view.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customPageIndicatorView.snp.top)
        }
        
        customPageIndicatorView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(socialLoginButtonStackView.snp.top).inset(view.convertByHeightRatio(-52))
            $0.height.equalTo(8)
        }
          
        socialLoginButtonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(view.convertByHeightRatio(26))
            $0.height.equalTo(136) // Button height(62 * 2) + StackView Spacing(12)
        }
        
        onboardingPageViewController.didMove(toParent: self)
    }
    
    private func setupDelegate() {
        onboardingPageViewController.dataSource = self
        onboardingPageViewController.delegate = self
    }
    
    func setupAddTarget() {
        kakaoSocialLoginButtonView.addTarget(self, action: #selector(kakaoButtonTapped), for: .touchUpInside)
        appleSocialLoginButtonView.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
    }
    
    /// 할당된 Social Login Adapter 를  통해 loginUseCase 로 Login 실행
    /// - Returns: SocialLogin 을 통해 반환받은 Token 을 SocialLoginTokenModel 로 반환,
    /// Social Login Adapter 가 할당되지 않았을 때 LoginError 반환
    func attemptLogin() async throws -> SocialLoginTokenModel {
        guard let loginUseCase else {
            throw LoginError.notSettingUsecase
        }
        
        do {
            let result = try await loginUseCase.login()
            return result
        } catch let error {
            print("Login Error:", error.localizedDescription)
            throw LoginError.failedReceiveToken
        }
    }
    
    /// 회원가입/로그인 API 요청을 위한 메서드
    /// - Parameters:
    ///   - token: Social Login 을 통해 전달받은 AccessToken
    ///   - socialType: Social Login Tpye ( KAKAO, APPLE )
    /// - Returns: Token 을 KeyChain 에 저장하여 최종적으로 Login 성공시 true,
    /// 서버 통신 중 NetworkResult 타입에 의거하여 success 이외 에 따른 결과는 false,
    /// 서버 통신 결과값을 Decoding 하는 과정 중 생길 수 있는 오류를 LoginError 타입으로 반환
    func fetchTokenSocialLogin(token: String, socialType: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
        
            NetworkService.shared.authService.postSocialLogin(
                socialToken: token,
                requestBody: PostSocialLoginRequestDTO(
                    socialType: socialType,
                    fcmToken: KeyChainService.loadFCMToken(key: Config.fcmTokenKey) ?? ""
                )
            ) { result in
                switch result {
                case .success(let response):
                    /// Decoding 하는 과정 중 생길 수 있는 오류
                    guard let serverAccessToken = response?.data.accessToken, let serverRefreshToken = response?.data.refreshToken else { return continuation.resume(throwing: LoginError.failedReceiveToken) }
                    
                    let keyChainResult = KeyChainService.saveTokens(accessKey: serverAccessToken, refreshKey: serverRefreshToken)
                    
                    if keyChainResult.accessResult == true && keyChainResult.refreshResult == true {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                case .decodeErr, .networkFail:
                    continuation.resume(returning: false)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func createOnboardingViewController(index: Int) -> OnboardingViewController? {
        guard index >= 0, index < OnboardingType.allCases.count else { return nil }
        let onboardType = OnboardingType.allCases[index]
        return OnboardingViewController(onboardType: onboardType)
    }

    // MARK: - @objc
    
    @objc func kakaoButtonTapped() {
        loginUseCase = LoginUseCase(adapter: KakaoAuthenticateAdapter())
        
        Task {
            do {
                let result = try await attemptLogin()
                
                guard let kakaoAccessToken = result.accessToken else { return print("Kakao Login Error:", LoginError.failedReceiveToken) }
                
                let serverResult = try await fetchTokenSocialLogin(token: kakaoAccessToken, socialType: "KAKAO")
        
                if serverResult == true {
                    UserDefaults.standard.set("\(Config.kakaoLogin)", forKey: Config.loginType)
                    onLoginCompleted?()
                }
            } catch {
                guard let error = error as? LoginError else { return }
                switch error {
                case .notSettingUsecase:
                    print(error.description)
                case .failedReceiveToken:
                    print(error.description)
                }
            }
        }
    }
    
    @objc func appleButtonTapped() {
        loginUseCase = LoginUseCase(adapter: AppleAuthenticateAdapter())
        
        Task {
            do {
                let result = try await attemptLogin()
                
                guard let appleIdentityToken = result.identityToken else { return print("Apple Login Error:", LoginError.failedReceiveToken) }
                
                let serverResult = try await fetchTokenSocialLogin(token: appleIdentityToken, socialType: "APPLE")
                
                if serverResult == true {
                    UserDefaults.standard.set(Config.appleLogin, forKey: Config.loginType)
                    onLoginCompleted?()
                }
            } catch let error {
                print("Apple Login Error:", error)
            }
        }
    }
}

// MARK: - UIPageViewController Delegate

extension LoginViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // 이전 페이지를 가져오는 메서드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingViewController, let currentIndex = OnboardingType.allCases.firstIndex(of: currentVC.onboardType), currentIndex > 0 else { return nil }

        let newIndex = currentIndex - 1
        return createOnboardingViewController(index: newIndex)
    }
    
    // 다음 페이지를 가져오는 메서드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingViewController, let currentIndex = OnboardingType.allCases.firstIndex(of: currentVC.onboardType), currentIndex < OnboardingType.allCases.count - 1  else { return nil }
                
        let newIndex = currentIndex + 1
        return createOnboardingViewController(index: newIndex)
    }
    
    // 페이지 전환 애니메이션이 완료되었을 때 호출되는 메서드
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentVC = pageViewController.viewControllers?.first as? OnboardingViewController, let currentIndex = OnboardingType.allCases.firstIndex(of: currentVC.onboardType) else {
            return
        }
        self.currentIndex = currentIndex
        customPageIndicatorView.changeCurrentPageIndex(index: currentIndex)
    }
    
    // 초기 화면을 설정하는 메서드
    func selectedViewControllerSetting() {
        if let selectViewController = createOnboardingViewController(index: 0) {
            onboardingPageViewController.setViewControllers([selectViewController], direction: .forward, animated: false)
        }
    }
}

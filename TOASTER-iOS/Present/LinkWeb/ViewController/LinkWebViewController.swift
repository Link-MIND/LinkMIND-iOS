//
//  LinkWebViewController.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/11/24.
//

import UIKit
import WebKit

import SnapKit
import Then

final class LinkWebViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = LinkWebViewModel()
    private var cancelBag = CancelBag()
    
    private var progressObservation: NSKeyValueObservation?
    private var toastId: Int?
    
    // MARK: - UI Properties
    
    private let navigationView = LinkWebNavigationView()
    private let progressView = UIProgressView()
    private let webView = WKWebView()
    private let toolBar = LinkWebToolBarView()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModels()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupNavigationBarAction()
        setupToolBarAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar()
    }
    
    deinit {
        progressObservation?.invalidate()
    }
}

// MARK: - Extensions

extension LinkWebViewController {
    func setupDataBind(linkURL: String, isRead: Bool? = nil, id: Int? = nil) {
        if let url = URL(string: linkURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        guard let isRead, let id else { return }
        toolBar.updateIsRead(isRead)
        self.toastId = id
    }
}

// MARK: - Private Extensions

private extension LinkWebViewController {
    func bindViewModels() {
        let readLinkButtonTapped = toolBar.readLinkButtonTap
            .map { _ in
                LinkReadEditModel(toastId: self.toastId ?? 0, isRead: !self.toolBar.isRead)
            }
            .eraseToAnyPublisher()
        
        let input = LinkWebViewModel.Input(
            readLinkButtonTapped: readLinkButtonTapped
        )
        
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        output.isRead
            .sink { [weak self] isRead in
                let mesage = isRead ? StringLiterals.ToastMessage.completeReadLink : StringLiterals.ToastMessage.cancelReadLink
                self?.showToastMessage(width: 152, status: .check, message: mesage)
                self?.toolBar.updateIsRead(isRead)
            }.store(in: cancelBag)
        
        output.navigateToLogin
            .sink { [weak self] _ in
                self?.changeViewController(viewController: LoginViewController())
            }.store(in: cancelBag)
    }
    
    func setupStyle() {
        view.bringSubviewToFront(progressView)
        view.backgroundColor = .toasterWhite
        
        progressView.do {
            $0.tintColor = .toasterPrimary
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        webView.do {
            $0.navigationDelegate = self
            progressObservation = $0.observe(
                \.estimatedProgress,
                 options: [.new]) { [weak self] object, _ in
                     let progress = Float(object.estimatedProgress)
                     self?.progressView.progress = progress
                 }
        }
    }
    
    func setupHierarchy() {
        view.addSubviews(navigationView, progressView, webView, toolBar)
    }
    
    func setupLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        webView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(toolBar.snp.top)
        }
        
        toolBar.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(42)
        }
    }
    
    func setupNavigationBarAction() {
        /// 네비게이션바 뒤로가기 버튼 클릭 액션 클로저
        navigationView.popButtonTapped {
            self.navigationController?.popViewController(animated: true)
            self.showNavigationBar()
        }
        
        /// 네비게이션바 새로고침 버튼 클릭 액션 클로저
        navigationView.reloadButtonTapped { self.webView.reload() }
    }
    
    func setupToolBarAction() {
        /// 툴바 뒤로가기 버튼 클릭 액션 클로저
        toolBar.backButtonTapped {
            if self.webView.canGoBack { self.webView.goBack() }
        }
        
        /// 툴바 앞으로가기 버튼 클릭 액션 클로저
        toolBar.forwardButtonTapped {
            if self.webView.canGoForward { self.webView.goForward() }
        }
        
        /// 툴바 공유 버튼 클릭 액션 클로저
        toolBar.shareButtonTapped {
            guard let url = self.webView.url else { return }
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        /// 툴바 사파리 버튼 클릭 액션 클로저
        toolBar.safariButtonTapped {
            if let url = self.webView.url { UIApplication.shared.open(url) }
        }
    }
}

// MARK: - WKNavigationDelegate Extensions

extension LinkWebViewController: WKNavigationDelegate {
    /// 현재 웹 페이지 링크를 받아오는 함수
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            navigationView.setupLinkAddress(link: url)
        }
        toolBar.updateCanGoBack(webView.canGoBack)
        toolBar.updateCanGoForward(webView.canGoForward)
    }
    
    /// 웹 페이지 로딩이 완료되었을 때 호출
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    /// 웹 페이지 로딩이 시작할 때 호출
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
}

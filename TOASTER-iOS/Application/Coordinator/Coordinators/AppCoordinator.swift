//
//  AppCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import UIKit

final class AppCoordinator: BaseCoordinator {
    private let router: RouterProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    private var isLoggedIn: Bool
    private let updateAlertManager = UpdateAlertManager()
    
    init(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        isLoggedIn: Bool
    ) {
        self.router = router
        self.viewControllerFactory = viewControllerFactory
        self.isLoggedIn = isLoggedIn
    }
    
    override func start() {
        checkForUpdates()
        if isLoggedIn {
            setTabBarRootVC()
        } else {
            setLoginRootVC()
        }
    }
    
    func handlePasteboardURL() {
        if let pasteboardUrl = UIPasteboard.general.url, isLoggedIn {
            let addLinkVC = viewControllerFactory.makeAddLinkVC()
            addLinkVC.embedURL(url: pasteboardUrl.absoluteString)
            router.push(addLinkVC, animated: true)
        }
        UIPasteboard.general.url = nil
    }
}

private extension AppCoordinator {
    func setLoginRootVC() {
        let vc = viewControllerFactory.makeLoginVC()
        router.setRoot(vc, animated: true)
    }
    
    func setTabBarRootVC() {
        let vc = viewControllerFactory.makeTabBarVC()
        router.setRoot(vc, animated: true)
    }
    
    func checkForUpdates() {
        Task {
            if let rootViewController = router.rootViewController,
               let updateStatus = await updateAlertManager.checkUpdateAlertNeeded() {
                updateAlertManager.showUpdateAlert(type: updateStatus, on: rootViewController)
            }
        }
    }
}

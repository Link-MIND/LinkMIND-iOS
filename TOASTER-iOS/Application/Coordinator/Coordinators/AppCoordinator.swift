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
    private let coordinatorFactory: CoordinatorFactoryProtocol

    private var isLoggedIn: Bool
    private let updateAlertManager = UpdateAlertManager()
    
    init(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol,
        isLoggedIn: Bool
    ) {
        self.router = router
        self.viewControllerFactory = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
        self.isLoggedIn = isLoggedIn
    }
    
    override func start() {
        checkForUpdates()
        isLoggedIn ? setTabBarRootVC() : setLoginRootVC()
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
        let coordinator = coordinatorFactory.makeLoginCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func setTabBarRootVC() {
        let coordinator = coordinatorFactory.makeTabBarCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func checkForUpdates() {
//        Task {
//            if let rootViewController = router.rootViewController,
//               let updateStatus = await updateAlertManager.checkUpdateAlertNeeded() {
//                updateAlertManager.showUpdateAlert(type: updateStatus, on: rootViewController)
//            }
//        }
    }
}

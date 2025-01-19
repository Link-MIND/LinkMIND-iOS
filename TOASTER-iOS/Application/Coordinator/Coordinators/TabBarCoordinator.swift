//
//  TabBarCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import UIKit

typealias Scene = ((UINavigationController) -> Void)

final class TabBarCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
    var onFinish: (() -> Void)?
    
    private let router: RouterProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    private let coordinatorFactory: CoordinatorFactoryProtocol
    private var tabBarController: TabBarController?
    
    init(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) {
        self.router = router
        self.viewControllerFactory = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        if tabBarController == nil { setupTabBarController() }
        guard let tabBarController else { return }
        tabBarController.selectTab(0)
        router.setRoot(tabBarController, animated: false)
    }
}

private extension TabBarCoordinator {
    func setupTabBarController() {
        let vc = viewControllerFactory.makeTabBarVC()
        
        vc.onHomeScene = { [weak self] navController in
            self?.startHomeCoordinator(navController: navController)
        }
        vc.onClipScene = { [weak self] navController in
            self?.startClipCoordinator(navController: navController)
        }
        vc.onSearchScene = { [weak self] navController in
            self?.startSearchCoordinator(navController: navController)
        }
        vc.onTimerScene = { [weak self] navController in
            self?.startTimerCoordinator(navController: navController)
        }
        vc.didSelectPlusTab = { [weak self] in
            self?.handlePlusTabSelection()
        }
        self.tabBarController = vc
    }
    
    func startHomeCoordinator(navController: UINavigationController) {
        let coordinator = coordinatorFactory.makeHomeCoordinator(
            router: Router(rootViewController: navController),
            viewControllerFactory: self.viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.onFinish?()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func startClipCoordinator(navController: UINavigationController) {
        let coordinator = coordinatorFactory.makeClipCoordinator(
            router: Router(rootViewController: navController),
            viewControllerFactory: self.viewControllerFactory,
            coordinatorFactory: self.coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func startSearchCoordinator(navController: UINavigationController) {
        let coordinator = coordinatorFactory.makeSearchCoordinator(
            router: Router(rootViewController: navController),
            viewControllerFactory: self.viewControllerFactory,
            coordinatorFactory: self.coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func startTimerCoordinator(navController: UINavigationController) {
        let coordinator = coordinatorFactory.makeTimerCoordinator(
            router: Router(rootViewController: navController),
            viewControllerFactory: self.viewControllerFactory,
            coordinatorFactory: self.coordinatorFactory
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.onFinish?()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
    
    func handlePlusTabSelection() {
        let vc = viewControllerFactory.makeAddLinkVC(isNavigationBarHidden: false)
        vc.onLinkInputCompleted = { [weak self] linkURL in
            self?.showSelectClipVC(linkURL: linkURL)
        }
        vc.onPopToRoot = { [weak self] in
            self?.router.popToRoot(animated: false)
        }
        router.push(vc, animated: false)
    }
    
    func showSelectClipVC(linkURL: String) {
        let vc = ViewControllerFactory.shared.makeSelectClipVC(isNavigationBarHidden: false)
        vc.linkURL = linkURL
        vc.onPopToRoot = { [weak self] in
            self?.router.popToRoot(animated: false)
        }
        router.push(vc, animated: true)
    }
}

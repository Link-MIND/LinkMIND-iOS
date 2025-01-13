//
//  LoginCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/10/25.
//

import UIKit

final class LoginCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
    var onFinish: (() -> Void)?

    private let router: RouterProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    private let coordinatorFactory: CoordinatorFactoryProtocol
    
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
        showLoginVC()
    }
}

private extension LoginCoordinator {
    func showLoginVC() {
        let vc = viewControllerFactory.makeLoginVC()
        vc.onLoginCompleted = { [weak self] in
            self?.loginVCCompleted()
        }
        router.setRoot(vc, animated: true)
    }
    
    func loginVCCompleted() {
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
}

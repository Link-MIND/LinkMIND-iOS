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
    private var tabBarController: UITabBarController?
    
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
        router.setRoot(vc, animated: true)
    }
}

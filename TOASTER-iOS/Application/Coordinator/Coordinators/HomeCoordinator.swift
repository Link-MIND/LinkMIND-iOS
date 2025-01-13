//
//  HomeCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class HomeCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
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
        showHomeVC()
    }
}

private extension HomeCoordinator {
    func showHomeVC() {
        let vc = viewControllerFactory.makeHomeVC()
        router.setRoot(vc, animated: true)
    }
}

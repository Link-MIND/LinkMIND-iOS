//
//  HomeCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class HomeCoordinator: BaseCoordinator {
    private let router: RouterProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    init(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) {
        self.router = router
        self.viewControllerFactory = viewControllerFactory
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

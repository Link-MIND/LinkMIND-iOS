//
//  TimerCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class TimerCoordinator: BaseCoordinator {
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
        showRemindVC()
    }
}

private extension TimerCoordinator {
    func showRemindVC() {
        let vc = viewControllerFactory.makeRemindVC()
        router.setRoot(vc, animated: false)
    }
}

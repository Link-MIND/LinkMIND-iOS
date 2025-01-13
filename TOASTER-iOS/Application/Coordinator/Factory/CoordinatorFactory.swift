//
//  CoordinatorFactory.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import UIKit

protocol CoordinatorFactoryProtocol {
    func makeTabBarCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> TabBarCoordinator
    
    func makeHomeCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> HomeCoordinator
    
    func makeClipCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> ClipCoordinator
    
    func makeSearchCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> SearchCoordinator
    
    func makeTimerCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> TimerCoordinator
}

final class CoordinatorFactory: CoordinatorFactoryProtocol {
    func makeTabBarCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> TabBarCoordinator {
        return TabBarCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
    
    func makeHomeCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> HomeCoordinator {
        return HomeCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory
        )
    }
    
    func makeClipCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> ClipCoordinator {
        return ClipCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory
        )
    }
    
    func makeSearchCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> SearchCoordinator {
        return SearchCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory
        )
    }
    
    func makeTimerCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol
    ) -> TimerCoordinator {
        return TimerCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory
        )
    }
}

private extension CoordinatorFactory {
    func router(_ navigationController: UINavigationController?) -> RouterProtocol {
        return Router(rootViewController: navigationController)
    }
}

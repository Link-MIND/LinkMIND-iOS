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
    
    func makeLoginCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> LoginCoordinator
    
    func makeHomeCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> HomeCoordinator
    
    func makeClipCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> ClipCoordinator
    
    func makeAddLinkCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol,
        isNavigationBarHidden: Bool
    ) -> AddLinkCoordinator
    
    func makeSearchCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> SearchCoordinator
    
    func makeTimerCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
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
    
    func makeLoginCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> LoginCoordinator {
        return LoginCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
    
    func makeHomeCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> HomeCoordinator {
        return HomeCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
    
    func makeClipCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> ClipCoordinator {
        return ClipCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
    
    func makeAddLinkCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol,
        isNavigationBarHidden: Bool
    ) -> AddLinkCoordinator {
        return AddLinkCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
    
    func makeSearchCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> SearchCoordinator {
        return SearchCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
    
    func makeTimerCoordinator(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol
    ) -> TimerCoordinator {
        return TimerCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory
        )
    }
}

private extension CoordinatorFactory {
    func router(_ navigationController: UINavigationController?) -> RouterProtocol {
        return Router(rootViewController: navigationController)
    }
}

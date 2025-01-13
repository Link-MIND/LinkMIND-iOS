//
//  SearchCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class SearchCoordinator: BaseCoordinator {
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
        showSearchVC()
    }
}

private extension SearchCoordinator {
    func showSearchVC() {
        let vc = viewControllerFactory.makeSearchVC()
        router.setRoot(vc, animated: false)
    }
}

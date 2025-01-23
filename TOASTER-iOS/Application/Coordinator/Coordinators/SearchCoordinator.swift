//
//  SearchCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class SearchCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
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
        showSearchVC()
    }
}

private extension SearchCoordinator {
    func showSearchVC() {
        let vc = viewControllerFactory.makeSearchVC()
        vc.onLinkItemSelected = { [weak self] linkURL, isRead, id in
            self?.showLinkWebVC(linkURL: linkURL, isRead: isRead, id: id)
        }
        vc.onClipItemSelected = { [weak self] id, name in
            self?.showDetailClipVC(id: id, name: name)
        }
        router.setRoot(vc, animated: false)
    }
    
    func showDetailClipVC(id: Int, name: String) {
        let vc = viewControllerFactory.makeDetailClipVC()
        vc.setupCategory(id: id, name: name)
        vc.onLinkSelected = { [weak self] linkURL, isRead, id in
            self?.showLinkWebVC(linkURL: linkURL, isRead: isRead, id: id)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showLinkWebVC(linkURL: String, isRead: Bool, id: Int) {
        let vc = viewControllerFactory.makeLinkWebVC()
        vc.setupDataBind(linkURL: linkURL, isRead: isRead, id: id)
        vc.onBack = { [weak self] in
            self?.router.pop(animated: true)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
}

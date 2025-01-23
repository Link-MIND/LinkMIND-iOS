//
//  AddLinkCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/15/25.
//

import Foundation

final class AddLinkCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
    var onFinish: (() -> Void)?

    private let router: RouterProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    private let coordinatorFactory: CoordinatorFactoryProtocol
    private let isNavigationBarHidden: Bool
    
    init(
        router: RouterProtocol,
        viewControllerFactory: ViewControllerFactoryProtocol,
        coordinatorFactory: CoordinatorFactoryProtocol,
        isNavigationBarHidden: Bool
    ) {
        self.router = router
        self.viewControllerFactory = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
        self.isNavigationBarHidden = isNavigationBarHidden
    }
    
    override func start() {
        showAddLinkVC()
    }
}

private extension AddLinkCoordinator {
    func showAddLinkVC() {
        let vc = viewControllerFactory.makeAddLinkVC(isNavigationBarHidden: isNavigationBarHidden)
        vc.onLinkInputCompleted = { [weak self] linkURL in
            self?.showSelectClipVC(linkURL: linkURL)
        }
        vc.onPopToRoot = { [weak self] in
            self?.router.dismiss(animated: false, completion: {
                self?.onFinish?()
            })
        }
        router.setRoot(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showSelectClipVC(linkURL: String) {
        let vc = ViewControllerFactory.shared.makeSelectClipVC(isNavigationBarHidden: isNavigationBarHidden)
        vc.linkURL = linkURL
        vc.onPopToRoot = { [weak self] in
            self?.router.dismiss(animated: false, completion: {
                self?.onFinish?()
            })
        }
        router.push(vc, animated: true)
    }
}

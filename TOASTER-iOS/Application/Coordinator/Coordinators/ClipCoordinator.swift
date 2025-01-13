//
//  ClipCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import Foundation

final class ClipCoordinator: BaseCoordinator {
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
        showClipVC()
    }
}

private extension ClipCoordinator {
    func showClipVC() {
        let vc = viewControllerFactory.makeClipVC()
        vc.onEditClipSelected = { [weak self] clipList in
            self?.showEditClipVC(clipList: clipList)
        }
        router.setRoot(vc, animated: false)
    }
    
    func showEditClipVC(clipList: ClipModel) {
        let vc = viewControllerFactory.makeEditClipVC()
        vc.setupDataBind(clipModel: clipList)
        router.push(vc, animated: false, hideBottomBarWhenPushed: true)
    }
}

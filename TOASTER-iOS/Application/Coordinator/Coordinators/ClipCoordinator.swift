//
//  ClipCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import Foundation

final class ClipCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
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
        showClipVC()
    }
}

private extension ClipCoordinator {
    func showClipVC() {
        let vc = viewControllerFactory.makeClipVC()
        vc.onEditClipSelected = { [weak self] clipList in
            self?.showEditClipVC(clipList: clipList)
        }
        vc.onClipItemSelected = { [weak self] clipId, clipName in
            self?.showDetailClipVC(id: clipId, name: clipName)
        }
        router.setRoot(vc, animated: false)
    }
    
    func showEditClipVC(clipList: ClipModel) {
        let vc = viewControllerFactory.makeEditClipVC()
        vc.setupDataBind(clipModel: clipList)
        router.push(vc, animated: false, hideBottomBarWhenPushed: true)
    }
    
    func showDetailClipVC(id: Int, name: String) {
        let vc = viewControllerFactory.makeDetailClipVC()
        vc.setupCategory(id: id, name: name)
        router.push(vc, animated: true)
    }
}

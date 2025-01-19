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
        vc.onMyLinkSelected = { [weak self] linkURL, isRead, id in
            self?.showLinkWebVC(linkURL: linkURL, isRead: isRead, id: id)
        }
        vc.onOurLinkSelected = { [weak self] linkURL in
            self?.showLinkWebVC(linkURL: linkURL, isRead: nil, id: nil)
        }
        vc.onSettingSelected = { [weak self] in
            self?.showSettingVC()
        }
        vc.onArrowSelected = { [weak self] id, name in
            self?.showDetailClipVC(id: id, name: name)
        }
        vc.onAddLinkSelected = { [weak self] in
            self?.startAddLinkCoordinator()
        }
        router.setRoot(vc, animated: false)
    }
    
    func showLinkWebVC(linkURL: String, isRead: Bool?, id: Int?) {
        let vc = viewControllerFactory.makeLinkWebVC()
        vc.setupDataBind(linkURL: linkURL, isRead: isRead, id: id)
        vc.onBack = { [weak self] in
            self?.router.pop(animated: true)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showSettingVC() {
        let vc = viewControllerFactory.makeSettingVC()
        vc.onChangeRoot = { [weak self] in
            self?.router.dismiss()
            self?.onFinish?()
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showDetailClipVC(id: Int, name: String) {
        let vc = viewControllerFactory.makeDetailClipVC()
        vc.setupCategory(id: id, name: name)
        vc.onLinkSelected = { [weak self] linkURL, isRead, id in
            self?.showLinkWebVC(linkURL: linkURL, isRead: isRead, id: id)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func startAddLinkCoordinator() {
        let coordinator = coordinatorFactory.makeAddLinkCoordinator(
            router: router,
            viewControllerFactory: viewControllerFactory,
            coordinatorFactory: coordinatorFactory,
            isNavigationBarHidden: true
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            self?.start()
        }
        self.addDependency(coordinator)
        coordinator.start()
    }
}

//
//  TimerCoordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/8/25.
//

import Foundation

final class TimerCoordinator: BaseCoordinator, CoordinatorFinishOutput {
    
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
        showRemindVC()
    }
}

private extension TimerCoordinator {
    func showRemindVC() {
        let vc = viewControllerFactory.makeRemindVC()
        vc.onRemindClipSelected = { [weak self] in
            self?.showRemindSelectClipVC()
        }
        vc.onEditTimerSelected = { [weak self] id in
            self?.showRemindTimerAddVC(id: id)
        }
        vc.onClipItemSelected = { [weak self] id, name in
            self?.showDetailClipVC(id: id, name: name)
        }
        vc.onSettingSelected = { [weak self] in
            self?.showSettingVC()
        }
        router.setRoot(vc, animated: false)
    }
    
    func showRemindSelectClipVC() {
        let vc = ViewControllerFactory.shared.makeRemindSelectClipVC()
        vc.onEditTimerSelected = { [weak self] model in
            self?.showRemindTimerAddVC(model: model)
        }
        vc.onPopToRoot = { [weak self] in
            self?.router.popToRoot(animated: true)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showRemindTimerAddVC(id: Int) {
        let vc = viewControllerFactory.makeRemindTimerAddVC()
        vc.configureView(forTimerID: id)
        vc.onPopToRoot = { [weak self] in
            self?.router.popToRoot(animated: true)
        }
        router.push(vc, animated: true, hideBottomBarWhenPushed: true)
    }
    
    func showRemindTimerAddVC(model: RemindClipModel?) {
        let vc = viewControllerFactory.makeRemindTimerAddVC()
        vc.configureView(forModel: model)
        vc.onPopToRoot = { [weak self] in
            self?.router.popToRoot(animated: true)
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
    
    func showLinkWebVC(linkURL: String, isRead: Bool, id: Int) {
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
}

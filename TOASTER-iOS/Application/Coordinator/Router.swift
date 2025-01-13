//
//  Router.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import UIKit

protocol RouterProtocol: AnyObject {
    func setRoot(_ viewController: UIViewController, animated: Bool)
    
    func push(_ viewController: UIViewController, animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool, hideBottomBarWhenPushed: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    func pop(animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

final class Router: RouterProtocol {
    private weak var rootViewController: UINavigationController?
        
    init(rootViewController: UINavigationController?) {
        self.rootViewController = rootViewController
    }
    
    func setRoot(_ viewController: UIViewController, animated: Bool) {
        rootViewController?.setViewControllers([viewController], animated: animated)
    }
    
    func push(_ viewController: UIViewController, animated: Bool) {
        rootViewController?.pushViewController(viewController, animated: animated)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        hideBottomBarWhenPushed: Bool
    ) {
        viewController.hidesBottomBarWhenPushed = hideBottomBarWhenPushed
        rootViewController?.pushViewController(viewController, animated: animated)
    }
    
    func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        rootViewController?.present(viewController, animated: animated, completion: completion)
    }
    
    func pop(animated: Bool) {
        rootViewController?.popViewController(animated: animated)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        rootViewController?.dismiss(animated: animated, completion: completion)
    }

}

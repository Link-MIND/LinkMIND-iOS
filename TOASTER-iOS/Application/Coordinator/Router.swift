//
//  Router.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import UIKit

protocol RouterProtocol: AnyObject {
    var rootViewController: UIViewController? { get }
    
    func setRoot(_ viewController: UIViewController, animated: Bool)
    
    func push(_ viewController: UIViewController, animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool, hideBottomBarWhenPushed: Bool)
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    func pop(animated: Bool)
    
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

final class Router: RouterProtocol {
    
    private weak var navigationController: UINavigationController?
    var rootViewController: UIViewController? { navigationController?.viewControllers.first }
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func setRoot(_ viewController: UIViewController, animated: Bool) {
        navigationController?.setViewControllers([viewController], animated: animated)
    }
    
    func push(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func push(
        _ viewController: UIViewController,
        animated: Bool,
        hideBottomBarWhenPushed: Bool
    ) {
        viewController.hidesBottomBarWhenPushed = hideBottomBarWhenPushed
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        navigationController?.present(viewController, animated: animated, completion: completion)
    }
    
    func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }

}

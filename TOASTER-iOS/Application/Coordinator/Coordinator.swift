//
//  Coordinator.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class BaseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    
    func addDependency(_ coordinator: Coordinator) {
        guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator?) {
        guard let index = childCoordinators.firstIndex(where: { $0 === coordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func start() {}
}

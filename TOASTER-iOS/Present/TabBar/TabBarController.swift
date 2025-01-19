//
//  TabBarController.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/30/23.
//

import UIKit

import SnapKit
import Then

// MARK: - Tab Bar

final class TabBarController: UITabBarController {
    
    private var customTabBar = CustomTabBar()
    private var currentIndex: Int?
    
    // MARK: - View Controllable
    
    var onHomeScene: Scene?
    var onClipScene: Scene?
    var onPlusScene: (() -> Void)?
    var onSearchScene: Scene?
    var onTimerScene: Scene?
 
    var didSelectPlusTab: (() -> Void)?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
}

// MARK: - Private Extensions

private extension TabBarController {

    func setupTabBar() {
        self.setValue(customTabBar, forKey: "tabBar")

        delegate = self
        view.backgroundColor = .toasterBackground
        tabBar.backgroundColor = .toasterWhite
        tabBar.unselectedItemTintColor = .gray150
        tabBar.tintColor = .black900
        
        self.viewControllers = [
            createNavigation(for: .home),
            createNavigation(for: .clip),
            createNavigation(for: .plus),
            createNavigation(for: .search),
            createNavigation(for: .timer)
        ]
    }
    
    func createNavigation(for item: TabBarItem) -> UINavigationController {
        let navController = ToasterNavigationController()
        navController.tabBarItem = createTabBarItem(for: item)
        return navController
    }
    
    func createTabBarItem(for item: TabBarItem) -> UITabBarItem {
        let tabBarItem = UITabBarItem(
            title: item.itemTitle,
            image: item.normalItem?.withRenderingMode(.alwaysOriginal),
            selectedImage: item.selectedItem?.withRenderingMode(.alwaysOriginal)
        )
        
        if item == .plus {
            tabBarItem.imageInsets = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.suitBold(size: 12),
            .foregroundColor: UIColor.gray150
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.suitBold(size: 12),
            .foregroundColor: UIColor.black900
        ]
        
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        tabBarItem.setTitleTextAttributes(normalAttributes, for: .normal)
        tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        return tabBarItem
    }
}

extension TabBarController {
    func selectTab(_ index: Int) {
        self.selectedIndex = index
        if let controller = self.viewControllers?[index] {
            self.tabBarController(self, didSelect: controller)
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let controller = viewController as? UINavigationController else { return }
        if currentIndex == selectedIndex { return }
        self.currentIndex = selectedIndex
        
        switch selectedIndex {
        case 0: onHomeScene?(controller)
        case 1: onClipScene?(controller)
        case 2: onPlusScene?()
        case 3: onSearchScene?(controller)
        case 4: onTimerScene?(controller)
        default: return
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == viewControllers?[2] {
            didSelectPlusTab?()
            selectedIndex = 0
            currentIndex = selectedIndex
            return false
        }
        return true
    }
}

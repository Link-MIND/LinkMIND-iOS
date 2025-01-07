//
//  ViewControllerFactory.swift
//  TOASTER-iOS
//
//  Created by 민 on 1/7/25.
//

import Foundation

protocol ViewControllerFactoryProtocol {
    func makeLoginVC() -> LoginViewController
    func makeTabBarVC() -> TabBarController
    func makeHomeVC() -> HomeViewController
    func makeClipVC() -> ClipViewController
    func makeEditClipVC() -> EditClipViewController
    func makeAddLinkVC() -> AddLinkViewController
    func makeSelectClipVC() -> SelectClipViewController
    func makeDetailClipVC() -> DetailClipViewController
    func makeLinkWebVC() -> LinkWebViewController
    func makeSearchVC() -> SearchViewController
    func makeRemindVC() -> RemindViewController
    func makeRemindSelectClipVC() -> RemindSelectClipViewController
    func makeRemindTimerAddVC() -> RemindTimerAddViewController
    func makeSettingVC() -> SettingViewController
}

final class ViewControllerFactory: ViewControllerFactoryProtocol {
    
    static let shared = ViewControllerFactory()
    private init() {}
    
    func makeLoginVC() -> LoginViewController {
        let loginVC = LoginViewController()
        return loginVC
    }
    
    func makeTabBarVC() -> TabBarController {
        let tabBarVC = TabBarController()
        return tabBarVC
    }
    
    func makeHomeVC() -> HomeViewController {
        let viewModel = HomeViewModel()
        let detailClipViewModel = DetailClipViewModel()
        let homeVC = HomeViewController(viewModel: viewModel, clipViewModel: detailClipViewModel)
        return homeVC
    }
    
    func makeClipVC() -> ClipViewController {
        let viewModel = ClipViewModel()
        let clipVC = ClipViewController(viewModel: viewModel)
        return clipVC
    }
    
    func makeEditClipVC() -> EditClipViewController {
        let viewModel = EditClipViewModel()
        let editClipVC = EditClipViewController(viewModel: viewModel)
        return editClipVC
    }
    
    func makeAddLinkVC() -> AddLinkViewController {
        let viewModel = AddLinkViewModel()
        let addLinkVC = AddLinkViewController(viewModel: viewModel)
        return addLinkVC
    }
    
    func makeSelectClipVC() -> SelectClipViewController {
        let viewModel = SelectClipViewModel()
        let selectClipVC = SelectClipViewController(viewModel: viewModel)
        return selectClipVC
    }
    
    func makeDetailClipVC() -> DetailClipViewController {
        let viewModel = DetailClipViewModel()
        let detailClipVC = DetailClipViewController(viewModel: viewModel)
        return detailClipVC
    }
    
    func makeLinkWebVC() -> LinkWebViewController {
        let viewModel = LinkWebViewModel()
        let linkWebVC = LinkWebViewController(viewModel: viewModel)
        return linkWebVC
    }
    
    func makeSearchVC() -> SearchViewController {
        let viewModel = SearchViewModel()
        let searchVC = SearchViewController(viewModel: viewModel)
        return searchVC
    }
    
    func makeRemindVC() -> RemindViewController {
        let viewModel = RemindViewModel()
        let remindVC = RemindViewController(viewModel: viewModel)
        return remindVC
    }
    
    func makeRemindSelectClipVC() -> RemindSelectClipViewController {
        let viewModel = RemindSelectClipViewModel()
        let remindSelectClipVC = RemindSelectClipViewController(viewModel: viewModel)
        return remindSelectClipVC
    }
    
    func makeRemindTimerAddVC() -> RemindTimerAddViewController {
        let viewModel = RemindTimerAddViewModel()
        let remindTimerAddVC = RemindTimerAddViewController(viewModel: viewModel)
        return remindTimerAddVC
    }
    
    func makeSettingVC() -> SettingViewController {
        let settingVC = SettingViewController()
        return settingVC
    }
}

//
//  TabBarItem.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/01.
//

import UIKit

enum TabBarItem: CaseIterable {
    
    case home, clip, plus, search, timer

    // 선택되지 않은 탭
    var normalItem: UIImage? {
        switch self {
        case .home:
            return .icHome24.withTintColor(.gray150)
        case .clip:
            return .icClipFull24.withTintColor(.gray150)
        case .plus:
            return .fabPlus
        case .search:
            return .icSearch24.withTintColor(.gray150)
        case .timer:
            return .icTimer24.withTintColor(.gray150)
        
        }
    }
    
    // 선택된 탭
    var selectedItem: UIImage? {
        switch self {
        case .home:
            return .icHome24.withTintColor(.black900)
        case .clip:
            return .icClipFull24.withTintColor(.black900)
        case .plus:
            return .fabPlus
        case .search:
            return .icSearch24.withTintColor(.black900)
        case .timer:
            return .icTimer24.withTintColor(.black900)
        }
    }
    
    // 탭 별 제목
    var itemTitle: String? {
        switch self {
        case .home: return StringLiterals.Tabbar.home
        case .clip: return StringLiterals.Tabbar.clip
        case .plus: return nil
        case .search: return StringLiterals.Tabbar.search
        case .timer: return StringLiterals.Tabbar.timer
        }
    }
    
    // 탭 별 전환될 화면 -> 나중에 하나씩 추가
    var targetViewController: UIViewController {
        switch self {
        case .home: return HomeViewController()
        case .clip: return ClipViewController()
        case .plus: return ViewController()
        case .search: return SearchViewController()
        case .timer: return RemindViewController()
        }
    }
}

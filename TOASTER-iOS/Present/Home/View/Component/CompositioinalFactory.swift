//
//  CompositioinalFactory.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/09.
//

import UIKit

// MARK: - Compositional Layout

enum CompositionalFactory {
    static func create() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, _ environment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            switch sectionNumber {
            case 0:
                section = createMainSection()
            case 1:
                section = createUserClipSection()
            case 2:
                section = createWeeklyLinkSection()
            case 3:
                section = createWeeklyRecommendSection()
            default:
                section = createMainSection()
            }
            return section
        }
    }
    
    // MARK: - Main Section Layout
    
    static func createMainSection() -> NSCollectionLayoutSection {
        let itemFractionalWidthFraction = 1.0
        let itemInset: CGFloat = 0
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemFractionalWidthFraction),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                     leading: itemInset,
                                                     bottom: itemInset,
                                                     trailing: itemInset)
        
        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(158))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                        leading: itemInset,
                                                        bottom: itemInset,
                                                        trailing: itemInset)
        
        // Footer
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(4)),
                                                        elementKind: UICollectionView.elementKindSectionFooter, 
                                                        alignment: .bottom)]
        return section
    }
    
    // MARK: - User Clip 에 대한 Layout
    
    static func createUserClipSection() -> NSCollectionLayoutSection {
        let itemFractionalWidthFraction = 1.0 / 2.0
        let itemInset: CGFloat = 7
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemFractionalWidthFraction),
                                              heightDimension: .absolute(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                     leading: itemInset,
                                                     bottom: itemInset,
                                                     trailing: itemInset)
        
        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                        leading: itemInset,
                                                        bottom: itemInset,
                                                        trailing: itemInset)
        
        // Header, Footer
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(46)),
                                                        elementKind: UICollectionView.elementKindSectionHeader, 
                                                        alignment: .top),
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(17)),
                                                        elementKind: UICollectionView.elementKindSectionFooter, 
                                                        alignment: .bottom)]
        return section
    }
    
    // MARK: - Weekly Link 에 대한 Layout
    
    static func createWeeklyLinkSection() -> NSCollectionLayoutSection {
        let itemFractionalWidthFraction = 1.0
        let itemInset: CGFloat = 7
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemFractionalWidthFraction),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                     leading: itemInset,
                                                     bottom: itemInset,
                                                     trailing: itemInset)
        
        // group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(600)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitem: item, 
                                                     count: 5)
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                        leading: itemInset,
                                                        bottom: itemInset,
                                                        trailing: itemInset)
        
        // Header, Footer
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(50)),
                                                        elementKind: UICollectionView.elementKindSectionHeader, 
                                                        alignment: .top),
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(20)),
                                                        elementKind: UICollectionView.elementKindSectionFooter, 
                                                        alignment: .bottom)]
        return section
    }
    
    // MARK: - Weekly Recommend 에 대한 Layout
    
    static func createWeeklyRecommendSection() -> NSCollectionLayoutSection {
        let itemFractionalWidthFraction = 1.0 / 3.0
        let itemInset: CGFloat = 7
        
        // item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemFractionalWidthFraction),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                     leading: itemInset,
                                                     bottom: itemInset,
                                                     trailing: itemInset)
        
        // group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(115)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: itemInset,
                                                        leading: itemInset,
                                                        bottom: itemInset,
                                                        trailing: itemInset)
        
        // Header
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                          heightDimension: .absolute(50)),
                                                        elementKind: UICollectionView.elementKindSectionHeader, 
                                                        alignment: .top)]
        return section
    }
}

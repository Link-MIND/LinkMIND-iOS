//
//  ChangeClipBottomSheetView.swift
//  TOASTER-iOS
//
//  Created by ParkJunHyuk on 10/9/24.
//

import UIKit

import SnapKit
import Then

final class ChangeClipBottomSheetView: UIView {
    
    // MARK: - Properties
    
    var dataSourceHandler: (() -> [SelectClipModel])?
    
    weak var delegate: ChangeClipBottomSheetViewDelegate?
    
    // MARK: - UI Components
    
    private var clipSelectCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let completeBottomButton = UIButton()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupRegisterCell()
        setupDelegate()
        setupAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadChangeClipBottom() {
        clipSelectCollectionView.reloadData()
    }
    
    /// 버튼 활성화에 따른 UI 변경
    func updateCompleteButtonUI(_ isEnable: Bool) {
        if isEnable == true {
            completeBottomButton.isUserInteractionEnabled = true
            completeBottomButton.backgroundColor = .black850
        } else {
            completeBottomButton.isUserInteractionEnabled = false
            completeBottomButton.backgroundColor = .gray200
        }
    }
}

// MARK: - Private Extensions

private extension ChangeClipBottomSheetView {
    func setupStyle() {
        backgroundColor = .gray50
        
        clipSelectCollectionView.do {
            $0.backgroundColor = .gray50
            $0.makeRounded(radius: 12)
            $0.clipsToBounds = true
            $0.isScrollEnabled = true
            $0.showsVerticalScrollIndicator = false
        }
        
        completeBottomButton.do {
            $0.setTitle(StringLiterals.Button.complete, for: .normal)
            $0.setTitleColor(.toasterWhite, for: .normal)
            $0.backgroundColor = .gray200
            $0.makeRounded(radius: 12)
        }
    }
    
    func setupHierarchy() {
        addSubviews(clipSelectCollectionView, completeBottomButton)
    }
    
    func setupLayout() {
        clipSelectCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(completeBottomButton.snp.top).offset(-20)
        }
        
        completeBottomButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(34)
            $0.height.equalTo(62)
        }
    }
    
    func setupRegisterCell() {
        clipSelectCollectionView.register(RemindSelectClipCollectionViewCell.self, forCellWithReuseIdentifier: RemindSelectClipCollectionViewCell.className)
    }
    
    func setupDelegate() {
        clipSelectCollectionView.delegate = self
        clipSelectCollectionView.dataSource = self
    }
    
    func setupAddTarget() {
        completeBottomButton.addTarget(self, action: #selector(completeBottomuttonTapped), for: .touchUpInside)
    }
    
    @objc func completeBottomuttonTapped(_ sender: UIButton) {
        delegate?.completButtonTap()
    }
}

// MARK: - CollectionView DataSource

extension ChangeClipBottomSheetView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceHandler?().count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemindSelectClipCollectionViewCell.className, for: indexPath) as? RemindSelectClipCollectionViewCell, let clipData = dataSourceHandler?() else { return UICollectionViewCell() }
        
        if indexPath.row == 0 {
            cell.configureCurrentClipCell(forModel: clipData[indexPath.item], icon: .icClip24)
        } else {
            cell.configureChnageClipCell(forModel: clipData[indexPath.item], icon: .icClip24Black)
        }
            
        return cell
    }
}

// MARK: - CollectionViewDelegate

extension ChangeClipBottomSheetView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 0  // 첫 번째 아이템(인덱스 0)이 아닌 경우에만 true 반환
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let clipData = dataSourceHandler?() else { return }

        if indexPath.item != 0 {
            delegate?.didSelectClip(selectClipId: clipData[indexPath.row].id)
            
            if let cell = collectionView.cellForItem(at: .SubSequence(item: 0, section: 0)) {
                cell.isSelected = false
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChangeClipBottomSheetView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: convertByWidthRatio(335), height: 54)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

protocol ChangeClipBottomSheetViewDelegate: AnyObject {
    func didSelectClip(selectClipId: Int)
    func completButtonTap()
}

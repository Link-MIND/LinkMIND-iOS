//
//  UserClipEmptyCollectionViewCell.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/11.
//

import UIKit

import SnapKit
import Then

// MARK: - 클립 추가 Empty Cell

final class UserClipEmptyCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let addClipImage = UIImageView()
    private let addClipLabel = UILabel()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Make View
    
    func setView() {
        setupStyle()
        setupLayer()
        setupHierarchy()
        setupLayout()
    }
}

// MARK: - Private Extensions

private extension UserClipEmptyCollectionViewCell {
    func setupStyle() {
        backgroundColor = .clear
        
        addClipImage.do {
            $0.image = .btnPlus
        }
        
        addClipLabel.do {
            $0.font = .suitBold(size: 14)
            $0.textColor = .gray200
            $0.text = "첫번째 링크를 저장해보세요"
        }
    }
    
    func setupHierarchy() {
        addSubviews(addClipImage, addClipLabel)
    }
    
    func setupLayout() {
        addClipImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(17)
            $0.size.equalTo(42)
        }
        
        addClipLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(addClipImage.snp.bottom).offset(5)
        }
    }
    
    // Button 테두리 점선 Custom
    func setupLayer() {
        let customLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, 
                               y: 0,
                               width: frameSize.width,
                               height: frameSize.height)
        
        customLayer.bounds = shapeRect
        customLayer.position = CGPoint(x: frameSize.width/2, 
                                       y: frameSize.height/2)
        customLayer.fillColor = UIColor.clear.cgColor
        customLayer.strokeColor = UIColor.gray100.cgColor
        customLayer.lineWidth = 2
        customLayer.lineJoin = CAShapeLayerLineJoin.round
        customLayer.lineDashPattern = [4, 4]
        customLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 12).cgPath
        
        self.layer.addSublayer(customLayer)
    }
}

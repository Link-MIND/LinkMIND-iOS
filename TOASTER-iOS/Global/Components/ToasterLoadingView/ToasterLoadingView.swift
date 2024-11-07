//
//  ToasterLoadingView.swift
//  TOASTER-iOS
//
//  Created by 민 on 10/7/24.
//

import UIKit

import SnapKit

final class ToasterLoadingView: UIView {
    
    // MARK: - Properties
    
    /// 현재 로딩 뷰의 애니메이션이 동작하고 있는지를 Bool 값으로 반환
    private(set) var isAnimating: Bool = false
    
    /// 애니메이션이 중단될 때 로딩 뷰를 사라지게할지/말지를 Bool 값으로 결정
    var hidesWhenStopped: Bool = true
    
    // MARK: - UI Components
    
    private let backgroundShapeLayer = CAShapeLayer()
    private let loadingShapeLayer = CAShapeLayer()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupHierarchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
    }
}

// MARK: - Extensions

extension ToasterLoadingView {
    /// 커스텀 로딩 애니메이션을 시작합니다
    func startAnimation() {
        guard !isAnimating else { return }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = 2 * CGFloat.pi
        rotationAnimation.duration = 1
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.repeatCount = .infinity
        
        layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        isAnimating = true
        if hidesWhenStopped { self.isHidden = false }
    }
    
    /// 커스텀 로딩 애니메이션을 멈춥니다
    func stopAnimation() {
        guard isAnimating else { return }
        layer.removeAnimation(forKey: "rotationAnimation")
        
        isAnimating = false
        if hidesWhenStopped { self.isHidden = true }
    }
}

// MARK: - Private Extensions

private extension ToasterLoadingView {
    func setupStyle() {
        backgroundShapeLayer.do {
            $0.strokeColor = UIColor.toasterWhite.cgColor
            $0.fillColor = UIColor.clear.cgColor
        }
        
        loadingShapeLayer.do {
            $0.strokeColor = UIColor.black850.cgColor
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeEnd = 0.25
            $0.lineCap = .round
        }
    }
    
    func setupLayers() {
        let centerPoint = CGPoint(x: frame.width / 2, y: bounds.height / 2)
        let radius = bounds.width / 2
        
        // 흰색 부분의 동그라미 배경 경로
        let backgroundPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        backgroundShapeLayer.path = backgroundPath.cgPath
        backgroundShapeLayer.lineWidth = radius / 3
        
        // 검정색 실제 로딩이 되는 부분의 경로
        let loadingPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        loadingShapeLayer.path = loadingPath.cgPath
        loadingShapeLayer.lineWidth = radius / 3
    }
    
    func setupHierarchy() {
        [backgroundShapeLayer, loadingShapeLayer].forEach {
            layer.addSublayer($0)
        }
    }
}

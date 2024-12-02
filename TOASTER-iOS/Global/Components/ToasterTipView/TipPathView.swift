//
//  TipType.swift
//  TOASTER-iOS
//
//  Created by 민 on 10/11/24.
//

import UIKit

import SnapKit

enum TipType {
    case top, bottom, left, right
}

final class TipPathView: UIView {
    
    // MARK: - Properties
    
    private var tipType: TipType
    
    private let arrowWidth: CGFloat = 10.0
    private let arrowHeight: CGFloat = 9.0
    
    // MARK: - UI Components
    
    private let tipPath = UIBezierPath()
    
    // MARK: - Life Cycles
    
    init(tipType: TipType) {
        self.tipType = tipType
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        switch tipType {
        case .top: drawTopTip(rect)
        case .bottom: drawBottomTip(rect)
        case .left: drawLeftTip(rect)
        case .right: drawRightTip(rect)
        }
        setupTip()
    }
}

// MARK: - Private Extensions

private extension TipPathView {
    func setupTip() {
        tipPath.do {
            $0.lineJoinStyle = .round
            $0.lineWidth = 2
            tipPath.close()
            UIColor.black900.setStroke()
            tipPath.stroke()
            UIColor.black900.setFill()
            tipPath.fill()
        }
    }
    
    /// 팁이 상단에 위치했을 때 - 아래를 가리키는 방향
    func drawTopTip(_ rect: CGRect) {
        tipPath.move(to: CGPoint(x: rect.midX - arrowWidth/2, y: rect.maxY - arrowHeight))
        tipPath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        tipPath.addLine(to: CGPoint(x: rect.midX + arrowWidth/2, y: rect.maxY - arrowHeight))
    }
    
    /// 팁이 하단에 위치했을 때 - 위를 가리키는 방향
    func drawBottomTip(_ rect: CGRect) {
        tipPath.move(to: CGPoint(x: rect.midX - arrowWidth/2, y: rect.minY + arrowHeight))
        tipPath.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        tipPath.addLine(to: CGPoint(x: rect.midX + arrowWidth/2, y: rect.minY + arrowHeight))
    }
    
    /// 팁이 좌측에 위치했을 때 - 오른쪽을 가리키는 방향
    func drawLeftTip(_ rect: CGRect) {
        tipPath.move(to: CGPoint(x: rect.maxX - arrowHeight, y: rect.midY - arrowWidth/2))
        tipPath.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        tipPath.addLine(to: CGPoint(x: rect.maxX - arrowHeight, y: rect.midY + arrowWidth/2))
    }
    
    /// 팁이 우측에 위치했을 때 - 왼쪽을 가리키는 방향
    func drawRightTip(_ rect: CGRect) {
        tipPath.move(to: CGPoint(x: rect.minX + arrowHeight, y: rect.midY - arrowWidth/2))
        tipPath.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        tipPath.addLine(to: CGPoint(x: rect.minX + arrowHeight, y: rect.midY + arrowWidth/2))
    }
}

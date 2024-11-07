//
//  ToasterTipView.swift
//  TOASTER-iOS
//
//  Created by 민 on 10/11/24.
//

import UIKit

import SnapKit

final class ToasterTipView: UIView {
    
    // MARK: - Properties
    
    /// 현재 툴팁이 보여지고 있는지 여부를 Bool 값으로 반환
    private(set) var isShow: Bool = false
    
    private let title: String
    private let tipType: TipType
    
    // MARK: - UI Components
    
    private weak var sourceView: UIView?
    
    private let containerView = UIView()
    private let tipLabel = UILabel()
    private lazy var tipPathView = TipPathView(tipType: tipType)
    
    // MARK: - Life Cycles
    
    init(title: String, type: TipType, sourceItem: AnyObject) {
        self.title = title
        self.tipType = type
        self.sourceView = (sourceItem as? UIView) ?? sourceItem.view
        super.init(frame: .zero)
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension ToasterTipView {
    /// 툴팁을 보여줄 때 호출하는 함수 (with 애니메이션)
    func showToolTip() {
        guard !isShow else { return }
        guard let sourceView else { return }
        isShow = true
        
        setupTooltipLayoutBySourceView()
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        let finalPosition: CGPoint
        switch tipType {
        case .top:
            finalPosition = CGPoint(
                x: sourceView.center.x,
                y: sourceView.frame.minY
            )
        case .bottom:
            finalPosition = CGPoint(
                x: sourceView.center.x,
                y: sourceView.frame.maxY
            )
        case .left:
            finalPosition = CGPoint(
                x: sourceView.frame.minX - self.frame.width / 2,
                y: sourceView.center.y
            )
        case .right:
            finalPosition = CGPoint(
                x: sourceView.frame.maxX + self.frame.width / 2,
                y: sourceView.center.y
            )
        }
        self.center = CGPoint(
            x: sourceView.center.x,
            y: sourceView.center.y
        )
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                guard let self else { return }
                self.alpha = 1
                self.transform = CGAffineTransform.identity
                self.center = finalPosition
            })
    }
    
    /// 툴팁을 사라지게 할 때 호출하는 함수 (with 애니메이션)
    func dismissToolTip(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                guard let self else { return }
                guard self.isShow else { return }
                self.isShow = false
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                completion?()
            })
    }
    
    /// 툴팁을 보여주고, 특정 시간 이후에 자동으로 닫히도록 하는 함수 (with 애니메이션)
    func showToolTipAndDismissAfterDelay(
        duration: Int,
        completion: (() -> Void)? = nil
    ) {
        showToolTip()
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .seconds(duration)
        ) { [weak self] in
            self?.dismissToolTip(completion: completion)
        }
    }
}

// MARK: - Private Extensions

private extension ToasterTipView {
    func setupStyle() {
        backgroundColor = .clear
        
        tipPathView.do {
            $0.backgroundColor = .clear
        }
        
        containerView.do {
            $0.backgroundColor = .black900
            $0.makeRounded(radius: 8)
        }
        
        tipLabel.do {
            $0.text = title
            $0.numberOfLines = 2
            $0.font = .suitMedium(size: 12)
            $0.textColor = .toasterWhite
            $0.textAlignment = .center
        }
    }
    
    func setupHierarchy() {
        addSubviews(tipPathView, containerView)
        containerView.addSubviews(tipLabel)
    }
    
    func setupLayout() {
        tipPathView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(9)
        }
        
        tipLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func setupTooltipLayoutBySourceView() {
        guard let sourceView else { return }
        
        switch tipType {
        case .top:
            self.snp.makeConstraints {
                $0.bottom.equalTo(sourceView.snp.top).offset(-8)
                $0.centerX.equalTo(sourceView.snp.centerX)
            }
        case .bottom:
            self.snp.makeConstraints {
                $0.top.equalTo(sourceView.snp.bottom).offset(8)
                $0.centerX.equalTo(sourceView.snp.centerX)
            }
        case .left:
            self.snp.makeConstraints {
                $0.right.equalTo(sourceView.snp.left).offset(-8)
                $0.centerY.equalTo(sourceView.snp.centerY)
            }
        case .right:
            self.snp.makeConstraints {
                $0.left.equalTo(sourceView.snp.right).offset(8)
                $0.centerY.equalTo(sourceView.snp.centerY)
            }
        }
    }
}

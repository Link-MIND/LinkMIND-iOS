//
//  UIButton+.swift
//  TOASTER-iOS
//
//  Created by 민 on 10/7/24.
//

import UIKit

import SnapKit

extension UIButton {
    
    /// 버튼 클릭 시 비동기 작업+로딩 애니메이션을 처리하기 위한 메서드입니다.
    func loadingButtonTapped(
        loadingTitle: String?,
        loadingAnimationSize: Int,
        task: (@escaping () -> Void) -> Void
    ) {
        let originalTitle = self.title(for: .normal)
        let originalBackgroundColor = self.backgroundColor
        
        self.setTitle(loadingTitle, for: .normal)
        self.isEnabled = false
        self.backgroundColor = .gray200
        
        let toasterLoadingView = ToasterLoadingView()
        toasterLoadingView.alpha = 0
        self.addSubview(toasterLoadingView)
        toasterLoadingView.snp.makeConstraints {
            $0.size.equalTo(loadingAnimationSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.titleLabel?.snp.trailing ?? self.snp.centerX)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            toasterLoadingView.snp.updateConstraints {
                $0.leading.equalTo(self.titleLabel?.snp.trailing ?? self.snp.centerX).offset(10)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            toasterLoadingView.alpha = 1.0
            toasterLoadingView.startAnimation()
        })
        
        task {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    toasterLoadingView.snp.updateConstraints {
                        $0.leading.equalTo(self.titleLabel?.snp.trailing ?? self.snp.centerX)
                    }
                    toasterLoadingView.alpha = 0
                    self.layoutIfNeeded()
                }, completion: { _ in
                    toasterLoadingView.stopAnimation()
                    toasterLoadingView.removeFromSuperview()
                    self.setTitle(originalTitle, for: .normal)
                    self.isEnabled = true
                    self.backgroundColor = originalBackgroundColor
                })
            }
        }
    }
}

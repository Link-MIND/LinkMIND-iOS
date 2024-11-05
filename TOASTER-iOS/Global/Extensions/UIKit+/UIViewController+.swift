//
//  UIViewController+.swift
//  TOASTER-iOS
//
//  Created by 김다예 on 12/29/23.
//

import UIKit

extension UIViewController {
    
    /// 네비게이션바를 숨기는 메서드
    func hideNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    /// 숨긴 네비게이션 바를 보이게 하는 메서드
    func showNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    /// 화면밖 터치시 키보드를 내려 주는 메서드
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// 팝업 표출할 수 있도록 하는 메서드
    func showPopup(forMainText: String? = nil,
                   forSubText: String? = nil,
                   forLeftButtonTitle: String,
                   forRightButtonTitle: String,
                   forLeftButtonHandler: (() -> Void)? = nil,
                   forRightButtonHandler: (() -> Void)? = nil) {
        
        let popupViewController = ToasterPopupViewController(mainText: forMainText,
                                                             subText: forSubText,
                                                             leftButtonTitle: forLeftButtonTitle,
                                                             rightButtonTitle: forRightButtonTitle,
                                                             leftButtonHandler: forLeftButtonHandler,
                                                             rightButtonHandler: forRightButtonHandler)
        
        popupViewController.modalPresentationStyle = .overFullScreen
        present(popupViewController, animated: false)
    }
    
    /// 팝업 표출할 수 있도록 하는 메서드
    func showConfirmationPopup(forMainText: String? = nil,
                               forSubText: String? = nil,
                               centerButtonTitle: String,
                               centerButtonHandler: (() -> Void)? = nil) {
        
        let popupViewController = ToasterPopupViewController(mainText: forMainText,
                                                             subText: forSubText,
                                                             centerButtonTitle: centerButtonTitle,
                                                             centerButtonHandler: centerButtonHandler)
        
        popupViewController.modalPresentationStyle = .overFullScreen
        present(popupViewController, animated: false)
    }
    
    func showLimitationPopup(forMainText: String? = nil,
                             forSubText: String? = nil,
                             forImageURL: String? = nil,
                             centerButtonTitle: String,
                             bottomButtonTitle: String,
                             centerButtonHandler: (() -> Void)? = nil,
                             bottomButtonHandler: (() -> Void)? = nil,
                             closeButtonHandler: (() -> Void)? = nil) {
        let popupViewController = ToasterPopupViewController(mainText: forMainText,
                                                             subText: forSubText,
                                                             imageURL: forImageURL,
                                                             centerButtonTitle: centerButtonTitle,
                                                             bottomButtonTitle: bottomButtonTitle,
                                                             centerButtonHandler: centerButtonHandler,
                                                             bottomButtonHandler: bottomButtonHandler,
                                                             closeButtonHandler: closeButtonHandler)
        popupViewController.modalPresentationStyle = .overFullScreen
        present(popupViewController, animated: false)
    }
    
    /// 토스트 메시지를 보여주는 메서드
    func showToastMessage(width: CGFloat,
                          status: ToastStatus,
                          message: String) {
        
        let toastView = ToasterToastMessageView(frame: CGRect(x: view.center.x-width/2, y: view.convertByHeightRatio(658), width: width, height: 46))
        self.view.addSubview(toastView)
        toastView.setupDataBind(message: message, status: status)
        
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: { _ in
            toastView.removeFromSuperview()
        })
    }
    
    /// rootVIewController 를 변경해주는 메서드
    func changeViewController(viewController: UIViewController) {
        switch viewController {
        case is LoginViewController:
            _ = KeyChainService.deleteTokens(accessKey: Config.accessTokenKey, refreshKey: Config.refreshTokenKey)
            
            // alret 관련 동작을 넣으면 좋을거 같습니다.
        default:
            print("🍞⛔️해당하는 ViewController 가 없습니다!⛔️🍞")
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController = ToasterNavigationController(rootViewController: viewController)
                print("🍞⛔️\(String(describing: type(of: viewController)))⛔️🍞")
            }
        }
    }
}
